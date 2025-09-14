# inDrive AI

This project provides a machine learning-based system to classify the cleanliness and integrity of a car based on images from four sides (front, rear, left, right). It includes a training script to build a model, a FastAPI server for programmatic access, and a Gradio interface for interactive use.

## Features
- **Model Training**: Train a ResNet50-based model to predict car cleanliness and integrity using labeled images.
- **API**: A FastAPI endpoint to upload up to four images and receive JSON predictions for cleanliness and integrity.
- **Interactive Demo**: A Gradio interface for user-friendly image uploads and result visualization.
- **Predictions**: Classifies each side of the car as clean/dirty and intact/damaged, with aggregated results.

## Prerequisites
To run this project, ensure you have the following installed:
- Python 3.8 or higher
- PyTorch (`torch`, `torchvision`)
- FastAPI (`fastapi`, `uvicorn`)
- Gradio (`gradio`)
- PIL (`pillow`)
- Other dependencies listed in `requirements.txt`

## Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/car-state-prediction.git
   cd car-state-prediction
   ```

2. **Create a Virtual Environment** (optional but recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```


## Dataset Preparation
The model expects a dataset organized as follows:
```
dataset/
  train/
    clean_intact/
      image1.jpg
      image2.png
      ...
    clean_damaged/
    dirty_intact/
    dirty_damaged/
```
- Each folder (`clean_intact`, `clean_damaged`, etc.) contains images corresponding to the respective class.
- Supported image formats: `.jpg`, `.png`.
- Ensure the dataset is placed in `dataset/train/` or update the `train_dir` parameter in `train.py` if using a different path.

## Usage

### 1. Training the Model
To train the model:
```bash
python train.py
```
- The script trains a ResNet50-based model for 50 epochs (configurable) and saves the model weights to `car_state_model.pth`.
- Ensure the dataset is correctly structured in `dataset/train/`.
- The model will use CUDA if available; otherwise, it defaults to CPU.

### 2. Running the FastAPI Server
To start the API server:
```bash
python server.py
```
- The server runs on `http://127.0.0.1:8000`.
- Use the `/predict` endpoint to upload up to four images (front, rear, left, right) and receive a JSON response with cleanliness and integrity predictions.
- Example using `curl`:
  ```bash
  curl -X POST "http://127.0.0.1:8000/predict" \
       -F "front_image=@path/to/front.jpg" \
       -F "rear_image=@path/to/rear.jpg" \
       -F "left_image=@path/to/left.jpg" \
       -F "right_image=@path/to/right.jpg"
  ```
- The response includes per-side predictions and aggregated results.

### 3. Running the Gradio Interface
To launch the interactive demo:
```bash
python demo.py
```
- This opens a web interface where you can upload images for each side of the car.
- The interface displays detailed results (cleanliness and integrity for each side) and aggregated percentages.
- By default, the interface runs locally. To share it publicly, set `share=True` in `demo.py` (requires Gradio account and setup).

## Project Structure
```
car-state-prediction/
│
├── dataset/                # Dataset folder (not included in repo)
│   └── train/
│       ├── clean_intact/
│       ├── clean_damaged/
│       ├── dirty_intact/
│       └── dirty_damaged/
│
├── car_state_model.pth     # Trained model weights (generated after training)
├── train.py                # Script for training the model
├── server.py               # FastAPI server for predictions
├── demo.py                 # Gradio interface for interactive demo
├── requirements.txt        # Python dependencies
└── README.md               # This file
```

## Model Details
- **Architecture**: ResNet50 backbone with two heads for binary classification (cleanliness and integrity).
- **Training**: Uses data augmentation (random flips, rotations, crops) and Adam optimizer with learning rate scheduling.
- **Inference**: Images are resized, cropped, and normalized before prediction.
- **Output**: For each image, the model predicts:
  - Cleanliness: `clean` or `dirty` (probability threshold > 0.5 for dirty).
  - Integrity: `intact` or `damaged` (probability threshold > 0.5 for damaged).
  - Aggregated results are computed as the average probability across provided images.

## Troubleshooting
- **Model not loading**: Ensure `car_state_model.pth` exists. Run `train.py` to generate it.
- **No data found**: Verify the dataset structure and path in `train.py`.
- **CUDA errors**: If CUDA is unavailable, the model automatically uses CPU. Ensure compatible PyTorch and CUDA versions.
- **API errors**: Check that uploaded images are valid `.jpg` or `.png` files.
- **Gradio issues**: Ensure `gradio` is installed and up-to-date (`pip install gradio --upgrade`).

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.
