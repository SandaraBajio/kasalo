import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // --- CONFIGURATION ---
  // Replace with your actual Cloudinary values
  final String cloudName = "dxkbkzt6x"; 
  final String uploadPreset = "kasalo_preset"; 

  // --- 1. UPLOAD IMAGE (Cloudinary) ---
  Future<String> uploadImage(File imageFile) async {
    try {
      var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      var request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print("Upload Error: $e");
      return '';
    }
  }

  // --- 2. DONATION FUNCTIONS ---
  // UPDATED: Now accepts List<String> imageUrls
  Future<void> addDonation({
    required String title,
    required int quantity,
    required String unit,
    required String category,
    required String condition,
    required String location,
    required List<String> imageUrls, // CHANGED THIS
    DateTime? expiryDate,
  }) async {
    await FirebaseFirestore.instance.collection('donations').add({
      'donorId': uid,
      'title': title,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'condition': condition,
      'location': location,
      'imageUrls': imageUrls, // Store as a list
      'expiryDate': expiryDate,
      'status': 'Available',
      'createdAt': FieldValue.serverTimestamp(),
      'requesterId': null,
    });
  }

  // Stream: All Donations
  // 1. UPDATED: Get ONLY Available donations for the Home Feed
  Stream<QuerySnapshot> get donations {
    return FirebaseFirestore.instance
        .collection('donations')
        .where('status', isEqualTo: 'Available') // FILTER ADDED
        .snapshots();
  }

  // 2. NEW: Function to update status (or delete)
  Future<void> updateDonationStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('donations').doc(docId).update({
      'status': newStatus,
    });
  }

  Future<void> deleteDonation(String docId) async {
    await FirebaseFirestore.instance.collection('donations').doc(docId).delete();
  }
  
  // Stream: My Donations
  Stream<QuerySnapshot> get userDonations {
    return FirebaseFirestore.instance.collection('donations').where('donorId', isEqualTo: uid).snapshots();
  }

  // Stream: My Requests
  Stream<QuerySnapshot> get userRequests {
    return FirebaseFirestore.instance.collection('donations').where('requesterId', isEqualTo: uid).snapshots();
  }

  // --- 3. USER FUNCTIONS ---
  Future updateUserData({required String fullName, required String contactNumber, required String age, required String address}) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'contactNumber': contactNumber,
      'age': age,
      'address': address,
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserData() async {
    return await userCollection.doc(uid).get();
  }

  // --- 4. CHAT FUNCTIONS (The Missing Parts) ---

  // START CHAT: Checks if chat exists, if not creates one
  // UPDATED: Now accepts itemImageUrl
  Future<String> createChat(String otherUserId, String itemId, String itemTitle, String itemImageUrl) async {
    QuerySnapshot existingChat = await FirebaseFirestore.instance
        .collection('chats')
        .where('itemId', isEqualTo: itemId)
        .where('participants', arrayContains: uid)
        .get();

    for (var doc in existingChat.docs) {
      List participants = doc['participants'];
      if (participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat with Image URL
    DocumentReference ref = await FirebaseFirestore.instance.collection('chats').add({
      'participants': [uid, otherUserId],
      'itemId': itemId,
      'itemTitle': itemTitle,
      'itemImageUrl': itemImageUrl, // NEW FIELD
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // SEND MESSAGE (Updated to accept receiverId for unread count)
  Future<void> sendMessage(String chatId, String text, String receiverId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': uid,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false, // NEW: Default to unread
    });

    // Update Chat Metadata & Increment Unread for Receiver
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unread_$receiverId': FieldValue.increment(1), 
    });
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // GET MY CHATS
  Stream<QuerySnapshot> get userChats {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // *** THIS WAS MISSING: Mark Chat as Read ***
  Future<void> markChatAsRead(String chatId) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'unread_$uid': 0, // Reset MY unread count to 0
    });

  //B. Find all unread messages sent by the OTHER person
    var snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: uid) // Only mark theirs as read
        .get();

        // C. Update them to true (Batch write for performance)
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }



  // *** THIS WAS MISSING: Get Total Unread Count ***
  Stream<int> get totalUnreadCount {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            // Sum up all 'unread_MYID' fields
            // We use (doc.data() as Map) to safely access the field
            var data = doc.data() as Map<String, dynamic>;
            total += (data['unread_$uid'] ?? 0) as int;
          }
          return total;
        });
  }
}