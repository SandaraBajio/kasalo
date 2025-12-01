import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
    final Color backgroundColor = Color(0xFFFFFDE7); // Light cream background
    final Color buttonColor = Color(0xFFF9E27F);     // Yellow/Gold button
    final Color textColor = Color(0xFF8D6E63);       // Brownish text

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
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.volunteer_activism, size: 60, color: textColor),
                      ),
                    ),
                    SizedBox(height: 10),
                    // "kasalo" Text (You can replace with image later)
                    Text(
                      "kasalo",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: buttonColor,
                        shadows: [Shadow(blurRadius: 1, color: Colors.black26, offset: Offset(1,1))]
                      ),
                    ),
                    SizedBox(height: 5),
                    // Slogan
                    Text(
                      "Share your Kindness",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA1887F),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM SECTION: White Container with Form ---
            Expanded(
              flex: 6, // Takes up 60% of space
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          "SIGN IN",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBCAAA4),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Email Field (Grey Rounded)
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "Email",
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
                          decoration: InputDecoration(
                            hintText: "Password",
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
                              style: TextStyle(
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
                          Text(error, style: TextStyle(color: Colors.red, fontSize: 14)),

                        SizedBox(height: 20),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                "Register now",
                                style: TextStyle(
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