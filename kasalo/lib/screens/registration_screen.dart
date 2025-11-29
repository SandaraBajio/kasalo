import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // State variables
  String fullName = '';
  String contactNumber = ''; // Separate variable
  String age = '';           // Separate variable
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // 1. Full Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                onChanged: (val) => setState(() => fullName = val),
              ),
              SizedBox(height: 20),

              // 2. NEW: Contact Number (Split)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone, // Numerical keyboard
                validator: (val) => val!.isEmpty ? 'Enter contact number' : null,
                onChanged: (val) => setState(() => contactNumber = val),
              ),
              SizedBox(height: 20),

              // 3. NEW: Age (Split)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number, // Numerical keyboard
                validator: (val) => val!.isEmpty ? 'Enter your age' : null,
                onChanged: (val) => setState(() => age = val),
              ),
              SizedBox(height: 20),

              // 4. Email
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) => setState(() => email = val),
              ),
              SizedBox(height: 20),

              // 5. Password
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
                onChanged: (val) => setState(() => password = val),
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 50), // Make button wide
                ),
                child: Text(
                  loading ? 'Registering...' : 'Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => loading = true);
                    
                    // Create User in Auth
                    dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                    
                    if (result == null) {
                      setState(() {
                        error = 'Please supply a valid email';
                        loading = false;
                      });
                    } else {
                      // UPDATED: Pass all 3 separate fields to the database
                      User? user = result;
                      await DatabaseService(uid: user!.uid).updateUserData(fullName, contactNumber, age);
                      
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  }
                },
              ),
              SizedBox(height: 12),
              
              Text(error, style: TextStyle(color: Colors.red, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}