import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> {
  List<String> selected = [];
  void select(String id) {
    setState(() {
      if (selected.contains(id)) {
        selected.remove(id);
      } else {
        selected.add(id);
      }
    });
  }

  void deleteItem() {
    for (String id in selected) {
      FirebaseFirestore.instance.collection("Feedback").doc(id).delete();
    }
    setState(() {
      selected = [];
    });
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
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                deleteItem();
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Widget? floatingActionButton() {
    if (selected.isNotEmpty) {
      return FloatingActionButton(
        heroTag: 'delete',
        onPressed: () => confirmDelete(),
        child: const Icon(Icons.delete),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton(),
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
                ),
                child: Text("Feedbacks",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        )),
              ))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Feedback').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return Card(
                  child: ListTile(
                    tileColor: selected.contains(ds.id)
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Theme.of(context).colorScheme.surface,
                    onTap: () => select(ds.id),
                    title: Text('${ds['name']}( ${ds['phone']} )'),
                    subtitle: Text('${ds['feedback']}'),
                    trailing: selected.contains(ds.id)
                        ? const Icon(Icons.check)
                        : null,
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
