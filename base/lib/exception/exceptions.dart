

import 'package:base/resources/strings.dart';

class HandledHttpException implements Exception {

  int errorCode;

  Object errorBody;

  HandledHttpException(this.errorCode, this.errorBody);

}

class ConnectionException implements Exception {

  final String message = Strings.NETWORK_ERROR_DESCRIPTION;

  ConnectionException();

  String toString() => "FormatException: $message";
}

class ManuallyException implements Exception {

  final String message;

  ManuallyException(this.message);

  String toString() => "FormatException: $message";
}