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
    /// Get not parsed args
    final rest = argResults?.rest ?? [];
    if (rest.isEmpty) {
      print("Missing version");
      return;
    }

    /// Get version to install from args
    final version = rest.first;

    /// Initialize `currentVersion` to be used later
    String currentVersion = "";

    /// Set current working directory to flutter_home
    /// to prevent `OS Error: The system cannot move the file to a different disk drive.`
    Directory.current = Directory(kFlutterHome);

    /// Check if current Flutter version is the one to install
    final currentVersionDir = Directory(join(kFlutterHome, "flutter"));
    if (currentVersionDir.existsSync()) {
      currentVersion = File(join(currentVersionDir.path, "version")).readAsStringSync();
      if (currentVersion == version) {
        print("Version $version is already installed");
        return;
      }
    }

    /// Check if the version to install is installed or not
    final toInstallVersionDir = Directory(join(kFlutterHome, "flutter_$version"));
    if (toInstallVersionDir.existsSync()) {
      print("Version $version is already installed installed");
      return;
    }

    // TODO: install the sdk
  }
}
