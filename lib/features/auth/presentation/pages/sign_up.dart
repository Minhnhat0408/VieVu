import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vievu/core/layouts/custom_appbar.dart';
import 'package:vievu/core/utils/show_snackbar.dart';
import 'package:vievu/core/utils/validators.dart';
import 'package:vievu/core/common/widgets/loader.dart';
import 'package:vievu/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vievu/features/auth/presentation/widget/auth_field.dart';
import 'package:vievu/features/auth/presentation/widget/auth_submit_btn.dart';

class SignUpPage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const SignUpPage());
  }

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            showSnackbar(context, 'Có lỗi xảy ra', SnackBarState.error);
          }
          if (state is AuthSuccess) {
            showSnackbar(context, 'Đăng ký thành công');
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Đăng ký tài khoản mới ', // Normal text
                            style: Theme.of(context).textTheme.headlineMedium,
                            children: [
                              TextSpan(
                                text: 'VieVu', // Styled text
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary, // Custom color
                                  fontWeight: FontWeight
                                      .bold, // Optional: adjust weight
                                ),
                              ),
                              const TextSpan(
                                text: '.', // Trailing text
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuthField(
                          hintText: 'Họ và Tên',
                          controller: nameController,
                          validators: const [Validators.checkEmpty],
                        ),
                        const SizedBox(height: 24),
                        AuthField(
                          hintText: 'Email',
                          controller: emailController,
                          validators: const [Validators.checkEmail],
                        ),
                        const SizedBox(height: 24),
                        AuthField(
                          hintText: 'Mật khẩu',
                          controller: passwordController,
                          isObscureText: true,
                          validators: const [
                            Validators.checkPassword,
                            Validators.checkPasswordSpecialChar
                          ],
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        AuthSubmitBtn(
                          btnText: "Đăng ký",
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(AuthSignUp(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                    name: nameController.text.trim(),
                                  ));
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: RichText(
                              text: TextSpan(
                                  text: 'Đã có tài khoản? ',
                                  style: Theme.of(context).textTheme.titleSmall,
                                  children: [
                                    TextSpan(
                                      text: 'Đăng nhập',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "Hình thức khác",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 16,
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/google-icon.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Tiếp tục bằng Google',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
