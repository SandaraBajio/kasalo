import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // State variables for inputs
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Input: Email (Source 23) ---
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                // Validation: Source 23 (Real-time validation)
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) => setState(() => email = val),
              ),
              SizedBox(height: 20),

              // --- Input: Password (Source 23) ---
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
                onChanged: (val) => setState(() => password = val),
              ),
              SizedBox(height: 20),

              // --- Submit Login (Source 23) ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  loading ? 'Logging in...' : 'Log In',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    
                    // 1. Call Firebase Auth (Source 23)
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    
                    if (result == null) {
                      // 2. Error Handling (Source 23: "Credentials mismatch")
                      setState(() {
                        error = 'Could not sign in with those credentials';
                        loading = false;
                      });
                    } else {
                      // 3. Navigate to Home (Source 23)
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }
                },
              ),
              SizedBox(height: 12),
              
              // Error Message Display
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}