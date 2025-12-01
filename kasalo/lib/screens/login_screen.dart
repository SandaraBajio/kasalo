import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // State variables
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    // Define colors based on your image
    final Color backgroundColor = Color(0xFFFFF7D4); // Light cream background
    final Color buttonColor = Color(0xFFF7E28C);     // Yellow/Gold button
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP SECTION: Logo & Slogan ---
            Expanded(
              flex: 4, // Takes up 40% of space
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Placeholder
                    Container(
                        height: 230,
                        width: 230,
                        child: Image.asset(
                          'assets/icons/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    SizedBox(height: 10),
                    // Applied Abril Fatface
                    Text(
                      "Share your Kindness",
                      style: GoogleFonts.abrilFatface(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB78A00),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM SECTION: White Container with Form ---
            Expanded(
              flex: 6, 
              child: Container(
                width: double.infinity,
                // 1. Margin for the floating look
                margin: EdgeInsets.only(left: 0, right: 0, bottom: 0), 
                
                decoration: BoxDecoration(
                  color: Colors.white,
                  // 2. Rounded corners
                  borderRadius: BorderRadius.circular(40), 
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                // 3. The Form is now correctly inside this Container
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Applied Poppins
                        Text(
                          "SIGN IN",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB78A00),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Email Field (Grey Rounded)
                        TextFormField(
                          style: GoogleFonts.poppins(), // Applied to input text
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: GoogleFonts.poppins(), // Applied to hint text
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                          onChanged: (val) => setState(() => email = val),
                        ),
                        SizedBox(height: 20),

                        // Password Field (Grey Rounded)
                        TextFormField(
                          style: GoogleFonts.poppins(), // Applied to input text
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: GoogleFonts.poppins(), // Applied to hint text
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          obscureText: true,
                          validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
                          onChanged: (val) => setState(() => password = val),
                        ),
                        SizedBox(height: 30),

                        // Login Button (Gold)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              loading ? "Loading..." : "Log in",
                              // Applied Poppins
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037), // Dark brown text
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                                if (result == null) {
                                  setState(() {
                                    error = 'Could not sign in with those credentials';
                                    loading = false;
                                  });
                                } else {
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        
                        // Error Message
                        if (error.isNotEmpty)
                          Text(error, style: GoogleFonts.poppins(color: Colors.red, fontSize: 14)),

                        SizedBox(height: 20),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ", style: GoogleFonts.poppins()),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                "Register now",
                                // Applied Poppins
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}