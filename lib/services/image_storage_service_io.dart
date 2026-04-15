import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

export 'image_storage_service_stub.dart';

import 'image_storage_service_stub.dart';

class IoImageStorageService implements ImageStorageService {
  @override
  Future<List<String>> persistImagePaths(List<String> originalPaths) async {
    if (originalPaths.isEmpty) {
      return const [];
    }

    final imageDir = await _ensureImageDirectory();
    final persistedPaths = <String>[];

    for (final originalPath in originalPaths) {
      if (originalPath.startsWith('data:') || p.isWithin(imageDir.path, originalPath)) {
        persistedPaths.add(originalPath);
        continue;
      }

      final extension = p.extension(originalPath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(originalPath)}$extension';
      final targetPath = p.join(imageDir.path, fileName);
      await File(originalPath).copy(targetPath);
      persistedPaths.add(targetPath);
    }

    return persistedPaths;
  }

  Future<Directory> _ensureImageDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(docDir.path, 'entry_images'));
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }
}

ImageStorageService createImageStorageService() => IoImageStorageService();
