import 'package:flutter/widgets.dart';

import 'src/app.dart';

export 'src/app.dart' show RedSiteSocialApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RedSiteSocialApp());
}
