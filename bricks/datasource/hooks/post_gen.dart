import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) async {
  if (!context.vars["couchbase"]) {
    context.logger.success(
      "Couchbase installation skipped &&  Couchbase files removed",
    );
    await Process.runSync("rm", ["-R", "core/databse/couch_database"]);
    return;
  }
  context.logger.info("Adding couchbase as dependency ⏳⏳");
  await Process.runSync(
    "flutter",
    ["pub", "add", "cbl_flutter", "cbl", "cbl_flutter_ce"],
  );
  context.logger.success("Couchbase dependencies added ✅✅");
}
