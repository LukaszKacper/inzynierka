import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/constants/routes.dart';
import 'package:untitled/main.dart';
import 'package:untitled/views/FaqView.dart';
import 'package:untitled/views/NotificationsView.dart';
import 'package:untitled/views/UpdateEmailView.dart';
import 'UpdatePasswordView.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool valueDarkTheme = false;
  bool valueNotifications = false;
  String? username = "";

  @override
  void initState() {
    super.initState();
    getUserDataFromFirebase();
  }

  void getUserDataFromFirebase() async {
    // Pobierz zalogowanego użytkownika
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Pobierz dodatkowe dane o użytkowniku z Firestore
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userData.exists) {
        setState(() {
          // Zaktualizuj stan username
          username = userData['username'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationsView()));
            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            SizedBox(height: 20),
            // Username
            if (username != null && username!.isNotEmpty)
              Center(
                child: Text(
                  'Welcome, $username!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            SizedBox(height: 10),
            // "How can we help you?" section
            Center(
              child: Text(
                'How can we help You?',
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            // "My Account" section
            buildSectionTitle("My Account"),
            buildOption(context, "Change Password", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdatePasswordView()),
              );
            }),
            buildOption(context, "Change Email", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UpdateEmailView()),
              );
            }),
            SizedBox(height: 20),
            // "Features" section
            buildSectionTitle("Features"),
            buildOption(context, "Calendar", () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => FaqView()),
              );
            }),
            buildOption(context, "Cards", () {
              Navigator.pushNamed(context, cardsRoute);
            }),
            SizedBox(height: 20),
            // "Support" section
            buildSectionTitle("Support"),
            buildOption(context, "FAQ", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaqView()),
              );
            }),
            buildOption(context, "Contact", () {
            }),
            SizedBox(height: 20),
            SizedBox(height: 20),
            // "Account Management" section
            buildSectionTitle("Account Management"),
            buildOption(context, "Close Account", () {
            }),
            SizedBox(height: 20),
            // Logout option
            buildLogoutOption(context),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  GestureDetector buildOption(BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  GestureDetector buildLogoutOption(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool confirmLogout = await showLogOutDialog(context);
        if (confirmLogout) {
          FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
          );
        }
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  "Logout",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.red),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are You sure that You want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ), TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out'),
            )
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
