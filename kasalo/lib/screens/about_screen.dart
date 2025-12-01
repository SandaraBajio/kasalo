import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 


class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("About Kasalo", style: GoogleFonts.poppins(color: Color(0xFF7D5E00), fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF7D5E00)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: 200,
                width: 200,
                child: Image.asset(
                  'assets/icons/kasalo logo.png',
                  fit: BoxFit.contain,
                ),
              ),            
            Text("Version 1.0.0", style: GoogleFonts.poppins(color: Colors.grey[700])),
            
            SizedBox(height: 30),
            Divider(color: Color(0xFFF9E27F)),
            SizedBox(height: 20),

            // Developers Section
            Text("Meet the Team", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB78A00))),
            SizedBox(height: 20),

            _buildDeveloperCard("Sandara B. Bajio", "Backend Developer", Icons.storage),
            _buildDeveloperCard("Karylle L. De Los Reyes", "Frontend Developer", Icons.brush),

            SizedBox(height: 30),
            
            // Mission/Vision Placeholder (Standard for About pages)
            Text(
              "Kasalo aims to bridge the gap between abundance and need, fostering a community of sharing and sustainability.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontStyle: FontStyle.italic, color: Color(0xFFB78A00)),
            ),
            
            SizedBox(height: 40),
            Text("© 2025 Kasalo Project", style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12)),
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
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7D5E00))),
        subtitle: Text(role, style: TextStyle(color: Color(0xFFB78A00))),
      ),
    );
  }
}