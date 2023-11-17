import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  Map<String, dynamic> userData = {};
  List<UpiApp>? apps;

  TextStyle header = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  TextStyle value = const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  @override
  void initState() {
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      apps = [];
    });
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

  Future<UpiResponse> initiateTransaction(UpiApp app, double total) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "swain.sandeep@paytm",
      receiverName: 'Sandeep Kumar Swain',
      transactionRefId: 'MothersTiffinCheckout',
      transactionNote: 'Thank you for dining with us.',
      amount: total,
    );
  }

  Widget displayUpiApps(double total) {
    if (apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      return Center(
        child: Text(
          "No apps found to handle transaction.",
          style: header,
        ),
      );
    } else {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          SingleChildScrollView(
            child: Column(
              children: apps!.map<Widget>((UpiApp app) {
                return GestureDetector(
                  onTap: () {
                    _transaction = initiateTransaction(app, total);
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Theme.of(context).colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: Icon(Icons.payment,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withOpacity(0.5)),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          app.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }
  }

  String _upiErrorHandler(error) {
    switch (error) {
      case UpiIndiaAppNotInstalledException:
        return 'Requested app not installed on device';
      case UpiIndiaUserCancelledException:
        return 'You cancelled the transaction';
      case UpiIndiaNullResponseException:
        return 'Requested app didn\'t return any response';
      case UpiIndiaInvalidParametersException:
        return 'Requested app cannot handle the transaction';
      default:
        return 'An Unknown error has occurred';
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void addOrderDetail(Map<String, dynamic> selectedItems, double total,
      String status, String txnId, String txnRef, String approvalRef) {
    FirebaseFirestore.instance.collection('Order').add({
      'username': userData['username'],
      'email': userData['email'],
      'profile_image': userData['profile_image'],
      'phone_number': userData['phone_number'],
      'order': selectedItems,
      'total': total,
      'status': status,
      'txnId': txnId,
      'txnRef': txnRef,
      'approvalRef': approvalRef,
      'timestamp': DateTime.now(),
    }).then((value) {
      _showDialog("Success", "Thank you for your order.");
    }).catchError((error) {
      _showDialog("Error", "Failed to submit order");
    });
  }

  void _checkTxnStatus(Map<String, dynamic> selectedItems, double total,
      String status, String txnId, String txnRef, String approvalRef) {
    switch (status) {
      case UpiPaymentStatus.SUCCESS:
        _showDialog("Success", "Payment Sucessful.");
        addOrderDetail(
            selectedItems, total, status, txnId, txnRef, approvalRef);
        break;
      case UpiPaymentStatus.SUBMITTED:
        _showDialog("Pending", "Payment Pending.");
        break;
      case UpiPaymentStatus.FAILURE:
        _showDialog("Failure", "Payment Failed.");
        break;
      default:
        _showDialog("Unknown", "Payment status unknown.");
    }
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: header),
          Flexible(
              child: Text(
            body,
            style: value,
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    double total = selectedItems.values
        .map((e) => e['price'] * e['quantity'])
        .reduce((value, element) => value + element);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Choose UPI"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: displayUpiApps(total.toDouble()),
          ),
          Expanded(
            child: FutureBuilder(
              future: _transaction,
              builder:
                  (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        _upiErrorHandler(snapshot.error.runtimeType),
                        style: header,
                      ),
                    );
                  }

                  UpiResponse upiResponse = snapshot.data!;

                  String txnId = upiResponse.transactionId ?? 'N/A';
                  String resCode = upiResponse.responseCode ?? 'N/A';
                  String txnRef = upiResponse.transactionRefId ?? 'N/A';
                  String status = upiResponse.status ?? 'N/A';
                  String approvalRef = upiResponse.approvalRefNo ?? 'N/A';
                  _checkTxnStatus(
                      selectedItems, total, status, txnId, txnRef, approvalRef);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        displayTransactionData('Transaction Id', txnId),
                        displayTransactionData('Response Code', resCode),
                        displayTransactionData('Reference Id', txnRef),
                        displayTransactionData('Status', status.toUpperCase()),
                        displayTransactionData('Approval No', approvalRef),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(''),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
