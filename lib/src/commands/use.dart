import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fvm/src/constants.dart';
import 'package:path/path.dart';

class UseCommand extends Command {
  /// Initialize command with [name] and [description]
  @override
  final name = "use";

  @override
  final description = "Switch to the specified version";

  UseCommand();

  @override
  void run() {
    /// Get not parsed args
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      print("Missing version");
      return;
    }

    /// Get version to be used from args
    final version = rest.first;

    /// Initialize `currentVersion` to be used later
    String currentVersion = "";

    /// Set current working directory to flutter_home
    /// to prevent `OS Error: The system cannot move the file to a different disk drive.`
    Directory.current = Directory(kFlutterHome);

    /// Get current version of flutter and check if it's being used or not
    final currentVersionDir = Directory(join(kFlutterHome, "flutter"));
    if (currentVersionDir.existsSync()) {
      currentVersion =
          File(join(currentVersionDir.path, "version")).readAsStringSync();
      if (currentVersion == version) {
        print("Version $version is already in use");
        return;
      }
    }

    /// Check if the version to be used is installed or not
    final toUseVersionDir = Directory(join(kFlutterHome, "flutter_$version"));
    if (!toUseVersionDir.existsSync()) {
      print("Version $version is not installed");
      return;
    }

    /// Switch between versions by renaming the folders
    if (currentVersion.isNotEmpty) {
      currentVersionDir.renameSync("flutter_$currentVersion");
    }
    toUseVersionDir.renameSync("flutter");

    if (currentVersion.isNotEmpty) {
      print("Switched from version $currentVersion to version $version");
    } else {
      print("Now using version $version");
    }
  }
}
