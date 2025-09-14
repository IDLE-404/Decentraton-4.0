import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms, models
from torchvision.models import ResNet50_Weights
from PIL import Image
import os
import random

class CarDataset(Dataset):
    def __init__(self, root_dir, transform=None):
        self.root_dir = root_dir
        self.transform = transform
        self.images = []
        self.labels = []
        
        classes = ['clean_intact', 'clean_damaged', 'dirty_intact', 'dirty_damaged']
        label_map = {
            'clean_intact': (0, 0),
            'clean_damaged': (0, 1),
            'dirty_intact': (1, 0),
            'dirty_damaged': (1, 1)
        }
        
        for cls in classes:
            cls_dir = os.path.join(root_dir, cls)
            if os.path.exists(cls_dir):
                for img_name in os.listdir(cls_dir):
                    if img_name.endswith(('.jpg', '.png')):
                        self.images.append(os.path.join(cls_dir, img_name))
                        self.labels.append(label_map[cls])
        
    def __len__(self):
        return len(self.images)
    
    def __getitem__(self, idx):
        img_path = self.images[idx]
        image = Image.open(img_path).convert('RGB')
        label = self.labels[idx]
        
        if self.transform:
            image = self.transform(image)
        
        return image, torch.tensor(label, dtype=torch.float32)

class CarStateModel(nn.Module):
    def __init__(self):
        super(CarStateModel, self).__init__()
        self.base = models.resnet50(weights=ResNet50_Weights.DEFAULT)  # Используем weights вместо deprecated pretrained
        num_ftrs = self.base.fc.in_features
        self.base.fc = nn.Identity()
        
        self.cleanliness_head = nn.Sequential(
            nn.Linear(num_ftrs, 128),
            nn.ReLU(),
            nn.Dropout(0.3),  # Dropout для регуляризации
            nn.Linear(128, 1),
            nn.Sigmoid()
        )
        self.integrity_head = nn.Sequential(
            nn.Linear(num_ftrs, 128),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(128, 1),
            nn.Sigmoid()
        )
    
    def forward(self, x):
        features = self.base(x)
        cleanliness = self.cleanliness_head(features)
        integrity = self.integrity_head(features)
        return cleanliness, integrity

transform = transforms.Compose([
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(15),
    transforms.RandomResizedCrop(224, scale=(0.8, 1.0)),
    transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2, hue=0.1),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

inference_transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

def train_model(train_dir='dataset/train', epochs=50, batch_size=32, lr=0.0005):
    dataset = CarDataset(train_dir, transform=transform)
    if len(dataset) == 0:
        print("No data found! Check dataset structure.")
        return None
    dataloader = DataLoader(dataset, batch_size=batch_size, shuffle=True)
    
    model = CarStateModel()
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    model.to(device)
    
    criterion = nn.BCELoss()
    optimizer = optim.Adam(model.parameters(), lr=lr)
    scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=5, gamma=0.1)
    
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        for images, labels in dataloader:
            images = images.to(device)
            clean_labels = labels[:, 0].to(device)
            integ_labels = labels[:, 1].to(device)
            
            optimizer.zero_grad()
            clean_pred, integ_pred = model(images)
            
            loss_clean = criterion(clean_pred.squeeze(), clean_labels)
            loss_integ = criterion(integ_pred.squeeze(), integ_labels)
            loss = loss_clean + loss_integ
            
            loss.backward()
            optimizer.step()
            running_loss += loss.item()
        
        scheduler.step()
        print(f'Epoch {epoch+1}, Loss: {running_loss / len(dataloader):.4f}')
    
    torch.save(model.state_dict(), 'car_state_model.pth')
    return model

def predict_image(model, image_path, device):
    model.eval()
    image = Image.open(image_path).convert('RGB')
    image = inference_transform(image).unsqueeze(0).to(device)
    
    with torch.no_grad():
        clean_pred, integ_pred = model(image)
    
    cleanliness_prob = clean_pred.item()
    integrity_prob = integ_pred.item()
    cleanliness = 'dirty' if cleanliness_prob > 0.5 else 'clean'
    integrity = 'damaged' if integrity_prob > 0.5 else 'intact'
    
    return cleanliness, integrity, cleanliness_prob, integrity_prob

if __name__ == '__main__':
    model = train_model()