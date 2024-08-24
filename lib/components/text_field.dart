
import 'package:flutter/material.dart';

class TextFieldForm extends StatelessWidget {
  const TextFieldForm({
    super.key,
    required TextEditingController controller,
    this.keyboardType = TextInputType.text,
    this.labelText = '',
    this.obscureText = false, 

  }) : _emailController = controller, super();

  final TextEditingController _emailController;
  final TextInputType keyboardType;
  final String labelText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      maxLines: 1,
      autofocus: true,
      cursorColor: Colors.black54,
      obscureText: obscureText,
      controller: _emailController,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1,
            ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1,
            ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    ),
    validator: (value){
      if(value == null || value.isEmpty){
        return 'Por favor, ingrese su correo electrónico';
      }
      return null;
    },
    );
  }
} 

