import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/common/pages/introduction.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/password_forgot.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/reset_password.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/log_in.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/send_email_reset.dart';
import 'package:vn_travel_companion/features/auth/presentation/pages/sign_up.dart';
import 'package:vn_travel_companion/features/settings/presentation/pages/settings.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/settings': (context) => const SettingsPage(),
  '/send-email-reset': (context) => const SendEmailResetPage(),
  '/login': (context) => const LogInPage(),
  '/sign-up': (context) => const SignUpPage(),
  '/reset-password': (context) => const ResetPasswordPage(),
  '/password-forgot': (context) => const PasswordForgotPage(),
  
};
