import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) async {
  await Process.run("flutter", ["pub", "add", "uuid"]);
  if (!context.vars["couchbase"]) {
    context.logger.success(
      "Couchbase installation skipped &&  Couchbase files removed",
    );
    await Process.run(
      "rm",
      ["-R", "core/databse/couch_database"],
      runInShell: true,
    );
    return;
  }
  context.logger.info("Adding couchbase as dependency ⏳⏳");
  await Process.runSync(
    "flutter",
    ["pub", "add", "cbl_flutter", "cbl", "cbl_flutter_ce"],
    runInShell: true,
  );
  context.logger.success("Couchbase dependencies added ✅✅");
}
