# CNN Version 1 — Training and Evaluation Report

## 1. Objective
Develop an initial custom Convolutional Neural Network (CNN)
for classifying visible freshness and spoilage in fruits
and vegetables using smartphone-compatible images.

## 2. Dataset
- Original cleaned food spoilage dataset
- Total images: 11,766
- Training images: 8,236
- Validation images: 1,765
- Testing images: 1,765
- Number of classes: 20
- Produce types: 10
- Freshness categories: Fresh and Rotten

## 3. Image Preprocessing
- Image dimensions: 224 x 224 pixels
- RGB colour format
- Pixel normalization: 0–1
- Stratified dataset split
- Random seed: 42

## 4. CNN Architecture
Custom CNN trained from scratch.

- Conv2D: 32 filters
- MaxPooling2D
- Conv2D: 64 filters
- MaxPooling2D
- Conv2D: 128 filters
- GlobalAveragePooling2D
- Dense: 128 neurons
- Dropout: 0.30
- Dense: 20 neurons, Softmax activation

Trainable parameters: 112,340

## 5. Training
- Training epochs: 20
- Final training accuracy: 74.24%
- Best validation accuracy: 76.94%
- Validation loss: 0.7620

## 6. Test Evaluation
- Test accuracy: 75.64%
- Test loss: 0.8239
- Macro F1-score: 0.7512

## 7. Limitations
- Moderate classification accuracy
- Difficulty distinguishing certain rotten produce classes
- Limited evidence of real-world smartphone generalization

## 8. Model File
best_food_spoilage_cnn.keras

Stored in Google Drive:
Food_Spoilage_Models/

## 9. Conclusion
Version 1 established the baseline performance for the
food spoilage classification system and motivated
architectural improvements in Version 2.
