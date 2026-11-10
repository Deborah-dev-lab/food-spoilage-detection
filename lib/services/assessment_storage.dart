import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/database_helper.dart';

class AssessmentStorage {
  AssessmentStorage._();

  static Future<int> saveAssessment({
    required String produceName,
    required String freshnessStatus,
    required String imagePath,
    double? confidence,
  }) async {
    String? savedImagePath;

    if (imagePath.isNotEmpty) {
      final source = File(imagePath);

      if (await source.exists()) {
        final documentsDirectory = await getApplicationDocumentsDirectory();

        final imagesDirectory = Directory(
          p.join(documentsDirectory.path, 'assessment_images'),
        );

        await imagesDirectory.create(recursive: true);

        final extension = p.extension(imagePath).isNotEmpty
            ? p.extension(imagePath)
            : '.jpg';

        final filename = '${DateTime.now().microsecondsSinceEpoch}$extension';

        final destination = File(p.join(imagesDirectory.path, filename));

        final copiedFile = await source.copy(destination.path);
        savedImagePath = copiedFile.path;
      }
    }

    try {
      return await DatabaseHelper.instance.insertAssessment({
        'produce_name': produceName,
        'freshness_status': freshnessStatus,
        'confidence': confidence,
        'image_path': savedImagePath,
        'assessed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      if (savedImagePath != null) {
        final file = File(savedImagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAssessments() {
    return DatabaseHelper.instance.getAssessments();
  }

  static Future<void> deleteAssessment(int id, String? imagePath) async {
    final deletedRows = await DatabaseHelper.instance.deleteAssessment(id);

    if (deletedRows > 0 && imagePath != null) {
      final file = File(imagePath);

      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
