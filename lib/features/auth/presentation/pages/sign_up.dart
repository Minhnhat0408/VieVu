import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vn_travel_companion/core/utils/show_snackbar.dart';
import 'package:vn_travel_companion/core/utils/validators.dart';
import 'package:vn_travel_companion/core/widgets/loader.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_field.dart';
import 'package:vn_travel_companion/features/auth/presentation/widget/auth_submit_btn.dart';

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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          iconSize: 36,
          padding: const EdgeInsets.all(4),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Đăng ký tài khoản ', // Normal text
                  style: Theme.of(context).textTheme.headlineMedium,
                  children: [
                    TextSpan(
                      text: 'TravelCompanion', // Styled text
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Custom color
                        fontWeight: FontWeight.bold, // Optional: adjust weight
                      ),
                    ),
                    const TextSpan(
                      text: '.', // Trailing text
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              AuthField(
                hintText: 'Biệt danh',
                controller: nameController,
                validators: const [Validators.checkEmpty],
              ),
              const SizedBox(height: 15),
              AuthField(
                hintText: 'Email',
                controller: emailController,
                validators: const [Validators.checkEmail],
              ),
              const SizedBox(height: 15),
              AuthField(
                hintText: 'Mật khẩu',
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
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                "x Bao gồm một ký tự đặc biệt",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 30),
              AuthSubmitBtn(
                btnText: "Đăng ký",
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // call signUpWithEmailAndPassword
                    // context.read<AuthBloc>().add(AuthSignUp(
                    //     email: emailController.text.trim(),
                    //     password: passwordController.text.trim()));
                  }
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Navigator.push(context, LoginPage.route());
                  },
                  child: RichText(
                    text: TextSpan(
                        text: 'Đã có tài khoản? ',
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: 'Đăng nhập',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
