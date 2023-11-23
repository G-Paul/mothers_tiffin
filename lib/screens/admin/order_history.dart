// ignore_for_file: use_build_context_synchronously

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

  final List<bool> _buttonSelection = [false, false];

  @override
  Widget build(BuildContext context) {
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
                      children: const [
                        Icon(Icons.paid),
                        Icon(Icons.warning_rounded),
                      ],
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
                
                String name = '';
                for (var i = 0; i < ds['items'].length; i++) {
                  name += ds['items'][i]['title'] +
                      ':' +
                      ds['items'][i]['quantity'].toString();
                  if (i != ds['items'].length - 1) {
                    name += ', ';
                  }
                }
                bool paid = ds['paid'];
                return Card(
                  child: InkWell(
                    onTap: () {
                      //show a modal sheet containing the order details
                      showModalBottomSheet(
                          context: context,
                          builder: (context) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text('Order ID: ${ds.id}'),
                                      subtitle: Text(
                                          'Time: ${ds['time'].toDate().toString()}'),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: ds['items'].length,
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(
                                                ds['items'][index]['title']),
                                            subtitle: Text(ds['items'][index]
                                                    ['quantity']
                                                .toString()),
                                            trailing: Text(
                                                '₹${(ds['items'][index]['price'] * ds['items'][index]['quantity']).toStringAsFixed(2)}'),
                                          );
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text('Total'),
                                      trailing: Text(
                                          '₹${ds['total'].toStringAsFixed(2)}'),
                                    ),
                                    ListTile(
                                      title: const Text('Payment Status'),
                                      trailing: Text(
                                          ds['paid'] ? 'Paid' : 'Not Paid'),
                                    ),
                                  ],
                                ),
                              ));
                    },
                    child: ListTile(
                      title: Expanded(
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text('${ds['total']}'),
                      leading: InkWell(
                        onLongPress: () async {
                          await FirebaseFirestore.instance
                              .collection('Order')
                              .doc(ds.id)
                              .update({'paid': !paid}).then((_) {
                            //show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order Payment status updated'),
                              ),
                            );
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: paid ? Colors.green : Colors.red,
                          child: Icon(
                            paid ? Icons.paid : Icons.warning_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      trailing: //iconbutton that deletes the order, after a confirmation from a dialog box
                          IconButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              buttonPadding: EdgeInsets.zero,
                              // contentPadding: EdgeInsets.zero,
                              title: const Text('Delete Order'),
                              content: Text(
                                  'Are you sure you want to delete this order?\nID: ${ds.id}]'),
                              actions: [
                                TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Order')
                                        .doc(ds.id)
                                        .delete()
                                        .then((_) {
                                      //show a snackbar
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Order deleted'),
                                        ),
                                      );
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Yes'),
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .onSecondary),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('No'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
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
