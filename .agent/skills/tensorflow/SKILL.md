---
name: TensorFlow
description: Skill for deep learning with TensorFlow and Keras — covering model building (Sequential, Functional API), CNNs, RNNs, transfer learning, TensorFlow Serving, and TFLite deployment.
---

# TensorFlow Skill

## Overview
**TensorFlow** is Google's open-source deep learning framework. **Keras** (integrated in TF 2.x) provides a high-level API. This skill covers model building, training, and deployment.

---

## Installation
```bash
pip install tensorflow
# GPU support
pip install tensorflow[and-cuda]
```

---

## Model Building

### Sequential API (Simple)
```python
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

model = keras.Sequential([
    layers.Input(shape=(784,)),
    layers.Dense(256, activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(0.3),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(10, activation='softmax'),
])

model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=1e-3),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy'],
)

model.summary()
```

### Functional API (Complex)
```python
inputs = keras.Input(shape=(224, 224, 3))

# Feature extraction
x = layers.Conv2D(32, 3, activation='relu', padding='same')(inputs)
x = layers.MaxPooling2D()(x)
x = layers.Conv2D(64, 3, activation='relu', padding='same')(x)
x = layers.MaxPooling2D()(x)
x = layers.Conv2D(128, 3, activation='relu', padding='same')(x)
x = layers.GlobalAveragePooling2D()(x)

# Classification head
x = layers.Dense(256, activation='relu')(x)
x = layers.Dropout(0.5)(x)
outputs = layers.Dense(num_classes, activation='softmax')(x)

model = keras.Model(inputs=inputs, outputs=outputs, name='custom_cnn')
```

---

## Training

```python
# Callbacks
callbacks = [
    keras.callbacks.EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True),
    keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=3),
    keras.callbacks.ModelCheckpoint('best_model.keras', save_best_only=True),
    keras.callbacks.TensorBoard(log_dir='./logs'),
]

# Train
history = model.fit(
    X_train, y_train,
    validation_split=0.2,
    epochs=50,
    batch_size=32,
    callbacks=callbacks,
    verbose=1,
)

# Evaluate
test_loss, test_acc = model.evaluate(X_test, y_test)
print(f"Test accuracy: {test_acc:.4f}")
```

---

## Transfer Learning

```python
# Use pretrained model (ImageNet)
base_model = keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights='imagenet',
)
base_model.trainable = False  # Freeze base

# Add custom head
inputs = keras.Input(shape=(224, 224, 3))
x = keras.applications.mobilenet_v2.preprocess_input(inputs)
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dense(128, activation='relu')(x)
x = layers.Dropout(0.3)(x)
outputs = layers.Dense(num_classes, activation='softmax')(x)

model = keras.Model(inputs, outputs)
model.compile(optimizer=keras.optimizers.Adam(1e-4), loss='sparse_categorical_crossentropy', metrics=['accuracy'])

# Fine-tune: Unfreeze last layers after initial training
base_model.trainable = True
for layer in base_model.layers[:-20]:
    layer.trainable = False

model.compile(optimizer=keras.optimizers.Adam(1e-5), loss='sparse_categorical_crossentropy', metrics=['accuracy'])
```

---

## Data Pipeline (tf.data)

```python
# Efficient data loading
train_ds = tf.data.Dataset.from_tensor_slices((X_train, y_train))
train_ds = (train_ds
    .shuffle(10000)
    .batch(32)
    .prefetch(tf.data.AUTOTUNE)
)

# Image augmentation
augmentation = keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.1),
    layers.RandomZoom(0.1),
    layers.RandomContrast(0.1),
])
```

---

## Model Deployment

### Save & Load
```python
# Save (recommended: SavedModel format)
model.save('saved_models/my_model')
# or Keras format
model.save('model.keras')

# Load
loaded_model = keras.models.load_model('saved_models/my_model')
```

### TensorFlow Serving
```bash
# Serve model via Docker
docker run -p 8501:8501 \
  --mount type=bind,source=/models/my_model,target=/models/my_model \
  -e MODEL_NAME=my_model \
  tensorflow/serving

# Prediction API
curl -X POST http://localhost:8501/v1/models/my_model:predict \
  -H "Content-Type: application/json" \
  -d '{"instances": [[1.0, 2.0, 3.0]]}'
```

### TensorFlow Lite (Mobile/Edge)
```python
converter = tf.lite.TFLiteConverter.from_saved_model('saved_models/my_model')
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
```

## Best Practices
1. **Start with pretrained models** — transfer learning saves time and data
2. **Use tf.data** — efficient data pipeline over NumPy arrays
3. **Callbacks** — EarlyStopping, ReduceLROnPlateau, ModelCheckpoint
4. **Mixed precision** — `tf.keras.mixed_precision` for faster training
5. **TensorBoard** — visualize training metrics and model graph
6. **SavedModel format** — portable, production-ready
