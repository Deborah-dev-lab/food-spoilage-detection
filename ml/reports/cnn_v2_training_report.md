# CNN Version 2 — Training and Evaluation Report

## 1. Objective
Improve the classification accuracy and generalization
of the original CNN through a deeper architecture,
batch normalization and image augmentation.

## 2. Dataset
Same cleaned dataset and original splits as Version 1.

- Total images: 11,766
- Training images: 8,236
- Validation images: 1,765
- Testing images: 1,765
- Number of classes: 20
- Produce types: 10

## 3. Image Preprocessing
- Image dimensions: 224 x 224 pixels
- RGB colour format
- Pixel normalization: 0–1

## 4. Data Augmentation
- Random horizontal flipping
- Random rotation
- Random zoom
- Random translation
- Random contrast adjustments

## 5. CNN Architecture
Custom CNN trained from scratch.

Convolutional blocks:
- Block 1: 32, 32 filters
- Block 2: 64, 64 filters
- Block 3: 128, 128 filters
- Block 4: 256, 256 filters

Each convolution uses ReLU activation and batch normalization.

Additional layers:
- Max pooling
- Global average pooling
- Dense: 128 neurons
- Dropout: 0.35
- Dense: 20 neurons, Softmax activation

Total parameters: 1,211,572
Trainable parameters: 1,209,652

## 6. Training Configuration
- Optimizer: Adam
- Learning rate: 0.0005
- Loss: Sparse categorical crossentropy
- Maximum epochs: 35
- Batch size: 32
- Best checkpoint: Epoch 30

## 7. Validation Results
- Best validation accuracy: 89.24%
- Best validation loss: 0.3673

## 8. Test Evaluation
- Test accuracy: 88.90%
- Test loss: 0.5001
- Macro F1-score: 0.8834
- Weighted F1-score: 0.8862

## 9. Freshness Classification
Using grouped class probabilities:

- Produce identification accuracy: 90.65%
- Freshness classification accuracy: 96.03%

These results were obtained on the original test dataset.

## 10. Weak Classes
Rotten produce recall:
- Bell pepper: 53.66%
- Potato: 67.06%
- Carrot: 71.05%
- Apple: 84.09%

## 11. Smartphone Testing
Initial real-world smartphone photographs exposed
classification errors, including apples being
misidentified as bananas or potatoes.

The model is not yet validated for real-world deployment.

## 12. Model File
best_food_spoilage_cnn_v2.keras

Stored in Google Drive:
Food_Spoilage_Models/

## 13. Conclusion
Version 2 improved the original test accuracy from
75.64% to 88.90%, an increase of 13.26 percentage points.

However, smartphone testing revealed generalization
limitations, motivating the dataset-focused Version 3.
