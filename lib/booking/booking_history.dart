import 'package:flutter/material.dart';
import 'edit_booking.dart'; // Import the EditBookingPage
import '../services/restaurantpack.dart'; // Import your database helper

class BookingHistory extends StatefulWidget {
  final int usrId;

  const BookingHistory({super.key, required this.usrId});

  @override
  // ignore: library_private_types_in_public_api
  _BookingHistoryState createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  late Future<List<Map<String, dynamic>>> _futureBookingHistory;

  @override
  void initState() {
    super.initState();
    // Initialize the future booking history when the widget is created
    _futureBookingHistory = _getBookingHistory();
  }

  Future<List<Map<String, dynamic>>> _getBookingHistory() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    // Fetch the booking history from the database for the given user ID
    return databaseHelper.getBookingHistory(widget.usrId);
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
          'Booking History',
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
                        Text('Booking Date: ${bookingData['bookdate']}'),
                        Text('Booking Time: ${bookingData['booktime']}'),
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
    );
  }
}
