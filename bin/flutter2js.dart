import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';

Future main(List<String> args) async {
  final runner =
  new CommandRunner("flutter2js", "Flutter-to-browser project compiler.");
  runner.addCommand(new CreateCommand());
  return runner.run(args);
}

class CreateCommand extends Command {
  final ProjectOptions options = new ProjectOptions();

  get name => "create";

  get description => "Compiles a Flutter project to a web project";

  CreateCommand() {
    this.argParser.addOption("app-uri", defaultsTo: "path/to/your/app", callback: (String s) {
      options.importedUri = Uri.parse(s);
    });
    this.argParser.addOption("app-name", defaultsTo: "your_flutter_app", callback: (String s) {
      options.importedName = s;
    });
    this.argParser.addOption("app-main", defaultsTo: "main.dart", callback: (String s) {
      options.importedMain = s;
    });
  }

  @override
  void run() {
    // Parse remaining arguments
    final rest = this.argResults.rest;
    if (rest.length != 1) {
      print("Usage: dart2js ${this.name} [project_name]");
      return;
    }
    options.name = rest[0];
    final resultUri = Directory.current.absolute.uri.resolve(options.name);
    options.importedName ??= "your_app";
    if (options.importedUri==null) {
      options.importedUri = Uri.parse("path/to/your_app");
    } else if (options.importedUri.isAbsolute == false) {
      options.importedUri = resultUri.resolveUri(Directory.current.absolute.uri.resolveUri(options.importedUri));
    }
    options.importedUri ??= Uri.parse("path/to/your_app");
    options.importedMain ??= "main.dart";
    print("Creating project '${options.name}'.");
    final directory = new Directory.fromUri(resultUri);
    if (directory.existsSync()) {
      print("Directory '${directory.uri}' already exists.");
      return;
    }
    directory.createSync();
    final fileMap = new ProjectGenerator(options).buildFileMap();
    for (var filePath in fileMap.keys.toList()..sort()) {
      final file = new File.fromUri(directory.uri.resolve(filePath));
      file.createSync(recursive: true);
      file.writeAsStringSync(fileMap[filePath]);
    }
    print("Ok.");
    print("");
    print("Running 'pub get'...");
    Process.runSync("pub", ["get"], workingDirectory: directory.path);
    print("");
    final packagesFile = new File.fromUri(directory.uri.resolve(".packages"));
    if (!packagesFile.existsSync()) {
      print("Could not find '.packages'.");
      return;
    }
    // TODO: Customize 'dependency_overrides' based on used package list.
  }
}

class ProjectGenerator {
  final ProjectOptions options;

  ProjectGenerator(this.options);

  Map<String, String> buildFileMap() {
    final result = <String, String>{};
    result["pubspec.yaml"] = buildPubspec();
    result["web/index.html"] = buildHtml();
    result["web/index.dart"] = buildMain();
    result["test/main_test.dart"] = buildMainTest();
    result["dart_test.yaml"] = buildTestSettings();
    return result;
  }

  String buildHtml() {
    return """
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
    <script defer src="index.dart" type="application/dart"></script>
    <script defer src="packages/browser/dart.js"></script>
</head>
<body>
</body>
</html>
""";
  }

  String buildMain() {
    return """
import \"package:${options.importedName}/main.dart\" as app;

void main() {
  app.main();
}
""";
  }

  String buildTestSettings() {
    return """
platforms:
- chrome
""";
  }

  String buildMainTest() {
    return """
void main() {
  // Do your testing here
}
""";
  }

  String buildPubspec() {
    final sb = new StringBuffer();
    sb.write("""
name: ${options.name}

environment:
  sdk: '>=1.20.1 <2.0.0'

dependencies:
  ${options.importedName}:
""");
    // Manual path or repository
    var uri = options.importedUri;
    if (uri.scheme == null || uri.scheme=="" || uri.scheme == "file") {
      sb.write("    path: \"${uri.path}\"\n");
    } else {
      sb.write("    git:\n");
      sb.write("      url: \"${uri}\"\n");
    }
    sb.write("""

dev_dependencies:
  browser: ^0.10.0
  dart_to_js_script_rewriter: ^1.0.3

dependency_overrides:
  #
  # Browser-versions of Flutter packages
  #
  flutter:
    git:
      url: https://github.com/jban332/flutter2js_packages
      path: packages/flutter
  flutter_localizations:
    git:
      url: https://github.com/jban332/flutter2js_packages
      path: packages/flutter_localizations
  flutter_test:
    git:
      url: https://github.com/jban332/flutter2js_packages
      path: packages/flutter_test

transformers:
- dart_to_js_script_rewriter
- \$dart2js:
    checked: true
""");
    return sb.toString();
  }
}

class ProjectOptions {
  String name;
  String importedName;
  Uri importedUri;
  String importedMain;
}