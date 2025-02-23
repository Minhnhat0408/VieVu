import 'package:flutter/material.dart';
import 'package:vn_travel_companion/core/utils/validators.dart';

class AuthField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final List<String? Function(String?)> validators;
  final bool isObscureText;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validators = const [],
    this.isObscureText = false,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _isObscureText;

  @override
  void initState() {
    super.initState();
    _isObscureText = widget.isObscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscureText = !_isObscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelText: widget.hintText,
        suffixIcon: widget.isObscureText
            ? IconButton(
                icon: Icon(
                  _isObscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: _toggleObscureText,
              )
            : null,
      ),
      validator: Validators.combineValidators(widget.validators),
      obscureText: _isObscureText,
    );
  }
}
