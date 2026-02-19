---
name: PyTorch
description: Skill for deep learning with PyTorch — covering tensor operations, model building (nn.Module), training loops, data loaders, transfer learning, and deployment with TorchServe.
---

# PyTorch Skill

## Overview
**PyTorch** is Meta's open-source deep learning framework. It uses dynamic computation graphs (eager execution) making it intuitive for research and production. It powers most modern LLMs and research papers.

---

## Installation
```bash
pip install torch torchvision torchaudio
# Check GPU
python -c "import torch; print(torch.cuda.is_available())"
```

---

## Model Building

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

class NeuralNetwork(nn.Module):
    def __init__(self, input_dim: int, num_classes: int):
        super().__init__()
        self.layer1 = nn.Linear(input_dim, 256)
        self.bn1 = nn.BatchNorm1d(256)
        self.dropout1 = nn.Dropout(0.3)
        self.layer2 = nn.Linear(256, 128)
        self.bn2 = nn.BatchNorm1d(128)
        self.dropout2 = nn.Dropout(0.2)
        self.output = nn.Linear(128, num_classes)
    
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        x = self.dropout1(F.relu(self.bn1(self.layer1(x))))
        x = self.dropout2(F.relu(self.bn2(self.layer2(x))))
        return self.output(x)

# CNN for image classification
class CNN(nn.Module):
    def __init__(self, num_classes: int):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(3, 32, kernel_size=3, padding=1),
            nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(32, 64, kernel_size=3, padding=1),
            nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(64, 128, kernel_size=3, padding=1),
            nn.ReLU(), nn.AdaptiveAvgPool2d(1),
        )
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(128, 256), nn.ReLU(), nn.Dropout(0.5),
            nn.Linear(256, num_classes),
        )
    
    def forward(self, x):
        x = self.features(x)
        return self.classifier(x)
```

---

## Training Loop

```python
from torch.utils.data import DataLoader, TensorDataset

# Setup
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = NeuralNetwork(input_dim=20, num_classes=2).to(device)
optimizer = torch.optim.AdamW(model.parameters(), lr=1e-3, weight_decay=1e-4)
scheduler = torch.optim.lr_scheduler.ReduceLROnPlateau(optimizer, patience=3, factor=0.5)
criterion = nn.CrossEntropyLoss()

# Data loaders
train_loader = DataLoader(TensorDataset(X_train_tensor, y_train_tensor), batch_size=32, shuffle=True)
val_loader = DataLoader(TensorDataset(X_val_tensor, y_val_tensor), batch_size=64)

# Training
best_val_loss = float('inf')

for epoch in range(50):
    # Train
    model.train()
    train_loss = 0.0
    for X_batch, y_batch in train_loader:
        X_batch, y_batch = X_batch.to(device), y_batch.to(device)
        
        optimizer.zero_grad()
        outputs = model(X_batch)
        loss = criterion(outputs, y_batch)
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
        optimizer.step()
        train_loss += loss.item()
    
    # Validate
    model.eval()
    val_loss = 0.0
    correct = 0
    total = 0
    with torch.no_grad():
        for X_batch, y_batch in val_loader:
            X_batch, y_batch = X_batch.to(device), y_batch.to(device)
            outputs = model(X_batch)
            val_loss += criterion(outputs, y_batch).item()
            correct += (outputs.argmax(1) == y_batch).sum().item()
            total += y_batch.size(0)
    
    val_loss /= len(val_loader)
    val_acc = correct / total
    scheduler.step(val_loss)
    
    print(f"Epoch {epoch+1}: Train Loss={train_loss/len(train_loader):.4f}, "
          f"Val Loss={val_loss:.4f}, Val Acc={val_acc:.4f}")
    
    # Save best
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        torch.save(model.state_dict(), 'best_model.pth')
```

---

## Transfer Learning

```python
import torchvision.models as models

# Pretrained model
model = models.resnet50(weights='IMAGENET1K_V2')

# Freeze all layers
for param in model.parameters():
    param.requires_grad = False

# Replace final layer
model.fc = nn.Sequential(
    nn.Linear(2048, 256), nn.ReLU(), nn.Dropout(0.3),
    nn.Linear(256, num_classes),
)

# Only train new layers
optimizer = torch.optim.Adam(model.fc.parameters(), lr=1e-3)
```

---

## Save & Load

```python
# Save model state
torch.save({
    'model_state_dict': model.state_dict(),
    'optimizer_state_dict': optimizer.state_dict(),
    'epoch': epoch,
    'best_val_loss': best_val_loss,
}, 'checkpoint.pth')

# Load
checkpoint = torch.load('checkpoint.pth')
model.load_state_dict(checkpoint['model_state_dict'])

# Export to ONNX (interoperable)
dummy_input = torch.randn(1, 20).to(device)
torch.onnx.export(model, dummy_input, 'model.onnx', input_names=['input'], output_names=['output'])
```

## Best Practices
1. **Use `device` consistently** — move model and data to same device
2. **`model.train()` / `model.eval()`** — switches dropout & batchnorm behavior
3. **`torch.no_grad()`** for inference — saves memory, prevents gradient computation
4. **Gradient clipping** — prevents exploding gradients
5. **AdamW over Adam** — better weight decay implementation
6. **Hugging Face for NLP** — use transformers library with PyTorch backend
