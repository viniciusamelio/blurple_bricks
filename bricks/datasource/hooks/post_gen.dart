import 'dart:io';

import 'package:cli_spin/cli_spin.dart';
import 'package:mason/mason.dart';
import 'package:slug/slug.dart';

void run(HookContext context) async {
  final uuidSlug = Slug(slugStyle: SlugStyle.toggle7);
  final uuidProgress = uuidSlug.progress("Installing UUID package ");
  await Process.run("flutter", ["pub", "add", "uuid"]);
  uuidProgress.finish(
    message: "UUID installed ",
    showTiming: true,
  );
  if (!context.vars["couchbase"]) {
    CliSpin().info("Couchbase installation skipped ⏩⏩");
    await Process.run(
      "rm",
      ["-R", "lib/core/database/couch_database"],
      runInShell: true,
    );
    return;
  }
  final couchbaseSlug = Slug(slugStyle: SlugStyle.toggle7);
  final couchbaseProgress =
      couchbaseSlug.progress("Installing Couchbase Lite package ");
  await Process.runSync(
    "flutter",
    ["pub", "add", "cbl_flutter", "cbl", "cbl_flutter_ce"],
    runInShell: true,
  );
  couchbaseProgress.finish(
    message: "Couchbase Lite installed",
    showTiming: true,
  );
}
