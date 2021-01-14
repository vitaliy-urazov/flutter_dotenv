
import 'dart:async';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/src/parser.dart';

import 'errors.dart';

/// Loads environment variables from a `.env` file.
///
/// ## usage
///
/// Once you call [load], the top-level [env] map is available.
/// You may wish to prefix the import.
///
///     import 'package:dotenv/dotenv.dart' show load, env;
///
///     void main() {
///       load();
///       var x = env['foo'];
///       // ...
///     }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = const ['host', 'port'];
///     bool get hasEnv => isEveryDefined(_requiredEnvVars);
///
var _isInitialized = false;
var _envMap = Map<String, String>.from(Platform.environment);

/// A copy of [Platform.environment](dart:io) including variables loaded at runtime from a file.
Map<String, String> get env {
  if(!_isInitialized) {
    throw NotInitializedError();
  }
  return _envMap;
}

/// Clear [env] and optionally overwrite with a new writable copy of [Platform.environment](dart:io).
Map clean({ bool retainPlatformEnvironment = true}) => _envMap = Map.from(retainPlatformEnvironment ? Platform.environment : {});

/// Loads environment variables from the env file into a map
Future load({String fileName = '.env', Parser parser = const Parser(), bool includePlatformEnvironment = true}) async {
  clean(retainPlatformEnvironment: includePlatformEnvironment);
  final allLines = await _getEntriesFromFile(fileName);
  final envEntries = parser.parse(allLines);
  _envMap.addAll(envEntries);
  _isInitialized = true;
}

/// True if all supplied variables have nonempty value; false otherwise.
/// Differs from [containsKey](dart:core) by excluding null values.
/// Note [load] should be called first.
bool isEveryDefined(Iterable<String> vars) =>
    vars.every((k) => _envMap[k] != null && _envMap[k].isNotEmpty);


Future<List<String>> _getEntriesFromFile(String filename) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    var envString = await rootBundle.loadString(filename);
    if (envString.isEmpty) {
      throw EmptyEnvFileError();
    }
    return envString.split('\n');
  } on FlutterError {
    throw FileNotFoundError();
  }
}
