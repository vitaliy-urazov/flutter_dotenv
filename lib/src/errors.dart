
import 'dart:async';
import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import '../flutter_dotenv.dart';

class NotInitializedError extends Error {}
class ValueNotFound extends Error {}
class FileNotFoundError extends Error {}
class EmptyEnvFileError extends Error {}