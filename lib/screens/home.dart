import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'listtile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isCartEmpty = false;
  Map<String, dynamic> _userData = {};
  List<String> selectedItems = [];

  void getStuff() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    if (auth.currentUser == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/intro', (route) => false);
    }
    User user = auth.currentUser!;
    String uid = user.uid;
    
    await firestore.collection("Customer").doc(uid).get().then((value) {
      setState(() {
        _userData = value.data()!;
      });
    });
  }

  String greet() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();
    getStuff();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                ListTile(
                  title: Text("Hi! ${_userData["username"]}",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                  subtitle: Text(
                    greet(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withOpacity(0.7),
                        ),
                  ),
                  contentPadding:
                      const EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 15),
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
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomSheet: (_isCartEmpty)
          ? const SizedBox(
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