import 'dart:io';

void main() {
  Process.runSync("pub", ["build"], workingDirectory: "examples/hello-world-browser");
  Process.runSync("pub", ["build"], workingDirectory: "examples/stocks-browser");
  Process.runSync("pub", ["build"], workingDirectory: "examples/gallery-browser");
}