import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

final _firebaseAuth = FirebaseAuth.instance;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwVerifyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _firstTime = true;
  bool _isLoading = false;
  String _email = '';
  String _userName = '';
  String _password = '';
  String _phoneNumber = '';
  String? _signUpState;
  File? _profileImage;

  void _pickImage({required ImageSource source}) async {
    await ImagePicker()
        .pickImage(
            source: source,
            imageQuality: 75,
            maxWidth: 480,
            preferredCameraDevice: CameraDevice.rear)
        .then((value) {
      if (value != null) {
        setState(() {
          _profileImage = File(value.path);
        });
      }
    });
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();
    String? verifyPassword = await showTextDialog(
        context: context,
        title: "Re-enter Password",
        obscure: true,
        hintText: "Password",
        labelText: "Verify Password",
        cancelText: "Cancel",
        okText: "OK");
    if (verifyPassword == null || verifyPassword != _password) {
      setState(() {
        _signUpState = "Passwords do not match";
      });
      return;
    }
    if (_profileImage == null) {
      setState(() {
        _signUpState = "Please select a profile image";
      });
      return;
    }
    setState(() {
      _signUpState = 'Signing up...';
      _isLoading = true;
    });
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      ).then((value) async {
        setState(() {
          _signUpState = "Creating Profile...";
        });
        await FirebaseStorage.instance
            .ref('profile_images/${value.user!.uid}.jpg')
            .putFile(_profileImage!);
        String downloadURL = await FirebaseStorage.instance
            .ref('profile_images/${value.user!.uid}.jpg')
            .getDownloadURL();
        await FirebaseFirestore.instance
            .collection('Customer')
            .doc(value.user!.uid)
            .set({
          'username': _userName,
          'phone_number': _phoneNumber,
          'email': _email,
          'profile_image': downloadURL,
          'profile_image_path': 'profile_images/${value.user!.uid}.jpg'
        });

        setState(() {
          _signUpState = "Success!! Redirecting to Sign In...";
        });
        await Future.delayed(const Duration(seconds: 2));
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/signin');
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _signUpState = "Error occurred!!!";
        _isLoading = false;
        // _signUpState = e.message;
      });
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The account already exists for that email.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "An error occured"),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _signUpState = "Error occurred!!!";
        _isLoading = false;
      });
    } finally {}
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _pwController.dispose();
    _pwVerifyController.dispose();
    super.dispose();
  }

  InputDecoration _textFieldDecoration(
      {required String labelText, int minLength = 0}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
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

  Future<String?> showTextDialog(
      {required BuildContext context,
      required String title,
      required String hintText,
      required String labelText,
      required String cancelText,
      required String okText,
      bool obscure = false}) async {
    final TextEditingController _textController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextFormField(
            obscureText: obscure,
            controller: _textController,
            decoration: InputDecoration(
              hintText: hintText,
              labelText: labelText,
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_textController.text),
            child: Text(okText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.primary, size: 15),
              Text(
                'Back',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
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
                Text(
                  'Sign Up',
                  style: GoogleFonts.neonderthaw(
                    fontSize: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink.image(
                          fit: BoxFit.cover,
                          image: (_profileImage == null)
                              ? const AssetImage(
                                  'assets/images/startup_logo.png')
                              : FileImage(_profileImage!) as ImageProvider,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: Theme.of(context).colorScheme.background,
                              width: 3,
                              strokeAlign: BorderSide.strokeAlignOutside),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            await showImageSource(context).then((value) {
                              if (value != null) {
                                _pickImage(source: value);
                              }
                            });
                          },
                          icon: Icon(
                            Icons.edit,
                            size: 15,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: _usernameController,
                    validator: (value) {
                      if (_firstTime) return null;
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      if (value.length < 6) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onSaved: (newValue) {
                      _userName = newValue!;
                    },
                    textCapitalization: TextCapitalization.words,
                    decoration: _textFieldDecoration(labelText: 'Username'),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    controller: _phoneController,
                    validator: (value) =>
                        validatePhoneNumber(value, _firstTime),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onSaved: (newValue) {
                      _phoneNumber = newValue!;
                    },
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    decoration: _textFieldDecoration(labelText: 'Phone Number'),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextFormField(
                    obscureText: true,
                    controller: _pwController,
                    validator: (value) => validatePassword(value, _firstTime),
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    onSaved: (newValue) {
                      _password = newValue!;
                    },
                    keyboardType: TextInputType.visiblePassword,
                    autocorrect: false,
                    decoration: _textFieldDecoration(labelText: 'New Password'),
                  ),
                ),
                const SizedBox(height: 16),
                _signUpState == null
                    ? const SizedBox(height: 30)
                    : SizedBox(
                        height: 30,
                        child: Center(
                          child: Text(
                            _signUpState!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator()),
                if (!_isLoading)
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
                    child: const Text('Sign Up'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: !_isLoading
                      ? () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        }
                      : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text('Have an account? Sign In'),
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

String? validatePassword(String? value, bool firstTime) {
  if (!firstTime && (value == null || value.isEmpty)) {
    return 'Pass is required';
  }
  if (!firstTime && value!.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

String? validateVerifyPassword(
    String? value, String? passwordToVerify, bool firstTime) {
  if (!firstTime && (value == null || value.isEmpty)) {
    return 'Pass is required';
  }
  if (!firstTime && value!.length < 6) {
    return 'Password must be at least 6 characters';
  }
  if (!firstTime && value != passwordToVerify) {
    return 'Passwords do not match';
  }
  return null;
}

String? validatePhoneNumber(String? value, bool firstTime) {
  if (!firstTime && (value == null || value.isEmpty)) {
    return 'Phone Number is required';
  }
  const String regex_pattern = r'^[0-9]{10}$';
  RegExp regex = RegExp(regex_pattern);
  if (!firstTime && !regex.hasMatch(value!)) {
    return 'Invalid Phone Number';
  }
  return null;
}

Future<ImageSource?> showImageSource(BuildContext context) async {
  if (Platform.isIOS) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Text("Camera")),
          CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Text("Gallery")),
        ],
      ),
    );
  }
  return showModalBottomSheet(
      context: context,
      builder: (context) => Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  minVerticalPadding: 10,
                  leading: FaIcon(
                    FontAwesomeIcons.camera,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  title: const Text("Camera"),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  minVerticalPadding: 10,
                  leading: FaIcon(
                    FontAwesomeIcons.images,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  title: const Text("Gallery"),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ));
}
