export 'image_storage_service_stub.dart';

import 'image_storage_service_stub.dart';

class WebImageStorageService implements ImageStorageService {
  @override
  Future<List<String>> persistImagePaths(List<String> originalPaths) async {
    return originalPaths;
  }
}

ImageStorageService createImageStorageService() => WebImageStorageService();
