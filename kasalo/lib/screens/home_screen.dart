import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Requirement: Source [27] - "Can be an alert dialog that pops up after logging in"
    // We schedule this to run after the screen finishes building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSDGDialog();
    });
  }

  // The Alert Dialog for SDG 12 (Source 6, 7, 27)
  void _showSDGDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Welcome to the Community Pantry"),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text("Why It Relates to SDG 12:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              // Text taken from Source [7] and [9]
              Text("This project supports Responsible Consumption and Production."),
              SizedBox(height: 8),
              Text("We encourage you to donate items instead of throwing them away, helping to reduce waste in our community."),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("I Understand"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Digital Community Pantry"), // Source [27] - App Title
        actions: [
          // Logout Button (Source 29)
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _confirmSignOut(context),
          )
        ],
      ),
      // Requirement: Source [23] - "Fetch User Data" logic
      body: FutureBuilder<DocumentSnapshot>(
        future: DatabaseService(uid: user?.uid).getUserData(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // 2. Error/Empty State
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text("Welcome! (No Profile Data Found)"));
          }

          // 3. Data Loaded - Get the Full Name
          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['fullName'] ?? 'Neighbor'; // Source [27]

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Source [27] - "Welcome, [Fetched User's Name]!"
                Text(
                  "Welcome, $name!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),

                // Source [27] - Core Functions / Main Action Buttons
                _buildMenuButton(
                  icon: Icons.search,
                  label: "Browse Donations", // Source [27]
                  onTap: () {
                    // Navigate to Browse Screen (Future Step)
                  },
                ),
                _buildMenuButton(
                  icon: Icons.add_a_photo,
                  label: "Post Item to Donate", // Source [27]
                  onTap: () {
                    // Navigate to Post Item Screen (Future Step)
                  },
                ),
                _buildMenuButton(
                  icon: Icons.favorite,
                  label: "My Donations", // Source [27]
                  onTap: () {},
                ),
                _buildMenuButton(
                  icon: Icons.person,
                  label: "Profile", // Source [27]
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget to make buttons look nice
  Widget _buildMenuButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(label),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Logout Logic (Source 29, 30, 31)
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"), // Source [31]
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("Logout", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              await _auth.signOut(); // Source [31] - Call Firebase Sign out
              Navigator.pushReplacementNamed(context, '/'); // Return to Welcome
            },
          ),
        ],
      ),
    );
  }
}