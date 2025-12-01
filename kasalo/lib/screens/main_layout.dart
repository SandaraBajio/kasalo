import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import 'home_screen.dart';
import 'my_donations_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // 1. Current Tab Index
  int _selectedIndex = 0;

  // 2. List of Screens to switch between
  final List<Widget> _screens = [
    HomeScreen(),       // Index 0
    MyDonationsScreen(),// Index 1
    MessagesScreen(),   // Index 2
    ProfileScreen(),    // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. The Body switches based on index
      // IndexedStack preserves the state of each screen (so they don't reload when switching)
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // 4. The Bottom Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF7D5E00), // Dark Gold
        unselectedItemColor: Color(0xFFDBB051), // Light Gold
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFFFFF7D4), // Cream
        items: [
          // Home
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          
          // Donate
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism, size: 30),
            label: 'Donate',
          ),
          
          // Chat (With Red Badge for Unread Messages)
          BottomNavigationBarItem(
            icon: StreamBuilder<int>(
              // Listen to the total unread count from DatabaseService
              stream: DatabaseService(uid: FirebaseAuth.instance.currentUser?.uid).totalUnreadCount,
              builder: (context, snapshot) {
                int count = snapshot.data ?? 0;
                
                // If count is 0, just show the icon
                if (count == 0) {
                  return Icon(Icons.chat_bubble_outline, size: 28);
                }

                // If count > 0, show Badge
                return Badge(
                  label: Text('$count'),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  child: Icon(Icons.chat_bubble_outline, size: 28),
                );
              },
            ),
            label: 'Chat',
          ),
          
          // Profile
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}