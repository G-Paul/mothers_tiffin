import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String defaultImg =
      "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4";

  List<bool> _buttonSelection = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 60,
                  left: 30,
                  right: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Orders",
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                    ToggleButtons(
                      children: [
                        Icon(
                          Icons.paid,
                          // color: Colors.green,
                        ),
                        Icon(Icons.warning_rounded),
                      ],
                      borderRadius: BorderRadius.circular(30),
                      isSelected: _buttonSelection,
                      selectedColor:
                          _buttonSelection[0] ? Colors.green : Colors.red,
                      renderBorder: false,
                      onPressed: (int index) {
                        setState(() {
                          _buttonSelection[index] = !_buttonSelection[index];
                          if (_buttonSelection[0] == true &&
                              _buttonSelection[1] == true) {
                            _buttonSelection[0] = false;
                            _buttonSelection[1] = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ))),
      body: StreamBuilder<QuerySnapshot>(
        stream: (_buttonSelection[0])
            ? FirebaseFirestore.instance
                .collection('Order')
                .orderBy('time', descending: true)
                .where('paid', isEqualTo: true)
                .snapshots()
            : (_buttonSelection[1])
                ? FirebaseFirestore.instance
                    .collection('Order')
                    .orderBy('time', descending: true)
                    .where('paid', isEqualTo: false)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('Order')
                    .orderBy('time', descending: true)
                    .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                print(ds);
                return Card(
                  child: ListTile(
                    title: Text('${ds.id}'),
                    subtitle: Text('${ds['total']}'),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
