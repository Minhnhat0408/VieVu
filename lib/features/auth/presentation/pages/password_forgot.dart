import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/layouts/custom_appbar.dart';

class PasswordForgotPage extends StatelessWidget {
  static route() {
    return MaterialPageRoute(builder: (context) => const PasswordForgotPage());
  }

  const PasswordForgotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppbar(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: 'Chọn 1 phương thức để khôi phục mật khẩu', // Normal text
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/send-email-reset');
                },
                icon: const Icon(
                  Icons.email,
                  size: 30,
                  color: Color.fromRGBO(239, 154, 154, 1),
                ),
                label: const Center(
                    child: Text(
                  "Tiếp tục với email",
                  style: TextStyle(fontWeight: FontWeight.w500),
                )), // Text in the middle
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 24, top: 18, bottom: 18, right: 54),
                  textStyle: const TextStyle(fontSize: 20),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    // Customizes the border
                    width: 2.0, // Border thickness
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Handle button press
                },
                iconAlignment: IconAlignment.start,
                icon: const Icon(Icons.phone,
                    size: 30, color: Color.fromRGBO(77, 154, 164, 1)),
                // Icon on the left
                label: const Center(
                  child: Text(
                    "Tiếp tục với số điện thoại",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ), // Text in the middle
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 24, top: 18, bottom: 18, right: 54),
                  textStyle: const TextStyle(fontSize: 20),
                  side: BorderSide(
                    // Customizes the border
                    color: Theme.of(context).colorScheme.outline,
                    width: 2.0, // Border thickness
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
