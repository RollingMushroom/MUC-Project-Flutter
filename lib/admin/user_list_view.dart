import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../JsonModels/users.dart';
import '../services/restaurantpack.dart';
import '../admin/edit.dart';
import '../admin/AdminBookingHistory.dart';
import '../JsonModels/login.dart';

class UserListView extends StatefulWidget {
  const UserListView({super.key});

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  late Future<List<Users>> _users;

  @override
  void initState() {
    super.initState();
    _users = DatabaseHelper().getAllUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _users = DatabaseHelper().getAllUsers();
    });
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
        leading: const Icon(Icons.admin_panel_settings_outlined),
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
                          onPressed: () async {
                            var updatedUser = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileEditPage(
                                  user: user,
                                  name: user.name,
                                  email: user.email,
                                  phone: user.phone != null
                                      ? user.phone.toString()
                                      : '',
                                  username: user.username,
                                  password: user.password,
                                ),
                              ),
                            );
                            if (updatedUser != null) {
                              setState(() {
                                _users = DatabaseHelper().getAllUsers();
                              });
                            }
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListView(),
                    ),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminBookingHistory(),
                    ),
                  );
                  break;
                case 2:
                  _showLogoutConfirmationDialog(context);
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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete user
  void _deleteUser(BuildContext context, Users user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete ${user.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                int? userId = user.usrId;
                if (userId != null) {
                  await DatabaseHelper().deleteUser(userId);
                  Navigator.of(context).pop();
                  setState(() {
                    _users = DatabaseHelper().getAllUsers(); // Refresh the list
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
