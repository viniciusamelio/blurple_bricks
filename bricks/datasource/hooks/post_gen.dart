import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:mason/mason.dart';

void run(HookContext context) async {
  final uuidSpinner = CliSpin(
    text: "Installing dependencies",
    spinner: CliSpinners.bluePulse,
  );
  uuidSpinner.info();
  await Process.run("flutter", ["pub", "add", "uuid"]);
  uuidSpinner.success("UUID installed ✅✅");
  if (!context.vars["couchbase"]) {
    uuidSpinner.success("Couchbase installation skipped ⏩⏩");
    await Process.run(
      "rm",
      ["-R", "lib/core/database/couch_database"],
      runInShell: true,
    );
    return;
  }
  uuidSpinner.info("Installing couchbase packages");
  await Process.runSync(
    "flutter",
    ["pub", "add", "cbl_flutter", "cbl", "cbl_flutter_ce"],
    runInShell: true,
  );
  uuidSpinner.success("Couchbase Lite installed ✅✅");
}
