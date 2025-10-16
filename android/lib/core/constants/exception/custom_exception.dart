import 'error_code.dart'; // Import the ErrorCode enum

class CustomException implements Exception {
  final ErrorCode errorCode;

  CustomException(this.errorCode);

  @override
  String toString() => errorCode.message;
}
