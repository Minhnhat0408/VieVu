import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vievu/core/common/widgets/loader.dart';
import 'package:vievu/core/layouts/custom_appbar.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/core/utils/validators.dart';
import 'package:vievu/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vievu/features/auth/presentation/widget/auth_field.dart';
import 'package:vievu/features/auth/presentation/widget/auth_submit_btn.dart';

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
            _emailSentAnnouncer(context);
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
                          }),
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

  Future<void> _emailSentAnnouncer(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          title: Text('Email đã được gửi!!',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontSize: 20)),
          icon: Icon(
            Icons.email,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          content: const Text(
            'Vui lòng kiểm tra hòm thư của bạn để thay đổi mật khẩu.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
