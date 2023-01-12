class ApiException implements Exception {
  String message;

  ApiException(this.message);

  @override
  String toString() {
    if (message == null) return "Exception";
    return "Error: $message";
  }
}

class ApiNotFoundException extends ApiException {
  ApiNotFoundException(String message) : super(message);
}

class ApiAuthenticationException extends ApiException {
  ApiAuthenticationException(String message) : super(message);
}

class ApiAuthorizationException extends ApiException {
  ApiAuthorizationException(String message) : super(message);
}
