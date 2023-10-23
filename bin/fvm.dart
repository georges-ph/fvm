import 'package:args/command_runner.dart';
import 'package:fvm/fvm.dart';

void main(List<String> args) {
  final runner = CommandRunner("fvm", "Flutter Version Manager")
    ..addCommand(UseCommand())
    ..addCommand(ListCommand())
    ..addCommand(InstallCommand());
  runner.run(args);
}
