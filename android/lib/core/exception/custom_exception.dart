import 'package:GPMS/core/exception/error_code.dart'; // Import the ErrorCode enum

class CustomException implements Exception {
  final ErrorCode errorCode;
  final String? serverMessage; // optional raw message from backend

  CustomException(this.errorCode, {this.serverMessage});

  @override
  String toString() => serverMessage ?? errorCode.message;
}
