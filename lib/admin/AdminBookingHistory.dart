import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../admin/user_list_view.dart';
import '../JsonModels/login.dart';
import '../booking/edit_booking.dart'; // Import the EditBookingPage
import '../services/restaurantpack.dart'; // Import your database helper

class AdminBookingHistory extends StatefulWidget {
  const AdminBookingHistory({Key? key}) : super(key: key);

  @override
  _AdminBookingHistoryState createState() => _AdminBookingHistoryState();
}

class _AdminBookingHistoryState extends State<AdminBookingHistory> {
  late Future<List<Map<String, dynamic>>> _futureBookingHistory;
  int _selectedIndex = 1; // Added to track the current tab index

  @override
  void initState() {
    super.initState();
    _futureBookingHistory = _getBookingHistory();
  }

  Future<List<Map<String, dynamic>>> _getBookingHistory() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    // Fetch all booking histories from the database
    return databaseHelper.getAllBookingHistories();
  }

  void _deleteBooking(int bookingId) async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    // Delete the booking from the database
    await databaseHelper.deleteBooking(bookingId);
    // Refresh the booking history after deletion
    setState(() {
      _futureBookingHistory = _getBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureBookingHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No booking history found.',
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> bookingData = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple[100],
                      child: const Icon(Icons.event, color: Colors.black),
                    ),
                    title: Text('${bookingData['function']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User ID: ${bookingData['usrId']}'),
                        Text('Booking Date: ${bookingData['bookdate']}'),
                        Text('Event Date: ${bookingData['eventdate']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            var updatedDetails = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditBookingPage(
                                  bookingId: bookingData['bookId'],
                                  bookingDetails: bookingData,
                                ),
                              ),
                            );
                            if (updatedDetails != null) {
                              setState(() {
                                // Force refresh the booking history
                                _futureBookingHistory = _getBookingHistory();
                              });
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            bool confirmDelete = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Booking'),
                                  content: const Text(
                                      'Are you sure you want to delete this booking?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmDelete) {
                              _deleteBooking(bookingData['bookId']);
                            }
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
            selectedIndex: _selectedIndex, // Highlight current tab
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
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
}
