import 'package:easy_localization/easy_localization.dart';

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'auth.val_email_req'.tr();
  final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(value.trim())) return 'auth.val_email_invalid'.tr();
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'auth.val_pass_req'.tr();
  if (value.length < 8) return 'auth.val_pass_min'.tr();
  if (!RegExp(r'[a-zA-Z]').hasMatch(value))
    return 'auth.val_pass_letter'.tr();
  if (!RegExp(r'[0-9]').hasMatch(value))
    return 'auth.val_pass_number'.tr();
  return null;
}

String? validateLoginPassword(String? value) {
  if (value == null || value.isEmpty) return 'auth.val_pass_req'.tr();
  return null;
}

String? validateUsername(String? value) {
  if (value == null || value.trim().isEmpty) return 'auth.val_user_req'.tr();
  if (value.trim().length > 30) return 'auth.val_user_max'.tr();
  return null;
}
