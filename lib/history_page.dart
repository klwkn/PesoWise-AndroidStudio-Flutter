import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'colors.dart'; // Use your color palette

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text("Not logged in."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaction-history')
          .doc(uid)
          .collection('history')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No transactions yet."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final type = data['type'] ?? 'Unknown';
            final amount = data['amount'] ?? 0;
            final timestamp = data['date'] as Timestamp?;
            final date = timestamp != null
                ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
                : DateTime.now();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  type == 'Deposit' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: type == 'Deposit' ? Colors.green : Colors.red,
                ),
                title: Text("$type - PHP $amount"),
                subtitle: Text(
                  "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                ),
              ),
            );
          },
        );
      },
    );
  }
}
