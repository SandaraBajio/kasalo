import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'donation_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart'; 

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
        automaticallyImplyLeading: false, 
        centerTitle: false, 
        
        // 1. INCREASE THE APP BAR HEIGHT
        toolbarHeight: 70, 
        
        // Title on the Left
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            "My Donations",
            style: GoogleFonts.poppins(
              color: Color(0xFFA1770E), 
              fontSize: 26, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),

        // Image on the Right
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 8),
            child: Center(
              child: Image.asset(
                'assets/icons/name.png', 
                // 2. NOW YOU CAN MAKE THIS BIGGER
                height: 40, 
                fit: BoxFit.contain, 
              ),
            ),
          )
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService(uid: user?.uid).userDonations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFF9E27F)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No donations yet", style: GoogleFonts.poppins(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          color: Color(0xFFF9E27F),
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
                  Text(data['title'] ?? "Item", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.brown[800], fontSize: 16)),
                  SizedBox(height: 4),
                  Text("Category: ${data['category'] ?? '-'}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.brown[700])),
                  Text("Location: ${data['location'] ?? '-'}", style: GoogleFonts.poppins(fontSize: 12, color: Colors.brown[700])),
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
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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