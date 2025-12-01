import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // Import Home to access the welcome flag

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // Top Bar (Transparent to show the cream background)
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFDE7),
        elevation: 0,
        automaticallyImplyLeading: false, // ADD THIS: Prevents default back arrow
        // DELETED: leading: IconButton(...)

        actions: [
          // KEEP: Logout Button
          IconButton(
            icon: Icon(Icons.logout, color: Colors.brown),
            onPressed: () => _confirmSignOut(context),
          )
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- 1. TOP PROFILE SECTION (Cream Background) ---
          Container(
            color: Color(0xFFFFFDE7),
            padding: EdgeInsets.only(bottom: 30),
            child: FutureBuilder<DocumentSnapshot>(
              future: DatabaseService(uid: user?.uid).getUserData(),
              builder: (context, snapshot) {
                // Default placeholders while loading
                String name = "Loading...";
                String email = user?.email ?? "No Email";

                if (snapshot.hasData && snapshot.data!.data() != null) {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  name = data['fullName'] ?? "User";
                }

                return Column(
                  children: [
                    // Profile Icon
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFA1770E), // Dark Gold border
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFFF9E27F), // Light Gold fill
                        child: Icon(Icons.person, size: 50, color: Colors.brown),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Full Name
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFFA1770E) // Dark Gold/Brown
                      ),
                    ),
                    
                    // Email Address
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14, 
                        fontStyle: FontStyle.italic, 
                        color: Color(0xFFA1770E)
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // --- 2. "REQUESTED ITEMS" HEADER ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "Requested Items:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037), // Dark Brown
              ),
            ),
          ),

          // --- 3. LIST OF REQUESTED ITEMS ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService(uid: user?.uid).userRequests,
              builder: (context, snapshot) {
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFF9E27F)));
                }

                // Empty State
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey[300]),
                        SizedBox(height: 10),
                        Text("No requested items", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                // List
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return _buildRequestCard(data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data) {
    String status = data['status'] ?? 'Available';
    Color statusColor = status == 'Completed' ? Colors.green : Color(0xFFA1770E);

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF9E27F).withOpacity(0.6), // Light yellow
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(15),
            ),
            child: () {
              if (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty) {
                return ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(data['imageUrls'][0], fit: BoxFit.cover));
              } else if (data['imageUrl'] != null) {
                return ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(data['imageUrl'], fit: BoxFit.cover));
              }
              return Icon(Icons.image, color: Colors.white, size: 40);
            }(),
          ),
          SizedBox(width: 15),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'] ?? "Requested Item", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown[800], fontSize: 16)),
                SizedBox(height: 4),
                Text("Category: ${data['category'] ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.brown[600])),
                
                SizedBox(height: 8),
                
                // --- NEW STATUS BADGE ---
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status, // Shows "Pending" or "Completed"
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- LOGOUT LOGIC (WITH RESET) ---
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Logout", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context); // 1. Close the dialog popup
              
              // 2. Reset the welcome flag so the next user sees the popup
              HomeScreen.welcomeShown = false; 
              
              // 3. Sign out from Firebase
              await _auth.signOut();
              
              // 4. NAVIGATE OUT CORRECTLY
              // 'rootNavigator: true' grabs the very top-level navigation controller,
              // ensuring we completely exit the MainLayout and all tabs.
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}