import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/common/widgets/loader.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/validators.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_field.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_submit_btn.dart';

class SendEmailResetPage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const SendEmailResetPage());
  }

  const SendEmailResetPage({super.key});

  @override
  State<SendEmailResetPage> createState() => _SendEmailResetPageState();
}

class _SendEmailResetPageState extends State<SendEmailResetPage> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackbar(context, 'Gửi email thất bại', SnackBarState.error);
          }
          if (state is AuthSendResetPasswordEmailSuccess) {
            showSnackbar(
                context,
                'Email xác nhận đã được gửi đến hòm thư của bạn',
                SnackBarState.success);
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
                          text:
                              'Vui lòng nhập email cần thay đổi mật khẩu', // Normal text
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 60),
                      AuthField(
                        hintText: 'Email',
                        controller: emailController,
                        validators: const [Validators.checkEmail],
                      ),
                      const SizedBox(height: 30),
                      AuthSubmitBtn(
                        btnText: "Xác nhận",
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthSendResetPasswordEmail(
                                    email: emailController.text,
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
