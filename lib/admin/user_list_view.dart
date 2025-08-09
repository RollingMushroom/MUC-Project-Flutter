import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../JsonModels/users.dart'; // Import your Users model
import '../JsonModels/booking.dart'; // Import your Booking model
import '../services/restaurantpack.dart'; // Import your DatabaseHelper class
import '../JsonModels/login.dart';
import '../admin/edit.dart';
import '../admin/adminhistory.dart';

class UserListView extends StatefulWidget {
  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late Future<List<Users>> _users;
  late Future<List<Booking>> _bookings;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadBookings();
  }

  Future<void> _loadUsers() async {
    _users = DatabaseHelper()
        .getAllUsers(); // Implement getAllUsers() method in DatabaseHelper
  }

  Future<void> _loadBookings() async {
    _bookings = DatabaseHelper()
        .getAllBookings(); // Implement getAllBookings() method in DatabaseHelper
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registered Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
        leading: const Icon(
            Icons.admin_panel_settings_outlined), // Static icon for display
      ),
      body: FutureBuilder<List<Users>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Users>? users = snapshot.data;
            return ListView.builder(
              itemCount: users?.length ?? 0,
              itemBuilder: (context, index) {
                Users user = users![index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.account_circle),
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editUser(context, user);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteUser(context, user);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            onTabChange: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                 /* Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminBookingHistory(
                        usrId: booking.usrId,
                        bookId: booking.bookId,
                      ),
                    ),
                  );*/
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                  break;
              }
            },
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.restaurant_menu,
                text: 'Registered User',
              ),
              GButton(
                icon: Icons.bookmark_add,
                text: 'Booking',
              ),
              GButton(
                icon: Icons.logout_sharp,
                text: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBookingHistory(BuildContext context) async {
    // Assuming the first booking for the example, modify as needed
    var bookings = await _bookings;
    if (bookings.isNotEmpty) {
      Booking booking = bookings[
          0]; // Replace with appropriate logic to get the correct booking
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => AdminBookingHistory(
            usrId: booking.usrId,
            bookId: booking.bookId,
          ),
        ),
      );
    }
  }

  // Function to edit user
  void _editUser(BuildContext context, Users user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileEditPage(
          user: user,
          name: user.name,
          email: user.email,
          phone: user.phone != null ? user.phone.toString() : '',
          username: user.username,
          password: user.password,
        ),
      ),
    ).then((_) {
      setState(() {
        _loadUsers();
      });
    });
  }

  // Function to delete user
  void _deleteUser(BuildContext context, Users user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete ${user.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                int? userId = user.usrId;
                if (userId != null) {
                  await DatabaseHelper().deleteUser(userId);
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  setState(() {
                    _loadUsers();
                  });
                } else {
                  // Handle the case when user.usrId is null
                }
              },
            ),
          ],
        );
      },
    );
  }
}
