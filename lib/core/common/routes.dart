import 'package:flutter/material.dart';
import 'package:vievu/features/auth/presentation/pages/password_forgot.dart';
import 'package:vievu/features/auth/presentation/pages/reset_password.dart';
import 'package:vievu/features/auth/presentation/pages/log_in.dart';
import 'package:vievu/features/auth/presentation/pages/send_email_reset.dart';
import 'package:vievu/features/auth/presentation/pages/sign_up.dart';

Map<String, Widget Function(BuildContext)> routes = {
  // '/settings': (context) => const SettingsPage(),
  '/send-email-reset': (context) => const SendEmailResetPage(),
  '/login': (context) => const LogInPage(),
  '/sign-up': (context) => const SignUpPage(),
  '/reset-password': (context) => const ResetPasswordPage(),
  '/password-forgot': (context) => const PasswordForgotPage(),
};
