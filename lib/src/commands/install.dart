import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:fvm/src/constants.dart';
import 'package:path/path.dart';

class InstallCommand extends Command {
  // Initialize command with `name` and `description`
  @override
  final name = "install";

  @override
  final description = "Install a Flutter SDK version";

  @override
  void run() {
    // Get not parsed args
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      print("Missing version");
      return;
    }

    // Check if only one argument is passed which is the version
    if (rest.length > 1) {
      print("Too many arguments");
      return;
    }

    // Get version to install from args
    final version = rest.first;

    // Set current working directory to flutter_home
    Directory.current = Directory(kFlutterHome);

    // Check if fvm was used by checking if its directory exists
    final currentVersionDir = Directory(join(kFlutterHome, "flutter"));
    if (!currentVersionDir.existsSync()) {
      print("No versions installed");
      return;
    }

    // Get current version of flutter and check if it's already installed or not
    final currentVersion =
        File(join(currentVersionDir.path, "version")).readAsStringSync();
    if (currentVersion == version) {
      print("Version $version is already installed");
      return;
    }

    // Check if the version to install is already insalled or not but not in use
    final tobeUsedVersionDir =
        Directory(join(kFlutterHome, "flutter_$version"));
    if (tobeUsedVersionDir.existsSync()) {
      print("Version $version is already installed");
      return;
    }

    // TODO: install the sdk
  }
}
