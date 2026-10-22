# CNN Version 3 — Dataset Assessment

## Project
Smartphone-Based Food Spoilage Detection

## Objective
Assess the suitability of an additional fruit and vegetable
dataset before developing CNN Version 3.

## Datasets
1. Original Food Spoilage Dataset
2. Fruits-360
3. Classificação de Frutas e Vegetais

## New Dataset Structure
- com_classificacao: Quality-labelled images
- bom: Good
- ruim: Bad
- sem_classificacao: Images without quality labels

## Quality-Labelled Dataset
Total images: 12,282
Good images: 4,769
Bad images: 7,513

Produce types: 13
Produce types with both labels: 12

Avocado:
- Good: 504
- Bad: 100

Strawberry:
- Good: 0
- Bad: 97

Pineapple and cabbage do not have quality-labelled
folders in this dataset.

## Exact Duplicate Audit
Total image files: 12,282
Unique file hashes: 12,220
Duplicate groups: 62
Extra duplicate files: 62
Conflicting Good/Bad duplicate groups: 0

## Cross-Dataset Overlap
Original dataset images: 11,766
New dataset images: 12,282
Matching files: 64
Unique overlapping images: 63

Original split overlap:
- Training: 46
- Validation: 11
- Test: 6

## Visual Assessment
- Many inspected images have plain backgrounds.
- Some examples contain multiple produce items.
- Some examples appear visually identical or highly similar.
- Visible spoilage is present in several bad-quality examples.
- Image diversity and label consistency require further review.

## Preliminary Findings
The dataset is a promising candidate for CNN Version 3,
particularly for avocado and additional spoilage examples.

However, datasets must not be merged without:
1. Exact duplicate removal.
2. Near-duplicate and source-overlap checks.
3. Verification of Good/Bad versus Fresh/Rotten labels.
4. Protection of original validation and test images.
5. An independent smartphone-image evaluation dataset.

## CNN V3 Decision
Proceed to dataset preparation and further validation.
Do not begin training until the combined dataset has
passed the required checks.

## Model Development
CNN Version 3 will remain a custom CNN trained from scratch,
without pretrained weights.
