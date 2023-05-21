import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) async {
  context.logger.info("Adding Dio as dependency");

  await Process.run(
    "flutter",
    ["pub add", "dio"],
  );
}
