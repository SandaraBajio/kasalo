import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 

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
            
            // --- LOGO SECTION ---
            Container(
              height: 250,
              width: 250,
              child: Image.asset(
                'assets/icons/kasalo logo.png',
                fit: BoxFit.contain,
              ),
            ),
            
            SizedBox(height: 40),

            // --- TEXT SECTION (Poppins applied) ---
            Text(
              "Magbigay ayon sa kakayahan,\nKumuha batay sa pangangailangan.",
              textAlign: TextAlign.center,
              // 2. Use GoogleFonts.poppins here
              style: GoogleFonts.poppins( 
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7D5E00),
              ),
            ),
            
            SizedBox(height: 50),

            // --- SIGN IN BUTTON ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF7E28C),
                foregroundColor: Color(0xFF7D5E00),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Sign In",
                // 3. Applied Poppins to button text too
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),

            SizedBox(height: 20),

            // --- SIGN UP BUTTON ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF7E28C),
                foregroundColor: Color(0xFF7D5E00),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Sign Up",
                // 4. Applied Poppins to button text too
                style: GoogleFonts.poppins(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        ),
      ),
    );
  }
}