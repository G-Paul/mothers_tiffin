import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/custom_detail.dart';

class MenuDetailsScreen extends StatefulWidget {
  const MenuDetailsScreen({key}) : super(key: key);

  @override
  State<MenuDetailsScreen> createState() => _MenuDetailsScreenState();
}

class _MenuDetailsScreenState extends State<MenuDetailsScreen> {
  late User user;
  bool _isUpdating = false;
  String _userName = '';
  String _userEmail = '';
  String _phoneNumber = '';
  String _photoURL = '';

  void updateName(String newName) async {
    while (_isUpdating) {}
    setState(() {
      _isUpdating = true;
    });
    await user.updateDisplayName(newName).then((value) {});
    await FirebaseFirestore.instance
        .collection('Customer')
        .doc(user.uid)
        .update({'username': newName}).then(((value) {
      setState(() {
        _isUpdating = false;
        _userName = newName;
      });
    }));
  }

  void updatePhone(String newPhone) async {
    while (_isUpdating) {}
    setState(() {
      _isUpdating = true;
    });
    await FirebaseFirestore.instance
        .collection('Customer')
        .doc(user.uid)
        .update({'phone_number': newPhone}).then(((value) {
      setState(() {
        _isUpdating = false;
        _phoneNumber = newPhone;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    setState(() {
      _userName = userData['username'];
      _userEmail = userData['email'];
      _phoneNumber = userData['phone_number'];
      _photoURL = userData['profile_image'];
    });

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text("Modify Details"),
          foregroundColor: Theme.of(context).textTheme.titleLarge!.color,
        ),
        body: SingleChildScrollView(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(20),
                    // height: 200,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 74,
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        radius: 72,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          foregroundImage: NetworkImage(_photoURL),
                          radius: 70,
                        ),
                      ),
                    ),
                  ),
                  CustomDetailTile(
                    title: "Name",
                    text: _userName,
                    leadingIcon: FontAwesomeIcons.solidUser,
                    validator: (value) => validateName(value),
                    onEdited: updateName,
                  ),
                  const Divider(
                    indent: 70,
                  ),
                  // CustomDetailTile(
                  //   title: "Email",
                  //   text: _userEmail,
                  //   leadingIcon: FontAwesomeIcons.solidEnvelope,
                  //   validator: (value) => validateEmail(value),
                  //   onEdited: updateEmail,
                  // ),
                  // Divider(
                  //   indent: 70,
                  // ),
                  CustomDetailTile(
                    title: "Phone Number",
                    text: _phoneNumber,
                    leadingIcon: FontAwesomeIcons.phone,
                    validator: (value) => validateMobile(value),
                    onEdited: updatePhone,
                  ),
                  const Divider(
                    indent: 70,
                  ),
                  InkWell(
                    onTap: () async {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: _userEmail)
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Password reset email has been sent to registered email ID.")));
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.key,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reset Password",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    indent: 70,
                  ),
                  InkWell(
                    onTap: () {
                      FirebaseAuth.instance.signOut().then((value) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/intro', (route) => false);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.rightFromBracket,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sign Out",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )));
  }
}