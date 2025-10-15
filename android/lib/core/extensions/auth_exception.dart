import 'error_code.dart'; // Import the ErrorCode enum

class AuthException implements Exception {
  final ErrorCode errorCode;

  AuthException(this.errorCode);

  @override
  String toString() => errorCode.message;
}
