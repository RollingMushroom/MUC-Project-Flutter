import 'package:flutter/material.dart';
import '../JsonModels/users.dart'; // Import your Users model
import '../services/restaurantpack.dart'; // Import your DatabaseHelper class

class Profile extends StatefulWidget {
  final String username; // Add a username parameter to the Profile widget

  Profile({required this.username}); // Constructor to receive the username

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Users currentUser; // Current user object
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize currentUser with the user's data when the widget initializes
    _getUserData(widget.username);
  }

  Future<void> _getUserData(String username) async {
    // Fetch user data from the database using the provided username
    currentUser = await DatabaseHelper().getUser(username);
    // Update text controllers with user data
    nameController.text = currentUser.name;
    emailController.text = currentUser.email;
    phoneController.text = currentUser.phone.toString();
    setState(() {}); // Update the UI with the fetched data
  }

  Future<void> _updateProfile() async {
    // Update user object with new data from text controllers
    currentUser.name = nameController.text;
    currentUser.email = emailController.text;
    currentUser.phone = int.parse(phoneController.text);

    // Update user data in the database
    await DatabaseHelper().updateUser(currentUser);

    // Show a dialog to indicate successful update
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Profile Updated"),
          content: const Text("Your profile has been successfully updated."),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Name:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Email:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Phone:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Enter your phone number',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
