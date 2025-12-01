import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'add_donation_screen.dart';
import 'donation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static bool welcomeShown = false;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  User? user = FirebaseAuth.instance.currentUser;
  
  // Search State
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  // Colors from your design
  final Color primaryColor = Color(0xFFA1770E); // Dark Gold/Brown
  final Color creamColor = Color(0xFFFFFDE7);   // Cream Background

  @override
  void initState() {
    super.initState();
    if (!HomeScreen.welcomeShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
      });
    }
  }

  void _showWelcomeDialog() async {
    DocumentSnapshot snapshot = await DatabaseService(uid: user?.uid).getUserData();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    String name = data?['fullName'] ?? 'User';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    HomeScreen.welcomeShown = true; 
                  },
                  child: Icon(Icons.close, color: Colors.grey),
                ),
              ),
              Container(
                height: 80, width: 80,
                decoration: BoxDecoration(color: Color(0xFFF9E27F), shape: BoxShape.circle),
                child: Icon(Icons.volunteer_activism, color: Colors.brown, size: 40),
              ),
              SizedBox(height: 10),
              Text("kasalo", style: TextStyle(color: Color(0xFFF9E27F), fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 15),
              Text("Welcome, $name!", style: TextStyle(color: Color(0xFFA1887F), fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 10),
              Text(
                "Kasalo connects those with plenty to those in need, ensuring that valuable resources are used, not discarded.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.brown[600]),
              ),
              SizedBox(height: 10),
              Text(
                "'Magbigay ayon sa kakayahan,\nkumuha batay sa pangangailangan.'",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.brown[800]),
              ),
              SizedBox(height: 10),
              Text(
                "Aligned with the SDG 12: Responsible Consumption and Production.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    ).then((_) {
      HomeScreen.welcomeShown = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      // --- 1. ADDED DRAWER HERE ---
      drawer: _buildDrawer(),
      

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // We use a Builder to get the correct context to open the drawer
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.brown),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search items...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(color: Colors.brown, fontSize: 18),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : Center(
                child: Text(
                  "kasalo", 
                  style: TextStyle(color: Color(0xFFF9E27F), fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 1.5)
                )
              ),
        
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.brown),
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
          SizedBox(width: 20),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Browse Donations", style: TextStyle(color: Colors.brown[800], fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Based on your address", style: TextStyle(color: Color(0xFFF9E27F), fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
              ],
            ),
          ),

          // --- LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().donations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFF9E27F)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 50, color: Colors.grey[300]),
                        SizedBox(height: 10),
                        Text("No donations yet", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String title = (data['title'] ?? '').toLowerCase();
                    String category = (data['category'] ?? '').toLowerCase();
                    return title.contains(_searchQuery) || category.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(child: Text("No items found matching '$_searchQuery'"));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = docs[index];
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return _buildDonationCard(data, doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFA1770E),
        child: Icon(Icons.add, size: 30, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDonationScreen()),
          );
        },
      ),
    );
  }

  // --- 2. DRAWER WIDGET IMPLEMENTATION ---
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: creamColor, // Cream Background
        child: Column(
          children: [
            // --- HEADER: Profile & Name ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 60, bottom: 20),
              child: FutureBuilder<DocumentSnapshot>(
                future: DatabaseService(uid: user?.uid).getUserData(),
                builder: (context, snapshot) {
                  String name = "Loading...";
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    var userData = snapshot.data!.data() as Map<String, dynamic>;
                    name = userData['fullName'] ?? "User";
                  }
                  return Column(
                    children: [
                      // Profile Icon with Ring
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: primaryColor, // Dark gold border
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 50, color: primaryColor),
                        ),
                      ),
                      SizedBox(height: 15),
                      // Name
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: primaryColor
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            Divider(color: primaryColor, thickness: 1.5, indent: 20, endIndent: 20),
            SizedBox(height: 10),

            // --- MENU ITEMS ---
            ListTile(
              leading: Icon(Icons.settings, color: primaryColor),
              title: Text("Settings", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushNamed(context, '/settings'); // Go to Settings
              },
            ),
            
            ListTile(
              leading: Icon(Icons.info_outline, color: primaryColor),
              title: Text("About", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushNamed(context, '/about'); // Go to About
              },
            ),

            Spacer(), // Pushes Logout to the bottom

            // --- LOGOUT BUTTON ---
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ListTile(
                leading: Icon(Icons.power_settings_new, color: primaryColor, size: 28),
                title: Text("Log Out", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  _confirmSignOut(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGOUT LOGIC ---
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: Text("Logout", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              HomeScreen.welcomeShown = false; 
              await _auth.signOut();
              // Exit MainLayout to Welcome Screen
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> data, String docId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DonationDetailScreen(data: data, documentId: docId)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(color: Color(0xFFF9E27F).withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: Colors.lightBlue[100], borderRadius: BorderRadius.circular(15)),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['title'] ?? "Donation Item", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown[800])),
                  Text("Category: ${data['category'] ?? '---'}", style: TextStyle(fontSize: 12, color: Colors.brown[600])),
                  Text("Condition: ${data['condition'] ?? '---'}", style: TextStyle(fontSize: 12, color: Colors.brown[600])),
                  Text("Location: ${data['location'] ?? '---'}", style: TextStyle(fontSize: 12, color: Colors.brown[600])),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Color(0xFFA1770E), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("View", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          SizedBox(width: 5),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}