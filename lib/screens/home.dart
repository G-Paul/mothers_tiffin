import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCartEmpty = false;
  Map<String, dynamic> _userData = {};
  void getStuff() async {
    //initialise the firebase instance
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    FirebaseStorage _storage = FirebaseStorage.instance;
    //get the current user
    if (_auth.currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
    }
    User user = _auth.currentUser!;
    //get the user id
    String uid = user.uid;
    //get the user data
    await _firestore.collection("Customer").doc(uid).get().then((value) {
      setState(() {
        _userData = value.data()!;
      });
    });
    print(_userData);
  }

  // Return greeting message based on time for ex: "Good morning, ${_userData[userName]}}"
  String greetingMessage(String? name) {
    DateTime now = DateTime.now();
    int hour = now.hour;
    if (hour < 12) {
      return "Good morning, $name";
    } else if (hour < 17) {
      return "Good afternoon, $name";
    } else {
      return "Good evening, $name";
    }
  }

  @override
  void initState() {
    super.initState();
    getStuff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          greetingMessage(_userData["username"]),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/details');
            },
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              radius: 24,
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                radius: 22,
                child: CircleAvatar(
                  foregroundImage: NetworkImage(_userData["profile_image"] ??
                      "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4"),
                  radius: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Center(
        child: Text("hello"),
      ),
      bottomSheet: (_isCartEmpty)
          ? Container(
              height: 0,
              width: 0,
            )
          : Container(
              height: 60,
              width: double.infinity,
              color: Theme.of(context).colorScheme.primary,
              child: Center(
                child: Text(
                  "2 items in cart",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
    );
  }
}
