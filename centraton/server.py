import torch
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from PIL import Image
import io
import os
import tempfile
from train import CarStateModel, inference_transform, predict_image  # Импорт из train.py

# Инициализация FastAPI
app = FastAPI(title="Car State Prediction API", description="API для классификации состояния автомобиля по 4 фотографиям")

# Загрузка модели
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = CarStateModel()
try:
    model.load_state_dict(torch.load('car_state_model.pth', map_location=device, weights_only=True))
    model.to(device)
    model.eval()
    print("Model loaded successfully.")
except (FileNotFoundError, RuntimeError) as e:
    print(f"Error loading model: {e}")
    model = None

@app.post("/predict", summary="Predict car state from four images")
async def predict_car_state(
    front_image: UploadFile = File(None, description="Фронтальное фото автомобиля"),
    rear_image: UploadFile = File(None, description="Заднее фото автомобиля"),
    left_image: UploadFile = File(None, description="Левое фото автомобиля"),
    right_image: UploadFile = File(None, description="Правое фото автомобиля")
):
    """
    Принимает до 4 фотографий автомобиля (фронт, зад, лево, право) и возвращает JSON с предсказаниями
    чистоты и целостности для каждой стороны, а также агрегированные результаты.
    """
    if model is None:
        raise HTTPException(status_code=500, detail="Model not loaded. Please ensure the model is trained and available.")

    images = [
        (front_image, "front"),
        (rear_image, "rear"),
        (left_image, "left"),
        (right_image, "right")
    ]
    results = []
    clean_probs = []
    integ_probs = []

    # Создаем временную папку для хранения загруженных изображений
    with tempfile.TemporaryDirectory() as temp_dir:
        for img_file, side in images:
            if img_file is None:
                continue  # Пропустить, если фото не загружено
            try:
                # Чтение изображения из UploadFile
                img_data = await img_file.read()
                image = Image.open(io.BytesIO(img_data)).convert('RGB')
                
                # Сохраняем изображение во временный файл
                temp_file_path = os.path.join(temp_dir, f"{side}.jpg")
                image.save(temp_file_path)
                
                # Предсказание с использованием пути к файлу
                cleanliness, integrity, clean_prob, integ_prob = predict_image(model, temp_file_path, device)
                results.append({
                    "side": side,
                    "cleanliness": cleanliness,
                    "cleanliness_probability": round(clean_prob * 100, 1),
                    "integrity": integrity,
                    "integrity_probability": round(integ_prob * 100, 1)
                })
                clean_probs.append(clean_prob)
                integ_probs.append(integ_prob)
            except Exception as e:
                raise HTTPException(status_code=400, detail=f"Error processing {side} image: {str(e)}")

        if not results:
            raise HTTPException(status_code=400, detail="No valid images provided.")

        # Агрегация результатов
        avg_clean_prob = sum(clean_probs) / len(clean_probs)
        avg_integ_prob = sum(integ_probs) / len(integ_probs)
        overall_cleanliness = "dirty" if avg_clean_prob > 0.5 else "clean"
        overall_integrity = "damaged" if avg_integ_prob > 0.5 else "intact"

        # Формирование JSON-ответа
        response = {
            "overall": {
                "cleanliness": overall_cleanliness,
                "cleanliness_probability": round(avg_clean_prob * 100, 1),
                "integrity": overall_integrity,
                "integrity_probability": round(avg_integ_prob * 100, 1)
            },
            "details": results
        }

        return JSONResponse(content=response)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)