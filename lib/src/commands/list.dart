import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fvm/src/constants.dart';
import 'package:path/path.dart';

class ListCommand extends Command {
  /// Initialize command with [name], [description] and [aliases]
  @override
  final name = "list";

  @override
  final description = "List all installed versions";

  @override
  final aliases = ['l'];

  ListCommand();

  @override
  void run() {
    // Check if fvm was used by checking if its directory exists
    final currentVersionDir = Directory(join(kFlutterHome, "flutter"));
    if (!currentVersionDir.existsSync()) {
      print("No versions installed");
      return;
    }

// Get current version
    final currentVersion =
        File(join(currentVersionDir.path, "version")).readAsStringSync();

    // Get versions installed from last part of directory name
    final versionsList = Directory(kFlutterHome)
        .listSync()
        .map((e) => e.path.split(Platform.pathSeparator).last)
        .where((element) => element.startsWith("flutter_"))
        .map((e) => e.split("_").last)
        .toList();

    // Emphasize current version and sort list
    versionsList.add("$currentVersion *current*");
    versionsList.sort();

    // Display versions list
    print("Installed versions:");
    for (var version in versionsList) {
      print("- $version");
    }
  }
}
