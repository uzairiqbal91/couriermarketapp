class Validators {
  static String? validateNotNull(value) => value == null ? 'This field is required!' : null;

  static String? validateNotEmpty(String? value) => value!.isEmpty ? 'This field is required!' : null;

  static String? validateRequired(dynamic value) {
    final errMsg = 'This field is required!';
    if (value == null) return errMsg;
    if (value is String && value.isEmpty) return errMsg;
    return null;
  }

  static String? noop(dynamic) => null;

  static String? validateNoSpace(String value) => value.contains(' ') ? 'This field should have no spaces!' : null;

  static String _formatErrorList(List<String> errors) => errors.join('\n');

  static Function validateIf(bool condition, Function validator) => condition ? validator : Validators.noop;

  static multiValidationBuilder(List validators, [fastFail = true]) {
    return (value) {
      List<String> responses = [];

      for (final validator in validators) {
        var validationResponse = validator(value);
        if (validationResponse != null) {
          responses.add(validationResponse);
          if (fastFail == true) return _formatErrorList(responses);
        }
      }

      return responses.length == 0 ? null : _formatErrorList(responses);
    };
  }
}
