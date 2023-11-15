import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  void handlePayment() {
    print("hello");
  }

  @override
  Widget build(BuildContext context) {
    final _selectedItems = ModalRoute.of(context)!.settings.arguments
        as Map<String, Map<String, dynamic>>;

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
                itemCount: _selectedItems.length,
                itemBuilder: (context, index) {
                  final _key = _selectedItems.keys.elementAt(index);
                  return ListTile(
                    title: Text(_selectedItems[_key]!['title']),
                    subtitle: Text(
                        "${_selectedItems[_key]!['quantity'].toString()} x ₹${_selectedItems[_key]!['price'].toStringAsFixed(2)}"),
                    trailing: Text(
                        '₹${(_selectedItems[_key]!['price'] * _selectedItems[_key]!['quantity']).toStringAsFixed(2)}'),
                    leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(_selectedItems[_key]!['imageURL']),
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
                    'Total: ₹${_selectedItems.values.map((e) => e['price'] * e['quantity']).reduce((value, element) => value + element).toStringAsFixed(2)}',
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
                      print("Hello");
                      handlePayment();
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
