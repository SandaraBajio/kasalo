import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; // For GPS
import 'package:geocoding/geocoding.dart';   // For Address Text
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'package:google_fonts/google_fonts.dart'; 

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Text Controllers (Needed to update text automatically)
  final TextEditingController _addressController = TextEditingController();

  // State variables
  String fullName = '';
  String contactNumber = '';
  String age = '';
  String email = '';
  String password = '';
  String error = '';
  bool loading = false;
  bool gettingLocation = false; // To show loading spinner on icon

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // --- FUNCTION: Get Current Location ---
  Future<void> _getCurrentLocation() async {
    setState(() => gettingLocation = true);
    try {
      // 1. Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => gettingLocation = false);
          return; // Permission denied
        }
      }

      // 2. Get GPS Position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // 3. Convert GPS to Address (Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );

      // 4. Format the address
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Example: "Batangas City, Calabarzon"
        String address = "${place.locality}, ${place.administrativeArea}"; 
        
        setState(() {
          _addressController.text = address; // Update the text field
        });
      }
    } catch (e) {
      print(e); // Handle errors
    } finally {
      setState(() => gettingLocation = false);
    }
  }

  // Helper for Input Style
  InputDecoration customInputDecoration(String label, {Widget? suffixIcon}) {
    // Colors from your design
    final Color borderColor = Color(0xFF7D5E00);
    final Color textColor = Color(0xFF5D4037);
    
    return InputDecoration(
      labelText: label,
      // Applied Poppins here for the placeholder labels
      labelStyle: GoogleFonts.poppins(color: textColor), 
      contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      suffixIcon: suffixIcon, // Add icon support
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: borderColor, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFFFFFDE7);
    final Color buttonColor = Color(0xFFF7E28C);
    final Color textColor = Color(0xFF7D5E00);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios, size: 18, color: textColor),
                    // Applied Poppins to Back Button
                    label: Text("Back", style: GoogleFonts.poppins(fontSize: 18, color: textColor)),
                  ),
                ],
              ),
            ),

            // Form Container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                ),
                margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Applied Poppins to Title
                        Text("SIGN UP", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB78A00))),
                        SizedBox(height: 30),

                        // Full Name
                        TextFormField(
                          decoration: customInputDecoration('Full name'),
                          style: GoogleFonts.poppins(), // Input text style
                          validator: (val) => val!.isEmpty ? 'Enter name' : null,
                          onChanged: (val) => setState(() => fullName = val),
                        ),
                        SizedBox(height: 15),

                        // Email
                        TextFormField(
                          decoration: customInputDecoration('Email'),
                          style: GoogleFonts.poppins(),
                          validator: (val) => val!.isEmpty ? 'Enter email' : null,
                          onChanged: (val) => setState(() => email = val),
                        ),
                        SizedBox(height: 15),

                        // Contact Number
                        TextFormField(
                          decoration: customInputDecoration('Contact Number'),
                          style: GoogleFonts.poppins(),
                          keyboardType: TextInputType.phone,
                          validator: (val) => val!.isEmpty ? 'Enter contact' : null,
                          onChanged: (val) => setState(() => contactNumber = val),
                        ),
                        SizedBox(height: 15),
                        
                        // Age
                        TextFormField(
                          decoration: customInputDecoration('Age'),
                          style: GoogleFonts.poppins(),
                          keyboardType: TextInputType.number,
                          validator: (val) => val!.isEmpty ? 'Enter age' : null,
                          onChanged: (val) => setState(() => age = val),
                        ),
                        SizedBox(height: 15),

                        // --- NEW ADDRESS FIELD WITH AUTO-DETECT ---
                        TextFormField(
                          controller: _addressController, // Use controller to update text
                          style: GoogleFonts.poppins(),
                          decoration: customInputDecoration(
                            'Address',
                            suffixIcon: IconButton(
                              icon: gettingLocation 
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                                : Icon(Icons.my_location, color: Color(0xFF7D5E00)),
                              onPressed: _getCurrentLocation, // Trigger detection
                            ),
                          ),
                          readOnly: false, // User can still type if they want
                          validator: (val) => val!.isEmpty ? 'Enter or detect address' : null,
                        ),
                        SizedBox(height: 15),

                        // Password
                        TextFormField(
                          decoration: customInputDecoration('Password'),
                          style: GoogleFonts.poppins(),
                          obscureText: true,
                          validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
                          onChanged: (val) => setState(() => password = val),
                        ),
                        SizedBox(height: 30),

                        // Register Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(
                              loading ? "Creating..." : "Register",
                              // Applied Poppins to Button Text
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => loading = true);
                                dynamic result = await _auth.registerWithEmailAndPassword(email, password);
                                if (result == null) {
                                  setState(() { error = 'Invalid email'; loading = false; });
                                } else {
                                  // SAVE ALL DATA TO FIRESTORE
                                  User? user = result;
                                  await DatabaseService(uid: user!.uid).updateUserData(
                                    fullName: fullName,
                                    contactNumber: contactNumber,
                                    age: age,
                                    address: _addressController.text, // Pass the detected address
                                  );
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        // Applied Poppins to Error Text
                        Text(error, style: GoogleFonts.poppins(color: Colors.red)),
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