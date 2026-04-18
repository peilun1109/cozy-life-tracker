import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_web_v4.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_TW');
  runApp(const ShiguangjiWebApp());
}
