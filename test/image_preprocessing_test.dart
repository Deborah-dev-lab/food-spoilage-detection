import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:food_spoilage/services/image_preprocessing_service.dart';

void main() {
  group('CNN V3 Image Preprocessing', () {
    test('Produces a 160x160 RGB tensor with valid pixel values', () {
      // Create a synthetic red image.
      final image = img.Image(width: 200, height: 200);

      img.fill(image, color: img.ColorRgb8(255, 0, 0));

      final bytes = Uint8List.fromList(img.encodePng(image));

      // Preprocess the image.
      final tensor = ImagePreprocessingService.preprocess(bytes);

      // Verify tensor dimensions.
      expect(tensor.length, 1);
      expect(tensor[0].length, 160);
      expect(tensor[0][0].length, 160);
      expect(tensor[0][0][0].length, 3);

      // Verify RGB values.
      expect(tensor[0][0][0][0], closeTo(255.0, 0.01));
      expect(tensor[0][0][0][1], closeTo(0.0, 0.01));
      expect(tensor[0][0][0][2], closeTo(0.0, 0.01));

      // Verify pixel range.
      for (final row in tensor[0]) {
        for (final pixel in row) {
          for (final channel in pixel) {
            expect(channel, inInclusiveRange(0.0, 255.0));
          }
        }
      }
    });

    test('Rejects invalid image data', () {
      final invalidBytes = Uint8List.fromList([1, 2, 3, 4]);

      expect(
        () => ImagePreprocessingService.preprocess(invalidBytes),
        throwsFormatException,
      );
    });
  });
}
