import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'add_donation_screen.dart';
import 'donation_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart'; 


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
                height: 200,
                width: 200,
                child: Image.asset(
                  'assets/icons/kasalo logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 10),
              Text("Welcome, $name!", 
              textAlign: TextAlign.center,
              style: GoogleFonts.abrilFatface(color: Color(0xFFB78A00), fontWeight: FontWeight.bold, fontSize: 22)),
              SizedBox(height: 10),
              Text(
                "Kasalo connects those with plenty to those in need, ensuring that valuable resources are used, not discarded.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Color(0xFF7D5E00)),
              ),
              SizedBox(height: 10),
              Text(
                "'Magbigay ayon sa kakayahan,\nkumuha batay sa pangangailangan.'",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF7D5E00)),
              ),
              SizedBox(height: 10),
              Text(
                "Aligned with the SDG 12: Responsible Consumption and Production.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11, color: Color(0xFF7D5E00)),
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
            icon: Icon(Icons.menu, color: Color(0xFF7D5E00)),
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
                  hintStyle: TextStyle(color: Color(0xFF7D5E00)),
                ),
                style: TextStyle(color: Color(0xFF7D5E00), fontSize: 20),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.toLowerCase();
                  });
                },
              )
            : Center(
              child: Image.asset(
                'assets/icons/name.png', // Replace with your actual image path
                height: 40, // Control the height so it fits nicely in the AppBar
                fit: BoxFit.contain, // Ensures the image doesn't distort
              ),
            ),
        
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Color(0xFF7D5E00)),
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
              // CHANGE THIS: 'start' -> 'stretch'
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
                Text(
                  "Browse Donations",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF7D5E00),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Based on your address",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Color(0xFFB78A00),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // --- LIST ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().donations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: Color(0xFFF7E28C)));
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
        backgroundColor: Color(0xFFB78A00),
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
        color: Color(0xFFFFFCEE), // Cream Background
        child: Column(
          children: [
            // --- HEADER: Profile & Name ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 80, bottom: 20),
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
                        style: GoogleFonts.poppins(
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
            
            Divider(color: primaryColor, thickness: 1.5, indent: 0, endIndent: 0),
            SizedBox(height: 10),

            // --- MENU ITEMS ---
            ListTile(
              leading: Icon(Icons.settings, color: Color(0xFF7D5E00)),
              title: Text("Settings", style: GoogleFonts.poppins(color: Color(0xFFB78A00), fontWeight: FontWeight.bold, fontSize: 18)),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushNamed(context, '/settings'); // Go to Settings
              },
            ),
            
            ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF7D5E00)),
              title: Text("About", style: GoogleFonts.poppins(color: Color(0xFFB78A00), fontWeight: FontWeight.bold, fontSize: 18)),
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
                leading: Icon(Icons.power_settings_new, color: Color(0xFF7D5E00), size: 26),
                title: Text("Log Out", style: GoogleFonts.poppins(color: Color(0xFFB78A00), fontWeight: FontWeight.bold, fontSize: 18)),
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
void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Rounded corners
        
        // 1. CENTERED TITLE
        title: Center(
          child: Text(
            "Log Out",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              color: Color(0xFF7D5E00)
            ),
          ),
        ),
        
        content: Text(
          "Are you sure you want to log out?",
          textAlign: TextAlign.center, // Center content text
          style: GoogleFonts.poppins(),
        ),
        
        actionsAlignment: MainAxisAlignment.center, // Center the buttons row
        actionsPadding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        
        actions: [
          // 2. NO BUTTON
          TextButton(
            child: Text(
              "No", 
              style: GoogleFonts.poppins(color: Colors.grey[800], fontWeight: FontWeight.bold)
            ),
            onPressed: () => Navigator.pop(context),
          ),
          
          SizedBox(width: 10), // Spacing between buttons

          // 2. YES BUTTON (Styled)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF7E28C), // Gold Button
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              elevation: 0,
            ),
            child: Text(
              "Yes", 
              style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontWeight: FontWeight.bold)
            ),
            onPressed: () async {
              Navigator.pop(context); // 1. Close the dialog popup
              
              // 2. Reset the welcome flag so the next user sees the popup
              HomeScreen.welcomeShown = false; 
              
              // 3. Sign out from Firebase
              await _auth.signOut();
              
              // 4. NAVIGATE OUT CORRECTLY
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
        decoration: BoxDecoration(color: Color(0xFFF9E27F), borderRadius: BorderRadius.circular(20)),
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
                  Text(data['title'] ?? "Donation Item", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Color(0xFF7D5E00))),
                  Text("Category: ${data['category'] ?? '---'}", style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF7D5E00))),
                  Text("Condition: ${data['condition'] ?? '---'}", style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF7D5E00))),
                  Text("Location: ${data['location'] ?? '---'}", style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF7D5E00))),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Color(0xFFB78A00), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("View", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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