// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String defaultImg =
      "https://firebasestorage.googleapis.com/v0/b/kitchen-mamas.appspot.com/o/startup_logo.png?alt=media&token=69197ee9-0dfd-4ee6-8326-ded0fc368ce4";

  final List<bool> _buttonSelection = [false, false];
  String? userName;
  String? userPhone;
  String? userImage;

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
                    onTap: () async {
                      //show a modal sheet containing the order details
                      //show a circular progress indicator in an alert dialog
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.transparent,
                              content: SizedBox(
                                height: MediaQuery.of(context).size.width * 0.4,
                                width: MediaQuery.of(context).size.width * 0.7,
                                // color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            );
                          });
                      await FirebaseFirestore.instance
                          .collection('Customer')
                          .doc(ds['user'])
                          .get()
                          .then((value) {
                        Navigator.of(context).pop();
                        userName = value['username'];
                        userPhone = value['phone_number'];
                        userImage = value['profile_image'];
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: Column(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      margin: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(25),
                                        ),
                                        //shadow effect on bottom right
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: const Offset(3, 3),
                                          ),
                                        ],
                                      ),
                                      child: userName == null
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                            )
                                          : ListTile(
                                              leading: CircleAvatar(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                radius: 25,
                                                backgroundImage: NetworkImage(
                                                    userImage ?? defaultImg),
                                              ),
                                              title: Text(
                                                userName!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                              subtitle: Text(userPhone!),
                                              trailing: IconButton(
                                                onPressed: () async {
                                                  //call the phone number
                                                  var phone = Uri.parse(
                                                      "tel:+91$userPhone");
                                                  if (await canLaunchUrl(
                                                      phone)) {
                                                    await launchUrl(phone);
                                                  } else {
                                                    //show a snackbar of the error
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Could not launch the phone app'),
                                                      ),
                                                    );
                                                  }
                                                },
                                                icon: Icon(Icons.call,
                                                    color: Colors.green),
                                              ),
                                            ),
                                    ),
                                    ListTile(
                                      title: Text('Order ID: ${ds.id}'),
                                      subtitle: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Time: ${DateFormat('hh:mm a').format(ds['time'].toDate())}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                          ),
                                          Text(
                                            'Date: ${DateFormat('dd-MM-yyyy').format(ds['time'].toDate())}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.1),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: ds['items'].length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6),
                                                  child: Text(
                                                    "${ds['items'][index]['title']}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),

                                                Text("   x"),
                                                //quantity
                                                Text(
                                                  "${ds['items'][index]['quantity']}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Expanded(
                                                  child: Container(),
                                                ),
                                                Text(
                                                  "₹${(ds['items'][index]['price'] * ds['items'][index]['quantity']).toStringAsFixed(2)}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(
                                          left: 30,
                                          right: 10,
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(25),
                                            topRight: Radius.circular(25),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Total: ",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                '₹ ${ds['total'].toStringAsFixed(2)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall!
                                                    .copyWith(
                                                        color: ds['paid']
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        )),
                                    
                                  ],
                                ),
                              );
                            });
                      });
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${ds['total']}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: ds['paid'] ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          // SizedBox(
                          //   width: 30,
                          // ),
                          Text(
                            DateFormat('dd-MM-yy   hh:mm a').format(ds['time'].toDate()),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withOpacity(0.5)),
                          ),
                          SizedBox(
                            width: 0,
                          )
                        ],
                      ),
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
