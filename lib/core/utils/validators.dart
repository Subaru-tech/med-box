class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateNoticeTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.length > 50) {
      return 'Title must be less than 50 characters';
    }
    return null;
  }

  static String? validateNoticeMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.length > 200) {
      return 'Message must be less than 200 characters';
    }
    return null;
  }

  static String? validateDeviceId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Device ID is required';
    }
    return null;
  }
}
