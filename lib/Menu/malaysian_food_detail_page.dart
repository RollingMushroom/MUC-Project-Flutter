import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../JsonModels/users.dart';
import '../Menu/menudetailspage.dart';
import '../Profile/edit.dart';
import '../booking/booking_form.dart';

import '../booking/booking_history.dart';

class MalaysianFoodDetailPage extends StatefulWidget {
  final String? packageName;
  final String description;
  final List<String>? packageContents;
  final String imageUrl;
  final double price;
  final double rating;

  final int usrId;
  final Users user;
  final String name;
  final String email;
  final String phone;
  final String username;
  final String password;
  final bool isLoggedIn; // New parameter to check if the user is logged in

  const MalaysianFoodDetailPage({
    super.key,
    this.packageName,
    required this.description,
    this.packageContents,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.isLoggedIn,
    required this.user,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    required this.usrId, // Add the new parameter
  });

  @override
  // ignore: library_private_types_in_public_api
  _MalaysianFoodDetailPageState createState() =>
      _MalaysianFoodDetailPageState();
}

class _MalaysianFoodDetailPageState extends State<MalaysianFoodDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.packageName ?? 'Food Detail',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  widget.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Image not found'),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (widget.packageName != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.packageName!,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                for (int i = 0; i < 5; i++)
                                  Icon(
                                    i < widget.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Description: ${widget.description}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (widget.packageContents != null &&
                      widget.packageContents!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Package Contents:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (String content in widget.packageContents!)
                          Text(
                            content,
                            style: const TextStyle(fontSize: 16),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  Row(
                    children: [
                      Text(
                        'RM${widget.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      builder: (context) => MenuDetailsPage(
                        user: widget.user,
                        name: widget.name,
                        email: widget.email,
                        phone: widget.phone,
                        username: widget.username,
                        password: widget.password,
                        usrId: widget.usrId,
                      ),
                    ),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(usrId: widget.usrId),
                    ),
                  );
                  break;

                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingHistory(
                        usrId: widget.usrId,
                      ),
                    ),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileEditPage(
                        user: widget.user,
                        name: widget.name,
                        email: widget.email,
                        phone: widget.phone,
                        username: widget.username,
                        password: widget.password,
                      ),
                    ),
                  );
                  break;
              }
            },
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.restaurant_menu,
                text: 'Menu',
              ),
              GButton(
                icon: Icons.bookmark_add,
                text: 'Book Now!',
              ),
              GButton(
                icon: Icons.history,
                text: 'History',
              ),
              GButton(
                icon: Icons.account_box,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
