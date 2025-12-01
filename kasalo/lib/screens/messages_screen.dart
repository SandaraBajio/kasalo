import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';
import 'chat_screen.dart';
import 'package:google_fonts/google_fonts.dart'; 


class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  // State for Tabs and Search
  String _currentFilter = "All"; // Options: "All", "Unread", "Read"
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- APP BAR (With Toggleable Search) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search messages...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF7D5E00)),
                ),
                style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontSize: 18),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text(
                  "Messages", 
                  style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontWeight: FontWeight.bold, fontSize: 26)
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Color(0xFF7D5E00), size: 30),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = "";
                  _searchController.clear();
                }
              });
            },
          ),
          SizedBox(width: 20)
        ],
      ),

      body: Column(
        children: [
          // --- FILTER TABS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTab("All"),
                _buildTab("Unread"),
                _buildTab("Read"),
              ],
            ),
          ),
          Divider(color: Color(0xFF7D5E00), thickness: 1, indent: 20, endIndent: 20),

          // --- CHAT LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService(uid: user?.uid).userChats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFB78A00)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet", style: GoogleFonts.poppins(color: Colors.grey)));
                }

                // 1. Convert docs to list
                var docs = snapshot.data!.docs;

                // 2. APPLY FILTERS (Tab Selection)
                if (_currentFilter == "Unread") {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    int unread = (data['unread_${user?.uid}'] ?? 0) as int;
                    return unread > 0;
                  }).toList();
                } else if (_currentFilter == "Read") {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    int unread = (data['unread_${user?.uid}'] ?? 0) as int;
                    return unread == 0;
                  }).toList();
                }

                // 3. APPLY SEARCH (Search Query)
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String title = (data['itemTitle'] ?? '').toLowerCase();
                    String lastMsg = (data['lastMessage'] ?? '').toLowerCase();
                    return title.contains(_searchQuery) || lastMsg.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(child: Text("No results found", style: GoogleFonts.poppins(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    
                    // Identify the other user
                    List participants = data['participants'];
                    String otherUserId = participants.firstWhere((id) => id != user?.uid, orElse: () => "");

                    // Use a separate widget to handle the async name fetching cleanly
                    return ChatListTile(
                      docId: doc.id,
                      data: data,
                      otherUserId: otherUserId,
                      currentUserId: user!.uid,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper to build Tabs ---
  Widget _buildTab(String text) {
    bool isActive = _currentFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = text;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isActive ? Color(0xFFA1770E) : Colors.brown[300], // Highlight active
            fontSize: 16,
            decoration: isActive ? TextDecoration.underline : TextDecoration.none, // Underline active
          ),
        ),
      ),
    );
  }
}

// --- SEPARATE WIDGET FOR LIST TILE (Handles Name Fetching) ---
class ChatListTile extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String otherUserId;
  final String currentUserId;

  ChatListTile({
    required this.docId,
    required this.data,
    required this.otherUserId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Unread logic
    int unread = (data['unread_$currentUserId'] ?? 0) as int;
    bool isUnread = unread > 0;

    return GestureDetector(
      onTap: () {
        DatabaseService(uid: currentUserId).markChatAsRead(docId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: docId,
              otherUserId: otherUserId,
              itemId: data['itemId'],
              itemTitle: data['itemTitle'] ?? 'Item',
              itemImageUrl: data['itemImageUrl'], // NEW: Pass Image URL from DB
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Color(0xFFFFF7D4),
          borderRadius: BorderRadius.circular(20),
          border: isUnread ? Border.all(color: Color(0xFFA1770E), width: 1.5) : null,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF7D5E00),
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 15),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // FETCH NAME HERE
                      FutureBuilder<DocumentSnapshot>(
                        future: DatabaseService(uid: otherUserId).getUserData(),
                        builder: (context, snapshot) {
                          String name = "User"; // Default while loading
                          if (snapshot.hasData && snapshot.data!.data() != null) {
                            var userData = snapshot.data!.data() as Map<String, dynamic>;
                            name = userData['fullName'] ?? "User";
                          }
                          return Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: Color(0xFF7D5E00)
                            )
                          );
                        },
                      ),
                      // Time Placeholder (You can add real logic if needed)
                      Text("Recent", style: GoogleFonts.poppins(fontSize: 10, color: Color(0xFF7D5E00))),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    data['lastMessage'] ?? "Start chatting...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Color(0xFF7D5E00),
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                ],
              ),
            ),
            
            // Unread Badge
            if (isUnread) 
              Container(
                margin: EdgeInsets.only(left: 10),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text("$unread", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)),
              )
          ],
        ),
      ),
    );
  }
}