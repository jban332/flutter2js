import 'package:logging/logging.dart';

const _undefined = const _Undefined();

final Logger engineLogger = () {
  //recordStackTraceAtLevel = Level.ALL;
  final logger = Logger.root;
  logger.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}\n${rec.stackTrace}');
  });
  return logger;
}();

int _nextId = 0;
final bool _isLogging = engineLogger.level <= Level.FINE;

String allocateDebugName(String className) {
  if (!_isLogging) {
    return "";
  }
  return "#${_nextId++}:${className}";
}

StackTrace getStackTrace() {
  if (recordStackTraceAtLevel<=Level.FINE) {
    return StackTrace.current;
  }
  return null;
}


void logConstructor(HasDebugName value, {Object arg0:_undefined, Object arg1:_undefined, Object arg2:_undefined}) {
  if (!_isLogging) {
    return;
  }
  logMethod(value, "", arg0:arg0, arg1:arg1, arg2:arg2);
}

void logMethod(HasDebugName value, String name, {Object arg0:_undefined, Object arg1:_undefined, Object arg2:_undefined, Object result:_undefined}) {
  if (!_isLogging) {
    return;
  }
  final sb = new StringBuffer();
  sb.write(value.debugName);
  if (name!="") {
    sb.write(".");
    sb.write(name);
  }
  sb.write("(");
  if (!identical(arg0, _undefined)) {
    sb.write(arg0);
    if (!identical(arg1, _undefined)) {
      sb.write(", ${arg1}");
      if (!identical(arg2, _undefined)) {
        sb.write(", ${arg2}");
      }
    }
  }
  sb.write(")");
  if (!identical(result, _undefined)) {
    sb.write(" -> ");
    sb.write(result);
  }
  engineLogger.fine(sb.toString(), null, getStackTrace());
}

void logStaticMethod(String name, {Object arg0:_undefined, Object arg1:_undefined, Object arg2:_undefined, Object result:_undefined}) {
  if (!_isLogging) {
    return;
  }
  final sb = new StringBuffer("${name}(");
  if (!identical(arg0, _undefined)) {
    sb.write(arg0);
    if (!identical(arg1, _undefined)) {
      sb.write(", ${arg1}");
      if (!identical(arg2, _undefined)) {
        sb.write(", ${arg2}");
      }
    }
  }
  sb.write(")");
  if (!identical(result, _undefined)) {
    sb.write(" -> ");
    sb.write(result);
  }
  engineLogger.fine(sb.toString(), null, getStackTrace());
}

abstract class HasDebugName {
  String get debugName;
  String toString() => debugName;
}

class _Undefined{
  const _Undefined();
}