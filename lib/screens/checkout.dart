import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

  @override
  Widget build(BuildContext context) {
    final selectedItems =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
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
                    title: Text(selectedItems[key]!['title']),
                    subtitle: Text(
                        "${selectedItems[key]!['quantity'].toString()} x ₹${selectedItems[key]!['price'].toStringAsFixed(2)}"),
                    trailing: Text(
                        '₹${(selectedItems[key]!['price'] * selectedItems[key]!['quantity']).toStringAsFixed(2)}'),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(selectedItems[key]!['imageURL']),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            height: 70,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Total: ₹${selectedItems.values.map((e) => e['price'] * e['quantity']).reduce((value, element) => value + element).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      double total = selectedItems.values
                          .map((e) => e['price'] * e['quantity'])
                          .reduce((value, element) => value + element);
                      Navigator.pushNamed(context, '/payment',
                            arguments: total);
                    },
                    child: const Text('Checkout'),
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
