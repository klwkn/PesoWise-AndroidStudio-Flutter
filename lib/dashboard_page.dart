import 'package:flutter/material.dart';
import 'colors.dart'; // Import the colors file

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text("PesoWise"),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false, // 🔥 This removes the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Handle logout
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.lightGray,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Your Balance",
                  style: TextStyle(color: AppColors.darkGray, fontSize: 20),
                ),
                const SizedBox(height: 5),
                const Text(
                  "₱50,000.00", // Static balance, can be dynamic later
                  style: TextStyle(
                    color: AppColors.darkGray,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Quick Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _quickAction(Icons.send, "Send Money"),
                    _quickAction(Icons.account_balance, "Deposit"),
                    _quickAction(Icons.payment, "Pay Bills"),
                    _quickAction(Icons.history, "History"),
                  ],
                ),
                const SizedBox(height: 20),

                // Recent Transactions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Recent Transactions",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text("See All"))
                    ],
                  ),
                ),

                // Transactions List
                _transactionTile("Netflix Subscription", "-₱550.00", "March 12"),
                _transactionTile("Money Received", "+₱2,000.00", "March 11"),
                _transactionTile("Electricity Bill", "-₱1,500.00", "March 10"),
                _transactionTile("Groceries - SM", "-₱3,200.00", "March 9"),
                _transactionTile("Online Shopping (Lazada)", "-₱1,100.00", "March 8"),
                _transactionTile("Salary Credited", "+₱30,000.00", "March 7"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Action Buttons
  Widget _quickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.darkTeal,
          child: Icon(icon, color: AppColors.softGray, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // Transaction Tile
  Widget _transactionTile(String title, String amount, String date) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.receipt_long, color: AppColors.darkGray),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          color: amount.contains('+') ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}