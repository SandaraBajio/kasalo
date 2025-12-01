import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add this to pubspec.yaml if needed for formatting, or use basic string
import '../services/database_service.dart';

class AddDonationScreen extends StatefulWidget {
  @override
  _AddDonationScreenState createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController(); // New Controller for Date
  
  // State Variables
  String selectedUnit = 'pcs';
  String? selectedCategory;
  String? selectedCondition;
  DateTime? _selectedExpiryDate; // Store the actual date object
  
  List<File> _selectedImages = [];
  final int maxImages = 5; 
  
  bool loading = false;
  bool gettingLocation = false;
  bool _isPickingImage = false;

  final List<String> units = ['pcs', 'pack', 'set', 'kg', 'box'];

  // --- 1. CONFIGURATION: CATEGORIES & CONDITIONS ---
  final Map<String, List<String>> categoryConditions = {
    'Food': ['Fresh', 'Frozen', 'Canned', 'Sealed', 'Home-cooked'],
    'Beverages': ['New', 'Sealed', 'Powdered'],
    'Baby Essentials': ['Sealed', 'Unused'],
    'Clothing': ['New', 'Like New', 'Good Condition', 'Fair Condition', 'For Home Use'],
    'Hygiene': ['Sealed', 'Unused', 'Refill'],
    'Household Items': ['Brand New', 'Functional / Working', 'Minor Cosmetic Defects', 'Needs Repair'],
    'School Supplies': ['Brand New', 'Lightly Used', 'Functional'],
    'Pet Supplies': ['Sealed (Food)', 'Open Bag (Food)', 'New / Unused (Accessories)', 'Sanitized / Clean (Accessories)'],
  };

  // Categories that REQUIRE an expiration date
  final List<String> categoriesWithExpiry = ['Food', 'Beverages', 'Baby Essentials'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // --- 2. LOGIC: Date Picker ---
  Future<void> _pickExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Can't be in the past
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFA1770E), // Gold Header
              onPrimary: Colors.white,
              onSurface: Colors.brown,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        // Format: MM/DD/YYYY
        _expiryController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _pickImages() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null) {
        setState(() {
          int spaceLeft = maxImages - _selectedImages.length;
          if (spaceLeft > 0) {
            int countToAdd = pickedFiles.length > spaceLeft ? spaceLeft : pickedFiles.length;
            for (int i = 0; i < countToAdd; i++) {
              _selectedImages.add(File(pickedFiles[i].path));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Max $maxImages images allowed")));
          }
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));

  Future<void> _getCurrentLocation() async {
    setState(() => gettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _locationController.text = "${place.locality}, ${place.administrativeArea}";
        });
      }
    } catch (e) { print(e); } 
    finally { setState(() => gettingLocation = false); }
  }

  void _submitDonation() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please upload at least one image")));
        return;
      }
      
      setState(() => loading = true);
      try {
        DatabaseService db = DatabaseService(uid: user!.uid);
        
        List<String> imageUrls = [];
        for (var img in _selectedImages) {
          String url = await db.uploadImage(img);
          if (url.isNotEmpty) imageUrls.add(url);
        }
        
        await db.addDonation(
          title: _nameController.text,
          quantity: int.parse(_quantityController.text),
          unit: selectedUnit,
          category: selectedCategory!,
          condition: selectedCondition!,
          location: _locationController.text,
          imageUrls: imageUrls,
          expiryDate: _selectedExpiryDate, // Pass the date (can be null)
        );
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Donation Posted!")));
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error posting donation")));
      } finally {
        setState(() => loading = false);
      }
    }
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFFA1770E), fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Color(0xFFF9E27F), width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Color(0xFFA1770E), width: 2.0)),
      filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the conditions for the currently selected category
    // If none selected, list is empty
    List<String> currentConditions = selectedCategory != null 
        ? categoryConditions[selectedCategory]! 
        : [];

    // Check if we need to show Expiry Date
    bool showExpiry = selectedCategory != null && categoriesWithExpiry.contains(selectedCategory);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: Colors.brown), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Donation Form", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFA1770E))),
              SizedBox(height: 20),

              TextFormField(controller: _nameController, decoration: _inputDeco("Name of Item"), validator: (val) => val!.isEmpty ? "Required" : null),
              SizedBox(height: 15),

              Row(
                children: [
                  Expanded(flex: 2, child: TextFormField(controller: _quantityController, keyboardType: TextInputType.number, decoration: _inputDeco("Quantity"), validator: (val) => val!.isEmpty ? "Required" : null)),
                  SizedBox(width: 10),
                  Expanded(flex: 1, child: DropdownButtonFormField<String>(value: selectedUnit, decoration: _inputDeco("Unit"), items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(), onChanged: (val) => setState(() => selectedUnit = val!))),
                ],
              ),
              SizedBox(height: 15),

              // --- CATEGORY DROPDOWN ---
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: _inputDeco("Item Category"),
                // Use the keys from our Map
                items: categoryConditions.keys.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val;
                    selectedCondition = null; // RESET condition when category changes
                    _selectedExpiryDate = null; // Reset date
                    _expiryController.clear();
                  });
                },
                validator: (val) => val == null ? "Required" : null,
              ),
              SizedBox(height: 15),

              // --- DYNAMIC CONDITION DROPDOWN ---
              DropdownButtonFormField<String>(
                value: selectedCondition,
                decoration: _inputDeco("Condition"),
                // If no category selected, disable this (null items) or show empty list
                items: currentConditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCondition = val),
                validator: (val) => val == null ? "Required" : null,
                hint: Text(selectedCategory == null ? "Select Category First" : "Select Condition"),
              ),
              SizedBox(height: 15),

              // --- CONDITIONAL EXPIRY DATE FIELD ---
              if (showExpiry) ...[
                TextFormField(
                  controller: _expiryController,
                  readOnly: true, // Prevent manual typing
                  onTap: _pickExpiryDate, // Open Date Picker
                  decoration: _inputDeco("Expiry Date (MM/DD/YYYY)").copyWith(
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.brown)
                  ),
                  validator: (val) => val!.isEmpty ? "Required for this category" : null,
                ),
                SizedBox(height: 15),
              ],

              TextFormField(controller: _locationController, decoration: _inputDeco("Location").copyWith(suffixIcon: IconButton(icon: gettingLocation ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator()) : Icon(Icons.my_location, color: Colors.brown), onPressed: _getCurrentLocation)), validator: (val) => val!.isEmpty ? "Required" : null),
              SizedBox(height: 25),

              Text("Images (${_selectedImages.length}/$maxImages)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
              SizedBox(height: 10),
              
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      if (_selectedImages.length >= maxImages) return SizedBox();
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100, margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15), border: Border.all(color: Color(0xFFF9E27F), width: 2)),
                          child: Icon(Icons.add_a_photo, color: Color(0xFFA1770E), size: 30),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(width: 100, margin: EdgeInsets.only(right: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover))),
                        Positioned(top: 5, right: 15, child: GestureDetector(onTap: () => _removeImage(index), child: CircleAvatar(radius: 12, backgroundColor: Colors.white, child: Icon(Icons.close, size: 16, color: Colors.red))))
                      ],
                    );
                  },
                ),
              ),
              
              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFA1770E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: loading ? CircularProgressIndicator(color: Colors.white) : Text("Upload Donation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: loading ? null : _submitDonation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}