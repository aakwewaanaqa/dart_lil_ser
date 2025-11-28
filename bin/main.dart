import 'package:args/args.dart';

import 'package:dart_lil_ser/commands/file.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart dart_lil_ser.dart <flags> [arguments]');
  print(argParser.usage);
}

Future<void> main(List<String> arguments) async {
  final argParser = buildParser();
  final fileCmd = FileCmd();
  argParser.addCommand('file', fileCmd.argParser);

  try {
    final results = argParser.parse(arguments);

    if (results.command?.name == 'file') {
      await fileCmd.execute(results.command!);
      return;
    }

    if (results['help'] as bool) {
      printUsage(argParser);
      return;
    }

    if (results['version'] as bool) {
      print('dart_lil_ser version: $version');
      return;
    }

    print('No command specified. Use --help for more info.');
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
  } catch (e) {
    print('Error: $e');
  }
}
