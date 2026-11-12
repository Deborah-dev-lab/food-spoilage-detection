import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImagePreprocessingService {
  static const int inputSize = 160;

  /// Prepares an image for FreshTrack CNN V3.
  ///
  /// Input: Image bytes (JPEG or PNG)
  /// Output shape: [1, 160, 160, 3]
  /// Pixel range: 0-255
  static List<List<List<List<double>>>> preprocess(Uint8List imageBytes) {
    // Step 1: Decode the image.
    final decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw const FormatException('Unable to decode the selected image.');
    }

    // Step 2: Correct image orientation.
    final orientedImage = img.bakeOrientation(decodedImage);

    // Step 3: Resize to CNN V3 input dimensions.
    final resizedImage = img.copyResize(
      orientedImage,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Step 4: Convert pixels into an RGB tensor.
    final inputTensor = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = resizedImage.getPixel(x, y);

          return <double>[
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ];
        }),
      ),
    );

    return inputTensor;
  }
}
