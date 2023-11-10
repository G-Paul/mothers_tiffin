import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:mothers_tiffin/screens/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _phoneNumber = "";
  String _otp = "";
  String _countryCode = "+91";
  bool _showOtp = false;

  void onSubmit() async {
    print(
        "${_phoneNumber}pppppppppppp${_otp}---------------------------------------------------------------");
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$_countryCode$_phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        },
        verificationFailed: (FirebaseAuthException e) {
          Navigator.of(context).pop();
        },
        codeSent: (String verificationId, int? resendToken) {
          //show a dialog box to take input from the user
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Enter OTP'),
                  content: Material(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _otpController,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        try {
                          FirebaseAuth auth = FirebaseAuth.instance;
                          String smsCode = _otpController.text.trim();
                          PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: smsCode);
                          UserCredential result =
                              await auth.signInWithCredential(credential);
                          User? user = result.user;
                          if (user != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen()));
                          } else {
                            print("Error");
                          }
                        } catch (e) {
                          print(
                              "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                          print(e);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                );
              });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Navigator.of(context).pop();
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            key: _formkey,
            children: [
              const Text(
                'Enter your phone number to login',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    prefixText: _countryCode,
                  ),
                  keyboardType: TextInputType.number,
                  controller: _phoneController,
                  onChanged: (value) => setState(() {
                    _phoneNumber = value;
                  }),
                  onEditingComplete: () {
                    setState(() {
                      _phoneNumber = _phoneController.text;
                      // setState(() {
                      //   _showOtp = true;
                      // });
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 40.0),
              //   child: TextFormField(
              //     decoration: const InputDecoration(
              //       hintText: 'OTP',
              //     ),
              //     keyboardType: TextInputType.number,
              //     controller: _otpController,
              //     enabled: _showOtp,
              //     onChanged: (value) => setState(() {
              //       _otp = value;
              //     }),
              //     onEditingComplete: () {
              //       setState(() {
              //         _phoneNumber = _otpController.text;
              //       });
              //     },
              //   ),
              // ),
              ElevatedButton(
                onPressed: () {
                  onSubmit();
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
