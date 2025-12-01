import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'home_screen.dart'; // Import to access static welcomeShown flag if needed

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  // --- 1. LOGIC: CHANGE PASSWORD ---
  void _changePassword(BuildContext context) async {
    if (user?.email == null) return;
    
    try {
      await _auth.sendPasswordResetEmail(email: user!.email!);
      _showInfoDialog(context, "Password Reset", "We have sent a password reset link to ${user!.email}. Please check your inbox.");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e", style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // --- 2. LOGIC: SHOW INFO DIALOG (IMPROVED UI) ---
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), 
        
        // Centered & Styled Title
        title: Center(
          child: Text(
            title, 
            style: GoogleFonts.poppins(
              color: Color(0xFFB78A00), 
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        
        // Styled Content
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                content,
                textAlign: TextAlign.center, 
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5, 
                ),
              ),
            ],
          ),
        ),
        
        actionsAlignment: MainAxisAlignment.center, 
        actionsPadding: EdgeInsets.only(bottom: 25, top: 10),
        
        // Gold Pill Button
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF7E28C), 
              foregroundColor: Color(0xFF7D5E00), 
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. LOGIC: CONFIRM SIGN OUT (IMPROVED UI) ---
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        
        title: Center(
          child: Text(
            "Logout",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              color: Color(0xFF7D5E00)
            ),
          ),
        ),
        
        content: Text(
          "Are you sure you want to log out?",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        
        actions: [
          // No Button
          TextButton(
            child: Text(
              "No", 
              style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)
            ),
            onPressed: () => Navigator.pop(context),
          ),
          
          SizedBox(width: 10), 

          // Yes Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFF7E28C), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              elevation: 0,
            ),
            child: Text(
              "Yes", 
              style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontWeight: FontWeight.bold)
            ),
            onPressed: () async {
              Navigator.pop(context); 
              
              // Optional: Reset welcome flag if you track it statically
              // HomeScreen.welcomeShown = false; 
              
              await _auth.signOut();
              
              // Navigate to Login/Welcome screen and remove all previous routes
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Settings", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF7D5E00)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSectionHeader("General"),
          
          SwitchListTile(
            activeColor: Color(0xFFB78A00),
            title: Text("Push Notifications", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontSize: 18)),
            subtitle: Text("Receive updates about your requests", style: GoogleFonts.poppins(fontSize: 12)),
            value: _notificationsEnabled,
            onChanged: (bool value) => setState(() => _notificationsEnabled = value),
          ),
          SwitchListTile(
            activeColor: Color(0xFFB78A00),
            title: Text("Dark Mode", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontSize: 18)),
            subtitle: Text("Switch to dark theme", style: GoogleFonts.poppins(fontSize: 12)),
            value: _darkModeEnabled,
            onChanged: (bool value) => setState(() => _darkModeEnabled = value),
          ),

          Divider(height: 40),

          _buildSectionHeader("Account"),
          
          ListTile(
            leading: Icon(Icons.lock_outline, color: Color(0xFF7D5E00)),
            title: Text("Change Password", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontSize: 18)),
            trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () => _changePassword(context), 
          ),
          
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Color(0xFF7D5E00)),
            title: Text("Privacy Policy", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontSize: 18)),
            trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () => _showInfoDialog(context, "Privacy Policy", "Kasalo collects minimal data to connect donors and receivers. We do not share your personal info with third parties without consent."),
          ),
          
          Divider(height: 40),

          _buildSectionHeader("Support"),
          
          ListTile(
            leading: Icon(Icons.help_outline, color: Color(0xFF7D5E00)),
            title: Text("Help Center", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontSize: 18)),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showInfoDialog(context, "Help Center", "For support, please contact us at support@kasalo.com or browse our FAQ section on the website."),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Color(0xFFB78A00),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}