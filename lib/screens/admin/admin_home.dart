//blank screen
import 'package:flutter/material.dart';

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'admin_listtile.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isCartEmpty = false;
  Map<String, dynamic> _userData = {};
  List<String> selectedItems = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController imageController = TextEditingController();

  final dummyList = [
    "hello",
    "world",
    "mars",
    "jupiter",
    "saturn",
    "uranus",
    "neptune",
    "pluto"
  ];

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

  void addItem() {
    final keybordInset = MediaQuery.of(context).viewInsets.bottom;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4 + keybordInset,
          padding: EdgeInsets.only(
              bottom: keybordInset, left: 16, right: 16, top: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Validate and save the data
                    String name = nameController.text;
                    double price = double.tryParse(priceController.text) ?? 0.0;
                    String category = categoryController.text;
                    String imageUrl = imageController.text;

                    // Implement your logic to add the item to the data source
                    // For example, you can use Firestore to add the item
                    // FirebaseFirestore.instance.collection("items").add({
                    //   "name": name,
                    //   "price": price,
                    //   "category": category,
                    //   "image": imageUrl,
                    // });

                    // Clear the controllers
                    nameController.clear();
                    priceController.clear();
                    categoryController.clear();
                    imageController.clear();

                    // Close the modal bottom sheet
                    Navigator.pop(context);
                  },
                  child: Text('Add Item'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildFloatingActionButton() {
    if (selectedItems.isEmpty) {
      return FloatingActionButton(
        onPressed: () {
          addItem();
          // Add item functionality
        },
        child: Icon(Icons.add),
      );
    } else if (selectedItems.length == 1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Edit item functionality
            },
            child: Icon(Icons.edit),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              // Delete item functionality
            },
            child: Icon(Icons.delete),
          ),
        ],
      );
    } else {
      return FloatingActionButton(
        onPressed: () {
          // Delete items functionality
        },
        child: Icon(Icons.delete),
      );
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
      floatingActionButton: buildFloatingActionButton(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            // height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                ListTile(
                  title: Text("Hi! Admin",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                  subtitle: Text(
                    "Good Morning",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary!
                              .withOpacity(0.7),
                        ),
                  ),
                  contentPadding:
                      EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 15),
                  trailing: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/details');
                    },
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 24,
                      child: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        radius: 22,
                        child: CircleAvatar(
                          foregroundImage: NetworkImage(_userData[
                                  "profile_image"] ??
                              "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4"),
                          radius: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            child: Container(
              // height: 500,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(200))),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 30,
                childAspectRatio: 0.75,
                scrollDirection: Axis.vertical,
                children: [
                  ItemTile(
                    title: "Khana",
                    category: "Salad",
                    price: 99.99,
                    imageUrl:
                        "https://unsplash.com/photos/kcA-c3f_3FE/download?force=true&w=1920",
                  ),
                  ItemTile(
                    title: "Khana",
                    category: "Salad",
                    price: 99.99,
                    imageUrl:
                        "https://unsplash.com/photos/kcA-c3f_3FE/download?force=true&w=1920",
                  ),
                  ItemTile(
                    title: "Khana",
                    category: "Salad",
                    price: 99.99,
                    imageUrl:
                        "https://unsplash.com/photos/kcA-c3f_3FE/download?force=true&w=1920",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
