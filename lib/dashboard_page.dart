import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart';
import 'colors.dart';
import 'transactions_page.dart';
import 'history_page.dart';
import 'user_settings_page.dart';

class DashboardPage extends StatefulWidget {
  final int balance;
  final String accountNumber;

  const DashboardPage({
    super.key,
    required this.balance,
    required this.accountNumber,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String _userName = "User";

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _pages.add(HomePage(accountNumber: widget.accountNumber, userName: _userName));
    _pages.add(const TransactionsPage());
    _pages.add(const HistoryPage());
    _pages.add(const UserSettingsPage());
  }

  Future<void> _loadUserName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('user-data')
            .doc(uid)
            .get();

        if (doc.exists) {
          final name = doc.data()?['name'] ?? 'User';

          setState(() {
            _userName = name;
            _pages[0] = HomePage(accountNumber: widget.accountNumber, userName: _userName);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/PesoWiseLogo.png', height: 30),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomePage()),
                    (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully")),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppColors.softGray,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkGray,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        selectedFontSize: 14,
        unselectedFontSize: 12,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String accountNumber;
  final String userName;

  const HomePage({
    super.key,
    required this.accountNumber,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Greeting and Notification Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Hi $userName!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.notifications, color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 16),

        // Real-time Balance Card
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bank-account')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final updatedBalance = data?['balance'] ?? 0;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Account number
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Account Number:", style: TextStyle(color: Colors.white)),
                      Text(accountNumber,
                          style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                  // Live Balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Available Balance:", style: TextStyle(color: Colors.white)),
                      Text("PHP $updatedBalance",
                          style: const TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 24),
        const Text("Special Deals",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGray)),
        const Divider(),
        const SizedBox(height: 16),
        const Text("Discount & Vouchers",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkGray)),
        const Divider(),
      ],
    );
  }
}
