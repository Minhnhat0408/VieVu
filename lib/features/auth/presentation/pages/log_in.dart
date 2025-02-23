import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/validators.dart';
import 'package:vn_travel_companion/core/common/widgets/loader.dart';
import 'package:vn_travel_companion/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_field.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_submit_btn.dart';

class LogInPage extends StatefulWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const LogInPage());
  }

  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
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
            showSnackbar(
                context, 'Email hoặc mật khẩu không đúng', SnackBarState.error);
          }
          if (state is AuthSuccess) {
            showSnackbar(context, 'Đăng nhập thành công');
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
                            text: 'Chào mừng đến với ', // Normal text
                            style: Theme.of(context).textTheme.headlineMedium,
                            children: [
                              TextSpan(
                                text: 'TravelCompanion', // Styled text
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
                        Text(
                          'Hãy nhập email và mật khẩu của bạn để đăng nhập',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/password-forgot');
                          },
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AuthSubmitBtn(
                          btnText: "Đăng Nhập",
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    AuthLogin(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    ),
                                  );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/sign-up');
                            },
                            child: RichText(
                              text: TextSpan(
                                  text: 'Chưa có tài khoản? ',
                                  style: Theme.of(context).textTheme.titleSmall,
                                  children: [
                                    TextSpan(
                                      text: 'Đăng ký',
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
                        const SizedBox(height: 28),
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
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        OutlinedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLoginWithGoogle());
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 14,
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
