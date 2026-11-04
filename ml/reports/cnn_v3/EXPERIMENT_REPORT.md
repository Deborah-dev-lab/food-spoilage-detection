# FreshTrack CNN V3 — Final Experiment Report

## 1. Project Overview

FreshTrack is a smartphone-based food freshness
classification project using computer vision and
deep learning.

CNN V3 is a custom convolutional neural network
trained to classify images of fruits and vegetables
into 32 categories representing fresh and rotten
conditions across 16 produce types.

The classification reflects visible freshness
characteristics and does not establish laboratory-
confirmed food safety.

## 2. Dataset

Original experiment records: 15248
Recovered usable records: 15145
Unavailable records excluded: 103

Training images: 10334
Validation images: 2516
Testing images: 2295

The original train, validation, and test assignments
were retained for available images.

The 103 excluded records referenced image files that
could not be restored from the available datasets.

## 3. Model Architecture

Model: FreshTrack Custom CNN V3
Input dimensions: 160 x 160 x 3
Output classes: 32
Parameters: 871,680

Architecture:
- Input rescaling (1/255)
- Training-only image augmentation
- Four convolutional blocks with 32, 64, 128,
  and 192 filters
- Batch normalization and ReLU activations
- Max pooling and spatial dropout
- Global average pooling
- Dense layer with 128 units
- Dropout of 0.35
- Softmax classification layer

The model was trained from scratch without
pretrained weights.

## 4. Training Configuration

Maximum epochs: 35
Completed epochs: 35
Batch size: 32
Optimizer: Adam
Initial learning rate: 0.001
Loss: Sparse Categorical Crossentropy

Class weights were calculated from training-class
frequencies using square-root inverse-frequency
weighting, clipped between 0.5 and 3.0.

Callbacks:
- Best-model checkpoint using validation loss
- Early stopping with patience of 8
- Learning-rate reduction with patience of 3
- CSV training logger

## 5. Training Results

Best epoch: 34
Best validation loss: 0.6507
Validation accuracy at best epoch:
81.68%

The best checkpoint was saved as:
best_food_spoilage_cnn_v3.keras

## 6. Held-Out Test Results

Test images: 2295
Test accuracy: 81.96%
Test loss: 0.6737
Weighted F1-score: 0.8171
Macro F1-score (classification report): 0.8256

The classification report and confusion matrix
are included in the evaluation folder.

## 7. Observed Limitations

The model has weaker performance for some rotten
produce categories, including rotten bell pepper,
rotten apple, rotten potato, and rotten lemon.

Some classes have limited test representation.
Fresh persimmon has no test examples, while fresh
watermelon has only three.

Therefore, class-specific performance estimates
should be interpreted cautiously.

The recovered dataset differs slightly from the
original experiment because 103 image records
were unavailable.

Real-world testing with smartphone photographs
under different lighting and background conditions
is still required.

## 8. Mobile Deployment

The best CNN V3 checkpoint was converted into
TensorFlow Lite format.

TFLite model: freshtrack_cnn_v3.tflite
Input: float32 tensor [1, 160, 160, 3]
Output: float32 tensor [1, 32]

RGB input pixels should be provided on the
0-255 scale because normalization is performed
inside the model.

The labels.txt file preserves the training
class-index order.

The model passed a basic TensorFlow Lite inference
test. Mobile-device performance and prediction
equivalence testing remain to be completed.

## 9. Reproducibility and Files

notebook/ contains the final Colab notebook
when available.

model/ contains the Keras checkpoint and TFLite model.

metadata/ contains class mappings and configuration.

evaluation/ contains training history, metrics,
classification reports, and confusion matrices.

dataset/ contains original and recovered manifests,
including excluded image records.

The actual training images are not included in this
checkpoint package.

## 10. Conclusion

FreshTrack CNN V3 achieved a held-out test accuracy
of 81.96% across 2,295 available
test images.

The experiment demonstrates the feasibility of
smartphone-based visual freshness classification,
while highlighting limitations in class balance,
per-class reliability, and real-world generalization.
