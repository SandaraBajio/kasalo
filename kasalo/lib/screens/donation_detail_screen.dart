import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import 'chat_screen.dart';

class DonationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String documentId;

  DonationDetailScreen({required this.data, required this.documentId});

  // Helper to format timestamp
  String _getTimeAgo(Timestamp? timestamp) {
    if (timestamp == null) return "Just now";
    DateTime postTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(postTime);
    if (difference.inMinutes < 1) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes} mins ago";
    if (difference.inHours < 24) return "${difference.inHours} hours ago";
    if (difference.inDays < 7) return "${difference.inDays} days ago";
    return "${postTime.day}/${postTime.month}/${postTime.year}";
  }

  // Helper to format Expiry Date
  String? _getExpiryDate() {
    if (data['expiryDate'] == null) return null;
    try {
      Timestamp t = data['expiryDate'];
      DateTime d = t.toDate();
      return "${d.month}/${d.day}/${d.year}";
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFFA1770E);
    final Color accentColor = Color(0xFFF9E27F);
    final User? user = FirebaseAuth.instance.currentUser;

    // CHECK: Am I the owner?
    bool isOwner = user?.uid == data['donorId'];
    String timeAgo = _getTimeAgo(data['createdAt']);
    String? expiryString = _getExpiryDate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Item Details", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 1. SWIPEABLE IMAGE GALLERY ---
                  Container(
                    width: double.infinity,
                    height: 300, 
                    color: Colors.grey[200],
                    child: Builder(
                      builder: (context) {
                        // A. Get images safely
                        List<dynamic> images = [];
                        if (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty) {
                          images = data['imageUrls'];
                        } else if (data['imageUrl'] != null) {
                          images = [data['imageUrl']];
                        }

                        // B. Show Placeholder if empty
                        if (images.isEmpty) {
                          return Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey));
                        }

                        // C. Build the Swiper
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(child: CircularProgressIndicator(color: primaryColor));
                                  },
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.grey),
                                );
                              },
                            ),
                            // D. Dots Indicator
                            if (images.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: images.map((url) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(horizontal: 3),
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.8),
                                        border: Border.all(color: Colors.black26),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER INFO ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data['status'] ?? 'Available',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(timeAgo, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: 15),

                        Text(
                          data['title'] ?? "No Title",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown[900]),
                        ),

                        Text(
                          "${data['quantity']} ${data['unit']}",
                          style: TextStyle(fontSize: 18, color: Colors.brown[600], fontWeight: FontWeight.w500),
                        ),

                        SizedBox(height: 20),
                        Divider(thickness: 1, color: accentColor),
                        SizedBox(height: 20),

                        // --- SHOW REQUESTER INFO (Only for Owner) ---
                        if (isOwner) _buildRequesterInfo(context),

                        // --- DETAILED INFO ---
                        _buildInfoRow(Icons.category, "Category", data['category']),
                        if (expiryString != null) 
                          _buildInfoRow(Icons.calendar_today, "Expiry Date", expiryString),
                        _buildInfoRow(Icons.info_outline, "Condition", data['condition']),
                        _buildInfoRow(Icons.location_on, "Location", data['location']),

                        SizedBox(height: 20),

                        // --- DONOR DETAILS ---
                        Text("Donor Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[800])),
                        SizedBox(height: 10),

                        FutureBuilder<DocumentSnapshot>(
                          future: DatabaseService(uid: data['donorId']).getUserData(),
                          builder: (context, snapshot) {
                            String donorName = "Loading...";
                            String subtitle = "Verified Neighbor";
                            if (snapshot.hasData && snapshot.data!.data() != null) {
                              var userData = snapshot.data!.data() as Map<String, dynamic>;
                              donorName = userData['fullName'] ?? "Unknown";
                            }
                            if (isOwner) donorName = "$donorName (Me)";

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: accentColor,
                                child: Icon(Icons.person, color: Colors.brown),
                              ),
                              title: Text(donorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(subtitle),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- BOTTOM BUTTONS ---
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
            ),
            child: isOwner
                ? _buildOwnerButtons(context)
                : _buildRequesterButtons(context, primaryColor),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildRequesterInfo(BuildContext context) {
    if (data['requesterId'] == null) {
      return Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange[200]!)),
        child: Row(
          children: [
            Icon(Icons.hourglass_empty, color: Colors.orange),
            SizedBox(width: 10),
            Text("Waiting for requests...", style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: DatabaseService(uid: data['requesterId']).getUserData(),
      builder: (context, snapshot) {
        String requesterName = "Loading...";
        if (snapshot.hasData && snapshot.data!.data() != null) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          requesterName = userData['fullName'] ?? "Unknown User";
        }

        return Container(
          margin: EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Color(0xFFA1770E))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Request Status:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
              SizedBox(height: 10),
              Row(
                children: [
                  CircleAvatar(backgroundColor: Color(0xFFA1770E), child: Icon(Icons.person, color: Colors.white, size: 20)),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Requested by:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(requesterName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFA1770E))),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.chat, color: Color(0xFFA1770E)),
                    onPressed: () async {
                      final User? user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;

                      // Fix Image URL
                      String imgUrl = '';
                      if (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty) {
                        imgUrl = data['imageUrls'][0];
                      } else if (data['imageUrl'] != null) {
                        imgUrl = data['imageUrl'];
                      }

                      String chatId = await DatabaseService(uid: user.uid).createChat(
                          data['requesterId'], 
                          documentId, // Pass ID
                          data['title'], 
                          imgUrl // Pass Image
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            otherUserId: data['requesterId'],
                            itemId: documentId, // *** ADDED THIS ***
                            itemTitle: data['title'],
                            itemImageUrl: imgUrl,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOwnerButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(Icons.settings, color: Colors.white),
        label: Text("Manage Donation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => _showManageDialog(context),
      ),
    );
  }

  Widget _buildRequesterButtons(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.chat_bubble_outline, color: primaryColor),
            label: Text("Message"),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor, width: 2),
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              foregroundColor: primaryColor,
            ),
            onPressed: () async {
              final User? user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              // Fix Image URL
              String imgUrl = '';
              if (data['imageUrls'] != null && (data['imageUrls'] as List).isNotEmpty) {
                imgUrl = data['imageUrls'][0];
              } else if (data['imageUrl'] != null) {
                imgUrl = data['imageUrl'];
              }

              String chatId = await DatabaseService(uid: user.uid).createChat(
                  data['donorId'], 
                  documentId, // Pass ID
                  data['title'], 
                  imgUrl // Pass Image
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: chatId,
                    otherUserId: data['donorId'],
                    itemId: documentId, // *** ADDED THIS ***
                    itemTitle: data['title'],
                    itemImageUrl: imgUrl,
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.volunteer_activism, color: Colors.white),
            label: Text("Request Item"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            onPressed: () => _handleRequestItem(context),
          ),
        ),
      ],
    );
  }

  void _showManageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text("Manage Donation", style: TextStyle(color: Color(0xFFA1770E), fontWeight: FontWeight.bold)),
        children: [
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Text("Mark as Available (Show on Feed)"),
            onPressed: () {
              DatabaseService().updateDonationStatus(documentId, 'Available');
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Text("Mark as Completed (Remove from Feed)"),
            onPressed: () {
              DatabaseService().updateDonationStatus(documentId, 'Completed');
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          Divider(),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Text("Delete Permanently", style: TextStyle(color: Colors.red)),
            onPressed: () {
              DatabaseService().deleteDonation(documentId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _handleRequestItem(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (data['donorId'] == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You cannot request your own item!")));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('donations').doc(documentId).update({
        'requesterId': user.uid,
        'status': 'Pending',
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request Sent!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error requesting item")));
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: Color(0xFFFFFDE7), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Color(0xFFA1770E), size: 24),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value ?? "N/A", style: TextStyle(color: Colors.brown[800], fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}