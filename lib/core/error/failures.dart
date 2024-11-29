class Failure {
  final String message;

  Failure([this.message = 'An error occurred.']);

  @override
  String toString() => message;
}
