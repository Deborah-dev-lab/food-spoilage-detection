# CNN Development Progress

**Project:** Smartphone-Based Food Spoilage Detection
**Last Updated:** 22 October 2026
**Current Phase:** CNN Version 3 — Dataset Preparation
**Status:** Dataset assessment completed; V3 training not started.

## CNN Version 1 — Completed

Developed a custom CNN from scratch to classify visible freshness and spoilage across 20 classes (10 produce types, Fresh and Rotten).

- Cleaned dataset: 11,766 images
- Training images: 8,236
- Validation images: 1,765
- Test images: 1,765
- Test accuracy: 75.64%
- Macro F1-score: 0.7512

**Outcome:** Established baseline classification performance.

## CNN Version 2 — Completed

Improved the custom CNN using additional convolutional layers, batch normalization, and data augmentation.

- Test accuracy: 88.90%
- Macro F1-score: 0.8834
- Produce identification accuracy: 90.65%
- Freshness classification accuracy: 96.03%

**Outcome:** Improved test-set accuracy, but real-world smartphone photographs exposed classification errors.

## CNN Version 3 — Dataset Assessment Completed

Assessed the Classificacao de Frutas e Vegetais dataset.

### Dataset distribution

- Total quality-labelled images: 12,282
- Good images: 4,769
- Bad images: 7,513
- Produce types: 13
- Produce types with both quality labels: 12
- Avocado: 504 Good and 100 Bad images
- Strawberry: 97 Bad images and no Good images

Pineapple and cabbage are present only in the unclassified portion of this dataset.

### Duplicate audit

- Unique image hashes: 12,220
- Extra exact duplicate files: 62
- Conflicting Good/Bad exact duplicate groups: 0

### Cross-dataset overlap

Compared the new quality-labelled dataset with the original cleaned dataset.

- Matching files: 64
- Unique overlapping images: 63

Overlap by original split:
- Training: 46
- Validation: 11
- Test: 6

### Visual audit

- Many inspected photographs have plain backgrounds.
- Some images contain multiple produce items.
- Some examples appear visually identical or highly similar.
- Several Bad images show visible spoilage.

### Version 3 decision

The new dataset is a candidate for improving CNN generalization and introducing avocado.

Before training, we must:
- Verify label compatibility between Good/Bad and Fresh/Rotten.
- Remove exact duplicates and investigate near-duplicates.
- Prevent original validation and test images from entering V3 training.
- Review overlap with Fruits-360.
- Establish an independent smartphone-photo evaluation set.

## Current Project Status

- CNN V1: Trained and evaluated
- CNN V2: Trained and evaluated
- CNN V3: Dataset audit completed
- CNN V3 dataset merging: Not started
- CNN V3 training: Not started
- TensorFlow Lite deployment: Pending validation

## Next Steps

1. Step 26.1 — Create the CNN V3 Google Drive workspace.
2. Build source-aware dataset manifests.
3. Check duplicate and near-duplicate images across datasets.
4. Review quality labels and class balance.
5. Prepare leakage-safe training and validation splits.
6. Train and evaluate CNN V3 from scratch.
7. Test independent smartphone photographs.
8. Convert and validate the selected model for TensorFlow Lite.

## Research Notes

- CNN development uses custom architectures without pretrained weights.
- Fruits-360 images must not automatically be labelled Fresh.
- Good/Bad labels require verification before mapping to Fresh/Rotten.
- Original test-set performance does not establish real-world reliability.
- The application assesses visible spoilage, not microbiological food safety.

## GitHub Checkpoint

Previous commit: c477d8c
Branch: feature/cnn-model
Next implementation step: Step 26.1
