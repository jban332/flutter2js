import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

abstract class File {
  String get path;
  Uri get uri;
  Future<Uint8List> readAsBytes();
  Future<String> readAsString() async => const Utf8Decoder().convert(await readAsBytes());
}

class Platform {
  static String get localeName => "en-US";
  static String get operatingSystem => "android";
  static String get pathSeparator => "/";
  static String get resolvedExecutable => "/main.dart";
  static bool get isAndroid => true;
  static bool get isFuchsia => false;
  static bool get isIOS => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
}

void exit(int status) {
  print("Exiting the app.");
}