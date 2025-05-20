import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'colors.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<void> _handleTransaction(String type) async {
    final uid = _auth.currentUser?.uid;
    final amount = int.tryParse(_amountController.text);

    if (uid == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount")),
      );
      return;
    }

    final accountRef = _firestore.collection('bank-account').doc(uid);
    final historyRef = _firestore.collection('transaction-history').doc(uid).collection('history');

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(accountRef);
        final currentBalance = snapshot['balance'] ?? 0;

        final newBalance = type == 'Deposit'
            ? currentBalance + amount
            : currentBalance - amount;

        if (newBalance < 0) {
          throw Exception("Insufficient balance.");
        }

        transaction.update(accountRef, {'balance': newBalance});
        transaction.set(historyRef.doc(), {
          'type': type,
          'amount': amount,
          'date': Timestamp.now(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$type successful!")),
      );
      _amountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.darkGray,
            tabs: const [
              Tab(text: 'Deposit'),
              Tab(text: 'Transfer'),
            ],
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTransactionForm('Deposit'),
              _buildTransactionForm('Transfer'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionForm(String type) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            "Enter $type Amount:",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "e.g. 100",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _handleTransaction(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
