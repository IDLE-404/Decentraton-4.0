import gradio as gr
import torch
from PIL import Image
from train import CarStateModel, transform, predict_image  # Импорт из train.py

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = CarStateModel()
try:
    model.load_state_dict(torch.load('car_state_model.pth', map_location=device, weights_only=True))
    model.to(device)
    print("Model loaded successfully.")
except (FileNotFoundError, RuntimeError) as e:
    print(f"Error loading model: {e}")
    print("Please run train.py to train a new model with the updated architecture.")
    model = None

def predict_car_state(front_image, rear_image, left_image, right_image):
    if model is None:
        return "Model not loaded. Please train the model first using train.py.", None
    
    images = [front_image, rear_image, left_image, right_image]
    clean_probs = []
    integ_probs = []
    results = []
    
    for i, img_path in enumerate(images):
        if img_path is None:
            continue
        cleanliness, integrity, clean_prob, integ_prob = predict_image(model, img_path, device)
        clean_probs.append(clean_prob)
        integ_probs.append(integ_prob)
        side = ['Фронт', 'Зад', 'Лево', 'Право'][i]
        results.append(f"{side}: Чистота - {cleanliness} ({clean_prob*100:.1f}%), Целостность - {integrity} ({integ_prob*100:.1f}%)")
    
    if not clean_probs:
        return "Нет загруженных фото.", None
    
    # Агрегация: средние проценты
    avg_clean_prob = sum(clean_probs) / len(clean_probs)
    avg_integ_prob = sum(integ_probs) / len(integ_probs)
    
    overall_cleanliness = 'dirty' if avg_clean_prob > 0.5 else 'clean'
    overall_integrity = 'damaged' if avg_integ_prob > 0.5 else 'intact'
    
    overall_result = f"""
    Общая чистота: {overall_cleanliness} (процент загрязнения: {avg_clean_prob*100:.1f}%)  
    Общая целостность: {overall_integrity} (процент повреждения: {avg_integ_prob*100:.1f}%)  
    """
    
    detailed_results = "\n".join(results)
    full_result = overall_result + "\nДетали по сторонам:\n" + detailed_results
    
    return full_result, front_image if front_image else None

iface = gr.Interface(
    fn=predict_car_state,
    inputs=[
        gr.Image(type="filepath", label="Фронтальное фото"),
        gr.Image(type="filepath", label="Заднее фото"),
        gr.Image(type="filepath", label="Левое фото"),
        gr.Image(type="filepath", label="Правое фото")
    ],
    outputs=[gr.Textbox(label="Результат"), gr.Image(label="Пример фото (фронт)")],
    title="Определитель состояния автомобиля",
    description="Загрузите 4 фото со всех сторон — получите классификацию по чистоте и целостности с агрегированными процентами."
)

if __name__ == '__main__':
    iface.launch(share=False)  # share=True для публичной ссылки