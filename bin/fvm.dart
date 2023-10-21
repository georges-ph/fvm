import 'package:args/command_runner.dart';
import 'package:fvm/fvm.dart';

void main(List<String> args) {
  final runner = CommandRunner("fvm", "Flutter Version Manager")
    ..addCommand(UseCommand());
  runner.run(args);
}
