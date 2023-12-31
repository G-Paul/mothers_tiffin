import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final String defaultImg =
      "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4";

  void createNewOrder(Map<String, dynamic> selectedItems) {
    num total = selectedItems.values
        .map((e) => e['price'] * e['quantity'])
        .reduce((value, element) => value + element);
    try {
      FirebaseFirestore.instance.collection('Order').add({
        'user': FirebaseAuth.instance.currentUser!.uid,
        'items': selectedItems.values.toList(),
        'total': total,
        'paid': false,
        'time': DateTime.now(),
      }).then((value) {
        Navigator.of(context).pushNamed('/payment', arguments: {
          'orderId': value.id,
          'total': total.toStringAsFixed(2),
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void checkout(Map<String, dynamic> selectedItems) {
    try {
      FirebaseFirestore.instance
          .collection('Order')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('paid', isEqualTo: false)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          final orderId = value.docs.first.id;
          final items = value.docs.first.data()['items'] as List<dynamic>;
          final newItems = selectedItems.values.toList();
          items.addAll(newItems);
          FirebaseFirestore.instance
              .collection('Order')
              .doc(orderId)
              .update({'items': items}).then((value) {
            Navigator.of(context).pushNamed('/payment', arguments: {
              'orderId': orderId,
              'total': items
                  .map((e) => e['price'] * e['quantity'])
                  .reduce((value, element) => value + element)
                  .toStringAsFixed(2)
            });
          });
        } else {
          createNewOrder(selectedItems);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 10),
                    Text("Checkout",
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                  ],
                ),
              ))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  final key = selectedItems.keys.elementAt(index);
                  return ListTile(
                    title: Text(selectedItems[key]!['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    subtitle: Text(
                        "${selectedItems[key]!['quantity'].toString()} x ₹${selectedItems[key]!['price'].toStringAsFixed(2)}"),
                    trailing: Text(
                        '₹${(selectedItems[key]!['price'] * selectedItems[key]!['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          selectedItems[key]!['imageUrl'] ?? defaultImg),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Text(
                      'Total: ₹${selectedItems.values.map((e) => e['price'] * e['quantity']).reduce((value, element) => value + element).toStringAsFixed(2)}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () => checkout(selectedItems),
                    style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.secondary),
                    ),
                    child: const Text("Checkout",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
