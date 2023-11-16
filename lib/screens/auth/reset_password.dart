// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

final _firebaseAuth = FirebaseAuth.instance;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _firstTime = true;
  String _email = '';
  final _emailController = TextEditingController();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: _email).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent.'),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for that email.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Try again.'),
          ),
        );
      }
    }
  }

  InputDecoration _textFieldDecoration({required String labelText}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary, width: 2.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.error, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.error, width: 2.0),
      ),
      labelText: labelText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.secondary, size: 15),
              Text(
                'Back',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/startup_logo.png',
                  width: 150,
                ),
                const SizedBox(height: 10),
                Text(
                  'Password Reset',
                  style: GoogleFonts.macondo(
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: _emailController,
                    validator: (value) => validateEmail(value, _firstTime),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onSaved: (newValue) {
                      _email = newValue!;
                    },
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: _textFieldDecoration(labelText: 'Email'),
                  ),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _firstTime = false;
                    });
                    _submit();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text('Send Reset Email'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? validateEmail(String? value, bool firstTime) {
  if (!firstTime && (value == null || value.isEmpty)) {
    return 'Email is required';
  }
  const String regexPattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(regexPattern);
  if (!firstTime && !regex.hasMatch(value!)) {
    return 'Invalid Email';
  }
  return null;
}
