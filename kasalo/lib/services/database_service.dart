import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  
  // We need the User ID (uid) to know which document to update
  DatabaseService({this.uid});

  // Collection Reference: This creates a folder named 'users' in your database
  final CollectionReference userCollection = 
      FirebaseFirestore.instance.collection('users');

  // 1. Save User Data
  // Requirements: Source [19] (Store additional user data: Full Name, Age/Contact)
  Future updateUserData(String fullName, String contactNumber, String age) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'contactNumber': contactNumber,
      'age': age, // Store age separately in the database
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Fetch User Data
  // Requirements: Source [23] (Fetch User Data for Home Screen)
  Future<DocumentSnapshot> getUserData() async {
    return await userCollection.doc(uid).get();
  }
}