import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/common/widgets/loader.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/validators.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_field.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_submit_btn.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/features/settings/presentation/pages/settings.dart';

class ResetPasswordPage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const ResetPasswordPage());
  }

  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is AuthFailure) {
            showSnackbar(
                context, 'Đặt lại mật khẩu thất bại', SnackBarState.error);
          }
          if (state is AuthUpdatePasswordSuccess) {
            showSnackbar(context, 'Mật khẩu của bạn đã được cập nhật',
                SnackBarState.success);
            Navigator.pushAndRemoveUntil(
                context, SettingsPage.route(), (route) => false);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Nhập mật khẩu mới của bạn', // Normal text
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 30),
                      AuthField(
                        hintText: 'Password',
                        controller: passwordController,
                        isObscureText: true,
                        validators: const [
                          Validators.checkPassword,
                          Validators.checkPasswordSpecialChar
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "x Ít nhất 8 ký tự",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      Text(
                        "x Bao gồm một ký tự đặc biệt",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      const SizedBox(height: 30),
                      AuthSubmitBtn(
                        btnText: "Xác nhận",
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthUpdatePassword(
                                    password: passwordController.text,
                                  ),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (state is AuthLoading) const Positioned.fill(child: Loader())
            ],
          );
        },
      ),
    );
  }
}
