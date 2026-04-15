abstract class ImageStorageService {
  Future<List<String>> persistImagePaths(List<String> originalPaths);
}

ImageStorageService createImageStorageService() {
  throw UnsupportedError('Unsupported platform');
}
