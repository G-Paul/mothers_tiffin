// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:mothers_kitchen/screens/feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'admin_listtile.dart';
import '../utils/topbar.dart';
import 'order_history.dart';
import 'admin_feedback.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Map<String, dynamic> selectedItems = {};
  Map<String, dynamic> userData = {};
  final String defaultImg =
      "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  File? _itemImage;
  var currentIndex = 0;
  List<String> listOfStrings = [
    '  Home',
    '  Orders',
    'Feedback',
  ];
  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.list_rounded,
    Icons.rate_review_outlined,
  ];
  List<String> listOfRoutes = [
    '/',
    '/order_history',
    '/feedback_admin',
  ];

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

  void cleanup({bool isEdit = false}) {
    _nameController.clear();
    _priceController.clear();
    _categoryController.clear();
    _imageController.clear();
    setState(() {
      _itemImage = null;
      if (isEdit) selectedItems.clear();
    });

    Navigator.pop(context);
  }

  void addItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                              color: Theme.of(context).colorScheme.surface,
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
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.onPrimary),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () async {
                    String name = _nameController.text;
                    double price =
                        double.tryParse(_priceController.text) ?? 0.0;
                    String category = _categoryController.text;

                    try {
                      await FirebaseFirestore.instance.collection("Menu").add({
                        "name": name,
                        "price": price,
                        "category": category,
                        "image_url": defaultImg,
                      }).then((value) async {
                        await FirebaseStorage.instance
                            .ref('menu_images/${value.id}.jpg')
                            .putFile(_itemImage!); //notNull
                        String downloadURL = await FirebaseStorage.instance
                            .ref('menu_images/${value.id}.jpg')
                            .getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection("Menu")
                            .doc(value.id)
                            .update({"image_url": downloadURL});
                      });
                    } catch (e) {
                      // log the error
                    }

                    cleanup();
                  },
                  child: const Text('Add Item'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void deleteItem() {
    for (String id in selectedItems.keys) {
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

    _nameController.text = selectedItems[id]["title"];
    _priceController.text = selectedItems[id]["price"].toString();
    _categoryController.text = selectedItems[id]["category"];
    setState(() {
      imageURL = selectedItems[id]["image_url"] ?? defaultImg;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) => isNameChanged = true,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => isPriceChanged = true,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onChanged: (value) => isCategoryChanged = true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    String name = _nameController.text;
                    double price =
                        double.tryParse(_priceController.text) ?? 0.0;
                    String category = _categoryController.text;

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
                              .ref('menu_images/$id.jpg')
                              .delete();
                          await FirebaseStorage.instance
                              .ref('menu_images/$id.jpg')
                              .putFile(_itemImage!); //notNull
                          String downloadURL = await FirebaseStorage.instance
                              .ref('menu_images/$id.jpg')
                              .getDownloadURL();
                          await FirebaseFirestore.instance
                              .collection("Menu")
                              .doc(id)
                              .update({"image_url": downloadURL});
                        }
                      });
                    } catch (e) {
                      // log the error
                    }

                    cleanup(isEdit: true);
                  },
                  child: const Text('Modify Item'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void selectItem(String id, dynamic data) {
    setState(() {
      if (selectedItems.containsKey(id)) {
        selectedItems.remove(id);
      } else {
        selectedItems[id] = data;
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

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Items"),
          content:
              const Text("Are you sure you want to delete the selected items?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteItem();
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Widget? buildFloatingActionButton() {
    if (currentIndex == 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selectedItems.isEmpty)
            FloatingActionButton(
              heroTag: 'add',
              onPressed: () => addItem(),
              child: const Icon(Icons.add),
            ),
          if (selectedItems.length == 1) ...[
            FloatingActionButton(
              heroTag: 'edit',
              onPressed: () => modifyItem(selectedItems.keys.first),
              child: const Icon(Icons.edit),
            ),
            const SizedBox(width: 16, height: 16),
          ],
          if (selectedItems.isNotEmpty)
            FloatingActionButton(
              heroTag: 'delete',
              onPressed: () => confirmDelete(),
              child: const Icon(Icons.delete),
            ),
        ],
      );
    }
    return null;
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        userData['username'] = prefs.getString('username') ?? '';
        userData['email'] = prefs.getString('email') ?? '';
        userData['profile_image'] = prefs.getString('profile_image') ?? '';
        userData['phone_number'] = prefs.getString('phone_number') ?? '';
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final displayWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(displayWidth * .05),
        height: displayWidth * .155,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          borderRadius: BorderRadius.circular(50),
        ),
        child: ListView.builder(
          itemCount: 3,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
          itemBuilder: (context, index) => InkWell(
            onTap: () {
              setState(() {
                currentIndex = index;
              });
              // Navigator.pushNamed(context, '${listOfRoutes[currentIndex]}');
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: index == currentIndex
                      ? displayWidth * .36
                      : displayWidth * .25,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.fastLinearToSlowEaseIn,
                    height: index == currentIndex ? displayWidth * .12 : 0,
                    width: index == currentIndex ? displayWidth * .39 : 0,
                    decoration: BoxDecoration(
                      color: index == currentIndex
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: index == currentIndex
                      ? displayWidth * .31
                      : displayWidth * .18,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width:
                                index == currentIndex ? displayWidth * .12 : 0,
                          ),
                          AnimatedOpacity(
                            opacity: index == currentIndex ? 1 : 0,
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            child: Text(
                              index == currentIndex ? listOfStrings[index] : '',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width:
                                index == currentIndex ? displayWidth * .03 : 20,
                          ),
                          Icon(
                            listOfIcons[index],
                            size: displayWidth * .076,
                            color: index == currentIndex
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.black26,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: currentIndex == 1
          ? const OrderHistoryScreen()
          : currentIndex == 2
              ? const AdminFeedbackScreen()
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    TopBar(userData: userData),
                    Container(
                      color: Theme.of(context).primaryColor,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(150))),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("Menu")
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;

                                return ItemTile(
                                  id: document.id.toString(),
                                  title: data['name'],
                                  price: data['price'].toDouble(),
                                  category: data['category'],
                                  imageUrl: data['image_url'] ??
                                      "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4",
                                  selectItem: selectItem,
                                  isSelected:
                                      selectedItems.containsKey(document.id),
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
