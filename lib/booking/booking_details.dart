import 'package:flutter/material.dart';
import '../intro/intro_page.dart';
import 'package:intl/intl.dart';

class BookingDetails {
  String name;
  String address;
  String phone;
  String email;
  DateTime? dateTime;
  String additionalRequests;
  int guestQuantity;

  BookingDetails({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.dateTime,
    required this.additionalRequests,
    required this.guestQuantity,
  });
}

class BookingDetailsPage extends StatelessWidget {
  final BookingDetails bookingDetails;

  const BookingDetailsPage({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final formattedDateTime =
        DateFormat('dd/MM/yyyy hh:mm a').format(bookingDetails.dateTime!);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/avatar.png',
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailItem('Name', bookingDetails.name),
              _buildDetailItem('Address', bookingDetails.address),
              _buildDetailItem('Phone', bookingDetails.phone),
              _buildDetailItem('Email', bookingDetails.email),
              _buildDetailItem('Date & Time', formattedDateTime),
              _buildDetailItem(
                  'Additional Requests', bookingDetails.additionalRequests),
              _buildDetailItem(
                  'Number of Guests', bookingDetails.guestQuantity.toString()),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const IntroPage(),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

void extractBookingDetails({
  required BuildContext context,
  required String userName,
  required String userAddress,
  required String userPhone,
  required String userEmail,
  required DateTime? reservationDateTime,
  required String additionalRequests,
  required int guestQuantity,
}) {
  BookingDetails bookingDetails = BookingDetails(
    name: userName,
    address: userAddress,
    phone: userPhone,
    email: userEmail,
    dateTime: reservationDateTime,
    additionalRequests: additionalRequests,
    guestQuantity: guestQuantity,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookingDetailsPage(bookingDetails: bookingDetails),
    ),
  );
}
