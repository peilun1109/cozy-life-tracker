import 'package:flutter/widgets.dart';

Widget buildAdaptiveEntryImage({
  required String imagePath,
  required double width,
  required double height,
  required BoxFit fit,
  Widget? errorChild,
}) {
  return errorChild ?? const SizedBox.shrink();
}
