import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("About Kasalo", style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.brown),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Container(
              height: 100, width: 100,
              decoration: BoxDecoration(color: Color(0xFFF9E27F), shape: BoxShape.circle),
              child: Icon(Icons.volunteer_activism, color: Colors.brown, size: 50),
            ),
            SizedBox(height: 10),
            Text("kasalo", style: TextStyle(color: Color(0xFFF9E27F), fontWeight: FontWeight.bold, fontSize: 24)),
            Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
            
            SizedBox(height: 30),
            Divider(color: Color(0xFFF9E27F)),
            SizedBox(height: 20),

            // Developers Section
            Text("Meet the Team", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFA1770E))),
            SizedBox(height: 20),

            _buildDeveloperCard("Sandara B. Bajio", "Backend Developer", Icons.storage),
            _buildDeveloperCard("Karylle L. De Los Reyes", "Frontend Developer", Icons.brush),

            SizedBox(height: 30),
            
            // Mission/Vision Placeholder (Standard for About pages)
            Text(
              "Kasalo aims to bridge the gap between abundance and need, fostering a community of sharing and sustainability.",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.brown[300]),
            ),
            
            SizedBox(height: 40),
            Text("© 2025 Kasalo Project", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(String name, String role, IconData icon) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Color(0xFFFFFDE7),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFA1770E),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown[800])),
        subtitle: Text(role, style: TextStyle(color: Colors.brown[600])),
      ),
    );
  }
}