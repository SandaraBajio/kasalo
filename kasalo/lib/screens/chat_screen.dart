import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import 'donation_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart'; 
 // IMPORT THIS so we can navigate there

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String itemId; // NEW: We need the ID to fetch details
  final String itemTitle;
  final String? itemImageUrl;

  ChatScreen({
    required this.chatId, 
    required this.otherUserId, 
    required this.itemId, // Add to constructor
    required this.itemTitle,
    this.itemImageUrl
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  late DatabaseService _db;

  @override
  void initState() {
    super.initState();
    _db = DatabaseService(uid: user!.uid);
    _db.markChatAsRead(widget.chatId);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    _db.sendMessage(widget.chatId, _messageController.text.trim(), widget.otherUserId);
    _messageController.clear();
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime date = timestamp.toDate();
    String period = date.hour >= 12 ? "PM" : "AM";
    int hour = date.hour > 12 ? date.hour - 12 : date.hour;
    if (hour == 0) hour = 12;
    String minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFCEE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF7D5E00), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(widget.otherUserId).snapshots(),
          builder: (context, snapshot) {
            String name = "Loading...";
            bool isOnline = false;
            if (snapshot.hasData && snapshot.data!.data() != null) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              name = data['fullName'] ?? "User";
              isOnline = data['isOnline'] ?? false;
            }
            return Column(
              children: [
                Text(name, style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontWeight: FontWeight.bold, fontSize: 18)),
                Text(isOnline ? "Online" : "Offline", style: GoogleFonts.poppins(color: Color(0xFFB78A00), fontSize: 14)),
              ],
            );
          },
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // --- SHOPEE STYLE ITEM CARD ---
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFFF7E28C), 
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey[300]!)
                  ),
                  child: (widget.itemImageUrl != null && widget.itemImageUrl!.startsWith('http'))
                    ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(widget.itemImageUrl!, fit: BoxFit.cover))
                    : Icon(Icons.image, size: 30, color: Colors.grey),
                ),
                SizedBox(width: 10),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Inquiry about:", style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF7D5E00))),
                      Text(
                        widget.itemTitle,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Color(0xFFB78A00), fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // --- WORKING VIEW BUTTON ---
                TextButton(
                  onPressed: () async {
                    // Fetch the latest item data from Firestore
                    DocumentSnapshot doc = await FirebaseFirestore.instance
                        .collection('donations')
                        .doc(widget.itemId)
                        .get();

                    if (doc.exists) {
                      // Navigate to Details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationDetailScreen(
                            data: doc.data() as Map<String, dynamic>,
                            documentId: widget.itemId,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("This item has been deleted."))
                      );
                    }
                  },
                  child: Text("View", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),

          // --- MESSAGES LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Color(0xFFA1770E)));

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var msg = snapshot.data!.docs[index];
                    bool isMe = msg['senderId'] == user!.uid;
                    String time = _formatTime(msg['createdAt']);
                    bool isRead = (msg.data() as Map<String, dynamic>).containsKey('isRead') ? msg['isRead'] : false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) CircleAvatar(radius: 14, backgroundColor: Color(0xFFB78A00), child: Icon(Icons.person, size: 16, color: Colors.white)),
                          if (!isMe) SizedBox(width: 8),

                          if (isMe) Padding(
                            padding: const EdgeInsets.only(right: 5, bottom: 2),
                            child: Row(
                              children: [
                                Text(time, style: GoogleFonts.poppins(fontSize: 10, color: Color(0xFF7D5E00))),
                                SizedBox(width: 2),
                                if (isRead) Icon(Icons.done_all, size: 14, color: Colors.brown),
                              ],
                            ),
                          ),

                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Color(0xFFF2E5AD) : Color(0xFFD9D9D8),
                              borderRadius: BorderRadius.circular(15).copyWith(
                                bottomLeft: isMe ? Radius.circular(15) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : Radius.circular(15)
                              ),
                            ),
                            child: Text(msg['text'], style: GoogleFonts.poppins(color: Colors.black87)),
                          ),

                          if (!isMe) Padding(
                            padding: const EdgeInsets.only(left: 5, bottom: 2),
                            child: Text(time, style: GoogleFonts.poppins(fontSize: 10, color: Color(0xFF7D5E00))),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- INPUT AREA ---
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true, fillColor: Color(0xFFFFF7D4),
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Icon(Icons.send, color: Color(0xFFA1770E), size: 30),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}