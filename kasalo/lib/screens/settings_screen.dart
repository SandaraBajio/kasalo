import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  final User? user = FirebaseAuth.instance.currentUser;

  // --- LOGIC: CHANGE PASSWORD ---
  void _changePassword(BuildContext context) async {
    if (user?.email == null) return;
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Password Reset"),
          content: Text("We have sent a password reset link to ${user!.email}. Please check your inbox."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- LOGIC: SHOW INFO DIALOG ---
  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: Color(0xFFA1770E))),
        content: SingleChildScrollView(child: Text(content)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          _buildSectionHeader("General"),
          
          // Visual Toggles (Logic requires complex State Management provider)
          SwitchListTile(
            activeColor: Color(0xFFA1770E),
            title: Text("Push Notifications", style: TextStyle(color: Colors.brown[800])),
            subtitle: Text("Receive updates about your requests"),
            value: _notificationsEnabled,
            onChanged: (bool value) => setState(() => _notificationsEnabled = value),
          ),
          SwitchListTile(
            activeColor: Color(0xFFA1770E),
            title: Text("Dark Mode", style: TextStyle(color: Colors.brown[800])),
            subtitle: Text("Switch to dark theme"),
            value: _darkModeEnabled,
            onChanged: (bool value) => setState(() => _darkModeEnabled = value),
          ),

          Divider(height: 40),

          _buildSectionHeader("Account"),
          
          // 1. CHANGE PASSWORD (Now Working)
          ListTile(
            leading: Icon(Icons.lock_outline, color: Colors.brown),
            title: Text("Change Password", style: TextStyle(color: Colors.brown[800])),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _changePassword(context), // Logic connected
          ),
          
          // 2. PRIVACY POLICY (Now Shows Info)
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: Colors.brown),
            title: Text("Privacy Policy", style: TextStyle(color: Colors.brown[800])),
            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showInfoDialog(context, "Privacy Policy", "Kasalo collects minimal data to connect donors and receivers. We do not share your personal info with third parties without consent."),
          ),
          
          Divider(height: 40),

          _buildSectionHeader("Support"),
          
          // 3. HELP CENTER (Now Shows Info)
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.brown),
            title: Text("Help Center", style: TextStyle(color: Colors.brown[800])),
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
        style: TextStyle(
          color: Color(0xFFA1770E),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}