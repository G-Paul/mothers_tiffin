import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuDetailsScreen extends StatefulWidget {
  const MenuDetailsScreen({super.key});

  @override
  State<MenuDetailsScreen> createState() => _MenuDetailsScreenState();
}

class _MenuDetailsScreenState extends State<MenuDetailsScreen> {
  late User user;
  bool _isLoading = false;
  bool _isUpdating = false;
  late String _userName;
  late String _userEmail;
  late String _phoneNumber;
  late String _photoURL;

  void getUserDetails() async {
    setState(() {
      _isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('Customer')
        .doc(user.uid)
        .get()
        .then((doc) {
      setState(() {
        _userName = doc.data()!['username'];
        _userEmail = doc.data()!['email'];
        _phoneNumber = doc.data()!['phone_number'];
        _photoURL = doc.data()!['profile_image'];
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  void updateName(String newName) async {
    while (_isUpdating);
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
    while (_isUpdating);
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
  void initState() {
    super.initState();
    setState(() {
      user = FirebaseAuth.instance.currentUser!;
    });
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Modify Details"),
          foregroundColor: Theme.of(context).textTheme.titleLarge!.color,
        ),
        body: (_isLoading)
            ? Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ))
            : SingleChildScrollView(
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

class CustomDetailTile extends StatefulWidget {
  final String text;
  final String title;
  final IconData leadingIcon;
  final Function onEdited;
  final Function validator;
  const CustomDetailTile({
    super.key,
    required this.text,
    required this.title,
    required this.leadingIcon,
    required this.onEdited,
    required this.validator,
  });

  @override
  State<CustomDetailTile> createState() => _CustomDetailTileState();
}

class _CustomDetailTileState extends State<CustomDetailTile> {
  final TextEditingController _controller = TextEditingController(text: "");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Center(
                child: FaIcon(
                  widget.leadingIcon,
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
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.text,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Form(
                      key: _formKey,
                      child: Container(
                        padding: EdgeInsets.only(
                            bottom:
                                MediaQuery.of(context).viewInsets.bottom + 10,
                            top: 20,
                            left: 20,
                            right: 20),
                        height: MediaQuery.of(context).size.height * 0.3 +
                            MediaQuery.of(context).viewInsets.bottom +
                            10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enter your ${widget.title}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .color!
                                            .withOpacity(0.7),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: TextFormField(
                                  validator: ((value) =>
                                      widget.validator(value)),
                                  onChanged: (_) {
                                    _formKey.currentState!.validate();
                                  },
                                  controller: _controller,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(fontSize: 20),
                                  decoration: InputDecoration(
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
                                      )),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).primaryColor),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(horizontal: 20)),
                                      textStyle: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 18,
                                                fontFamily: "Roboto",
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        widget.onEdited(_controller.value.text);
                                      }
                                    },
                                    style: ButtonStyle(
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).primaryColor),
                                      padding: MaterialStateProperty.all(
                                          const EdgeInsets.symmetric(horizontal: 20)),
                                      textStyle: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontSize: 18,
                                                fontFamily: "Roboto",
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    child: const Text("Save"),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: FaIcon(
                FontAwesomeIcons.pencil,
                color: Theme.of(context).focusColor,
                size: 17,
              ),
            ),
          ],
        ));
  }
}

String? validateEmail(String? value) {
  if ((value == null || value.isEmpty)) {
    return 'Email is required';
  }
  const String regexPattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(regexPattern);
  if (!regex.hasMatch(value)) {
    return 'Invalid Email';
  }
  return null;
}

String? validateName(String? value) {
  if ((value == null) || (value.isEmpty)) {
    return "Name cannot be empty";
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  RegExp regExp = RegExp(pattern);
  if (value == null || value.isEmpty) {
    return 'Please enter mobile number';
  } else if (!regExp.hasMatch(value)) {
    return 'Please enter valid mobile number';
  }
  return null;
}
