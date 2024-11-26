class Validators {
  static String? checkEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập trường này';
    }
    return null;
  }

  static String? checkEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? checkPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập password';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải chứa ít nhất 8 ký tự';
    }
    return null;
  }

  // check password contain at least one special character
  static String? checkPasswordSpecialChar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập password';
    }
    final specialCharRegex = RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]');
    if (!specialCharRegex.hasMatch(value)) {
      return 'Mật khẩu phải chứa ít nhất 1 ký tự đặc biệt';
    }
    return null;
  }

  static String? Function(String?) combineValidators(
      List<String? Function(String?)> validators) {
    return (value) {
      for (var validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error; // Return the first validation error
        }
      }
      return null; // All validators passed
    };
  }
}
