String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required';
  final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Minimum 8 characters';
  if (!RegExp(r'[a-zA-Z]').hasMatch(value))
    return 'Must contain at least one letter';
  if (!RegExp(r'[0-9]').hasMatch(value))
    return 'Must contain at least one number';
  return null;
}

String? validateLoginPassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.trim().isEmpty) return 'Username is required';
  if (value.trim().length > 30) return 'Maximum 30 characters';
  return null;
}
