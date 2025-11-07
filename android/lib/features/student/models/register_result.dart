class RegisterResult {
  final String title;
  final int advisorId;
  final String advisorName;
  final String? overviewFile;

  RegisterResult({
    required this.title,
    required this.advisorId,
    required this.advisorName,
    this.overviewFile,
  });
}
