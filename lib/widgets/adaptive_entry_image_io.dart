import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

Widget buildAdaptiveEntryImage({
  required String imagePath,
  required double width,
  required double height,
  required BoxFit fit,
  Widget? errorChild,
}) {
  if (imagePath.startsWith('data:')) {
    final bytes = _decodeDataUri(imagePath);
    if (bytes == null) {
      return errorChild ?? const SizedBox.shrink();
    }
    return Image.memory(
      bytes,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => errorChild ?? const SizedBox.shrink(),
    );
  }

  return Image.file(
    File(imagePath),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => errorChild ?? const SizedBox.shrink(),
  );
}

Uint8List? _decodeDataUri(String dataUri) {
  final commaIndex = dataUri.indexOf(',');
  if (commaIndex < 0) {
    return null;
  }
  return Uint8List.fromList(base64Decode(dataUri.substring(commaIndex + 1)));
}
