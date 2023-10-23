import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:console_bars/console_bars.dart';
import 'package:fvm/src/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class InstallCommand extends Command {
  // Initialize command with `name` and `description`
  @override
  final name = "install";

  @override
  final description = "Install a Flutter SDK version";

  @override
  Future<void> run() async {
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
      currentVersion =
          File(join(currentVersionDir.path, "version")).readAsStringSync();
      if (currentVersion == version) {
        print("Version $version is already installed");
        return;
      }
    }

    /// Check if the version to install is installed or not
    final toInstallVersionDir =
        Directory(join(kFlutterHome, "flutter_$version"));
    if (toInstallVersionDir.existsSync()) {
      print("Version $version is already installed installed");
      return;
    }

    downloadSdk(
      version,
      onDone: (file) async {
        /// Extract archive
        await extractFileToDisk(file.path, "flutter_$version");

        /// Move from [flutter_$version/flutter/*] to [flutter_$version/*]
        final copyResult = Process.runSync("xcopy", [
          join("flutter_$version", "flutter"),
          join("flutter_$version"),
          "/Y",
          "/E",
        ]);

        if (copyResult.exitCode != 0) {
          print(
              "Unable to copy ${join("flutter_$version", "flutter")} to ${join("flutter_$version")}");
          return;
        }

        /// Delete [flutter] directory
        Directory(join("flutter_$version", "flutter"))
            .deleteSync(recursive: true);
      },
    );
  }

  Future<void> downloadSdk(String version,
      {required void Function(File file) onDone}) async {
    String url =
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$version-stable.zip";

    // final response = await http.get(Uri.parse(url));
    /// Use a streamed response instead of a normal response
    final response =
        await http.Client().send(http.Request("GET", Uri.parse(url)));

    /// Display to the user that something went wrong
    /// cause the http status code is not OK
    if (response.statusCode != 200) {
      print("Something went wrong downloading the SDK");
      return;
    }

    /// Get file size from `contentLength` and set to 100 if not available
    final contentLength = response.contentLength ?? 100;

    /// Store how many bytes were downloaded
    var receivedBytes = 0;

    /// Create a reference to the downloadable file and open it to save
    final file = File(join(kFlutterHome, "flutter_$version.zip"));
    final sink = file.openWrite();

    /// Create the progress bar
    final progress = FillingBar(
      desc: "Downloading",
      // 1 MB = 1,024 KB
      // 1 KB = 1,024 bytes
      // => 1 MB = 1,024 x 1,024 = 1,048,576
      //     (contentLength / 1048576).toInt()
      total: contentLength ~/ 1048576,
      percentage: true,
      time: true,
    );

    response.stream.listen(
      (value) {
        /// Write the content of the remote file to the local file
        sink.add(value);
        receivedBytes += value.length;

        /// Update progress based on incrementing file size
        progress.update(receivedBytes ~/ 1048576);
      },
      onDone: () {
        /// Close the file when done and show download complete
        sink.close();
        stdout.writeln();
        onDone(file);
      },
    );
  }
}
