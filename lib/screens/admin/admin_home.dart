//blank screen
// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'dart:io';

import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  File? _itemImage = null;
  List<Map<String, dynamic>> _itemData = [];

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
    print(
        "-------------------------------------------------------------------------------------------------------------------------------");
    print(_userData);
  }

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
          _itemImage = File(value.path);
        });
      }
    });
  }

  void addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This ensures that the entire modal rises up
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink.image(
                          fit: BoxFit.cover,
                          image: (_itemImage == null)
                              ? const AssetImage(
                                  'assets/images/startup_logo.png')
                              : FileImage(_itemImage!) as ImageProvider,
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Validate and save the data
                    String name = _nameController.text;
                    double price =
                        double.tryParse(_priceController.text) ?? 0.0;
                    String category = _categoryController.text;
                    print("Name: $name\nPrice: $price\nCategory: $category\n");
                    // Implement your logic to add the item to the data source
                    // For example, you can use Firestore to add the item
                    try {
                      await FirebaseFirestore.instance.collection("Menu").add({
                        "name": name,
                        "price": price,
                        "category": category
                      }).then((value) async {
                        await FirebaseStorage.instance
                            .ref('menu_images/${value.id}.jpg')
                            .putFile(
                                _itemImage!); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!image null ho skta hai
                        String downloadURL = await FirebaseStorage.instance
                            .ref('menu_images/${value.id}.jpg')
                            .getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection("Menu")
                            .doc(value.id)
                            .update({"image_url": downloadURL});
                      });
                    } catch (e) {
                      print(e);
                    }

                    // Clear the controllers
                    _nameController.clear();
                    _priceController.clear();
                    _categoryController.clear();
                    _imageController.clear();
                    setState(() {
                      _itemImage = null;
                    });

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

  void deleteItem() {
    // Implement your logic to delete the selected items from the data source
    // For example, you can use Firestore to delete the items
    for (String id in selectedItems) {
      FirebaseFirestore.instance.collection("Menu").doc(id).delete();
    }
    setState(() {
      selectedItems.clear();
    });
  }

  void modifyItem(String id) async {
    String imageURL = "";
    bool isImageChanged = false;
    bool isNameChanged = false;
    bool isPriceChanged = false;
    bool isCategoryChanged = false;
    await FirebaseFirestore.instance
        .collection("Menu")
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic>? itemdata = documentSnapshot.data();
        if (itemdata != null) {
          _nameController.text = itemdata["name"];
          _priceController.text = itemdata["price"].toString();
          _categoryController.text = itemdata["category"];
          setState(() {
            imageURL = itemdata["image_url"];
          });
          // Handle the itemdata as needed
          print(itemdata);
        } else {
          // Handle the case when itemdata is null
          print('Item data is null');
        }
      } else {
        // Document does not exist
        print('Document does not exist');
      }
    }).catchError((error) {
      // Handle errors here
      print('Error fetching item data: $error');
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This ensures that the entire modal rises up
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        child: Ink.image(
                          fit: BoxFit.cover,
                          image: (_itemImage == null)
                              ? NetworkImage(imageURL)
                              : FileImage(_itemImage!) as ImageProvider,
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
                                isImageChanged = true;
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) => isNameChanged = true,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => isPriceChanged = true,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  onChanged: (value) => isCategoryChanged = true,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Validate and save the data
                    String name = _nameController.text;
                    double price =
                        double.tryParse(_priceController.text) ?? 0.0;
                    String category = _categoryController.text;
                    print("Name: $name\nPrice: $price\nCategory: $category\n");
                    // Implement your logic to add the item to the data source
                    // For example, you can use Firestore to add the item
                    try {
                      await FirebaseFirestore.instance
                          .collection("Menu")
                          .doc(id)
                          .update({
                        if (isNameChanged) "name": name,
                        if (isPriceChanged) "price": price,
                        if (isCategoryChanged) "category": category
                      }).then((value) async {
                        if (isImageChanged) {
                          await FirebaseStorage.instance
                              .ref('menu_images/${id}.jpg')
                              .delete();
                          await FirebaseStorage.instance
                              .ref('menu_images/${id}.jpg')
                              .putFile(
                                  _itemImage!); //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!image null ho skta hai
                          String downloadURL = await FirebaseStorage.instance
                              .ref('menu_images/${id}.jpg')
                              .getDownloadURL();
                          await FirebaseFirestore.instance
                              .collection("Menu")
                              .doc(id)
                              .update({"image_url": downloadURL});
                        }
                      });
                    } catch (e) {
                      print(e);
                    }

                    // Clear the controllers
                    _nameController.clear();
                    _priceController.clear();
                    _categoryController.clear();
                    _imageController.clear();
                    setState(() {
                      _itemImage = null;
                      selectedItems.clear();
                    });

                    // Close the modal bottom sheet
                    Navigator.pop(context);
                  },
                  child: Text('Modify Item'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void selectItem(String id) {
    setState(() {
      if (selectedItems.contains(id)) {
        selectedItems.remove(id);
      } else {
        selectedItems.add(id);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
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
              modifyItem(selectedItems[0]);
            },
            child: Icon(Icons.edit),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              // Delete item functionality
              deleteItem();
            },
            child: Icon(Icons.delete),
          ),
        ],
      );
    } else {
      return FloatingActionButton(
        onPressed: () {
          // Delete items functionality
          deleteItem();
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(200))),
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('Menu').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 30,
                    childAspectRatio: 0.75,
                    scrollDirection: Axis.vertical,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      return ItemTile(
                        id: document.id.toString(),
                        title: data['name'],
                        price: data['price'].toDouble(),
                        category: data['category'],
                        imageUrl: data['image_url'],
                        selectItem: selectItem,
                        isSelected: selectedItems.contains(document.id),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<ImageSource?> showImageSource(BuildContext context) async {
  if (Platform.isIOS) {
    return showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: Text("Camera")),
          CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: Text("Gallery")),
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
                  title: Text("Camera"),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  minVerticalPadding: 10,
                  leading: FaIcon(
                    FontAwesomeIcons.images,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  title: Text("Gallery"),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          ));
}
