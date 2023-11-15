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
  bool _isCartEmpty = true;
  Map<String, dynamic> _userData = {};
  final Map<String, dynamic> _selectedItems = {};

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

  void changeCart(id, price, inc) {
    setState(() {
      if (_selectedItems.containsKey(id)) {
        _selectedItems[id]['quantity'] += inc;
      } else {
        _selectedItems[id] = {'quantity': 1, 'price;': price};
      }
      if (_selectedItems[id]['quantity'] == 0) {
        _selectedItems.remove(id);
      }
      _isCartEmpty = _selectedItems.isEmpty;
    });
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
                  contentPadding: const EdgeInsets.only(
                      top: 0, bottom: 0, left: 20, right: 15),
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

                  Map<String, dynamic> categories = {};
                  for (DocumentSnapshot document in snapshot.data!.docs) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    data['id'] = document.id.toString();
                    if (categories.containsKey(data['category'])) {
                      categories[data['category']].add(data);
                    } else {
                      categories[data['category']] = [data];
                    }
                  }

                  return Column(
                    children: [
                      for (var category in categories.keys)
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(top: 30, left: 10),
                              child: Text(
                                category,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            ),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 40,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.75,
                              scrollDirection: Axis.vertical,
                              children: categories[category]
                                  .map<Widget>((item) => ItemTile(
                                        id: item['id'],
                                        title: item['name'],
                                        price: item['price'].toDouble(),
                                        imageUrl: item['image_url'],
                                        changeCart: changeCart,
                                        quantity:
                                            _selectedItems[item['id']] != null
                                                ? _selectedItems[item['id']]
                                                    ['quantity']
                                                : 0,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                    ],
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "${_selectedItems.length} items in cart",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/checkout',
                            arguments: _selectedItems);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Checkout",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
