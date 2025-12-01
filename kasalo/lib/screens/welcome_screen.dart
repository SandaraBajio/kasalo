import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placeholder for Logo (Frontend dev will replace this later)
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300], // Placeholder color
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "Logo Here",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            
            SizedBox(height: 40),

            // The Text from your design
            Text(
              "Magbigay ayon sa kakayahan,\nKumuha batay sa pangangailangan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown[800], // Matching the earthy tone in the image
              ),
            ),
            
            SizedBox(height: 50),

            // Sign In Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF3E5AB), // Beige/Yellowish color from design
                foregroundColor: Colors.brown[900], // Text color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Sign In",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),

            SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF3E5AB), // Beige/Yellowish color
                foregroundColor: Colors.brown[900], // Text color
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Sign Up",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        ),
      ),
    );
  }
}