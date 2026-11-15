import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('../docs/assets/timeit/Screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      stdout.writeln('Saved ${file.path} (${bytes.length} bytes)');
      return true;
    },
  );
}
