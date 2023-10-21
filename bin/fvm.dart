import 'package:args/command_runner.dart';
import 'package:fvm/fvm.dart';
import 'package:fvm/src/commands/list.dart';

void main(List<String> args) {
  final runner = CommandRunner("fvm", "Flutter Version Manager")
    ..addCommand(UseCommand())
    ..addCommand(ListCommand());
  runner.run(args);
}
