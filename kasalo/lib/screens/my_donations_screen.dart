import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'donation_detail_screen.dart'; // Import details screen

class MyDonationsScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // 1. ADD THIS: Tells Flutter NOT to put a back button automatically
        automaticallyImplyLeading: false, 
        
        // 2. REMOVED: The 'leading' IconButton block is deleted here.
        
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                "kasalo",
                style: TextStyle(
                  color: Color(0xFFF9E27F), 
                  fontWeight: FontWeight.bold, 
                  fontSize: 24, 
                  letterSpacing: 1.0,
                  shadows: [Shadow(color: Colors.black12, offset: Offset(1,1), blurRadius: 1)]
                ),
              ),
            ),
          )
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "My Donations",
              style: TextStyle(color: Color(0xFFA1770E), fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService(uid: user?.uid).userDonations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFF9E27F)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No donations yet", style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    
                    return _buildMyDonationCard(context, data, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD WIDGET ---
  Widget _buildMyDonationCard(BuildContext context, Map<String, dynamic> data, String docId) {
    return GestureDetector(
      // Navigates to Details Screen
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DonationDetailScreen(
              data: data, 
              documentId: docId
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF9E27F).withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Safe Loader
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(15)),
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
                  Text(data['title'] ?? "Item", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown[800], fontSize: 16)),
                  SizedBox(height: 4),
                  Text("Category: ${data['category'] ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.brown[700])),
                  Text("Location: ${data['location'] ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.brown[700])),
                  SizedBox(height: 10),
                  
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFA1770E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Status: ${data['status'] ?? 'Available'}",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}