import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../Profile/edit.dart';
import '../booking/booking_form.dart';
import '../booking/booking_history.dart';
import '../JsonModels/users.dart';
import 'malaysian_food_detail_page.dart';

class MalaysianFoodPackage extends StatelessWidget {
  final String packageName;
  final String description;
  final String imageUrl;
  final List<String> packageContents;
  final double price;
  final double rating;
  final VoidCallback onTap;

  const MalaysianFoodPackage({
    Key? key,
    required this.packageName,
    required this.description,
    required this.imageUrl,
    required this.packageContents,
    required this.price,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              packageName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  'RM${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8.0),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        if (index < rating) {
                          return const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 20.0,
                          );
                        } else {
                          return const Icon(
                            Icons.star_border,
                            color: Colors.yellow,
                            size: 20.0,
                          );
                        }
                      }),
                    ),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MenuDetailsPage extends StatefulWidget {
  Users user;
  final String name;
  final String email;
  final String phone;
  final String username;
  final String password;
  final int usrId;

  MenuDetailsPage({
    Key? key,
    required this.user,
    required this.name,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    required this.usrId,
  }) : super(key: key);

  @override
  _MenuDetailsPageState createState() => _MenuDetailsPageState();
}

class _MenuDetailsPageState extends State<MenuDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Packages',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
        leading: const Icon(Icons.restaurant_menu_rounded),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16.0),
                        for (var package in foodPackages)
                          MalaysianFoodPackage(
                            packageName: package.packageName,
                            description: package.description,
                            imageUrl: package.imageUrl,
                            packageContents: package.packageContents,
                            price: package.price,
                            rating: package.rating,
                            onTap: () => navigateToDetailPage(package),
                          ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      //bottom nav bar
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
            onTabChange: (index) async {
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
                      builder: (context) => BookingPage(
                        usrId: widget.usrId,
                      ), // Provide a valid userId
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
                  var updatedUser = await Navigator.push(
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

                  if (updatedUser != null) {
                    setState(() {
                      widget.user = updatedUser;
                    });
                  }
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

  void navigateToDetailPage(MalaysianFoodPackageModel meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MalaysianFoodDetailPage(
          user: widget.user,
          name: widget.name,
          email: widget.email,
          phone: widget.phone,
          username: widget.username,
          password: widget.password,
          packageName: meal.packageName,
          description: meal.description,
          imageUrl: meal.imageUrl,
          packageContents: meal.packageContents,
          price: meal.price,
          rating: meal.rating,
          isLoggedIn: isLoggedIn,
          usrId: widget.usrId,
        ),
      ),
    );
  }
}

class MalaysianFoodPackageModel {
  final String packageName;
  final String description;
  final String imageUrl;
  final List<String> packageContents;
  final double price;
  final double rating; // Added rating field

  MalaysianFoodPackageModel({
    required this.packageName,
    required this.description,
    required this.imageUrl,
    required this.packageContents,
    required this.price,
    this.rating = 0.0, // Default rating is set to 0
  });
}

final List<MalaysianFoodPackageModel> foodPackages = [
  MalaysianFoodPackageModel(
    packageName: 'Nasi Lemak Package',
    description:
        'Enjoy the authentic flavors of Malaysia with our Nasi Lemak Package!',
    imageUrl: 'assets/NasiLemakSET.png',
    packageContents: [
      '2 Nasi Lemak',
      '2 Hot Coffee',
      '4 pcs of Traditional Sweets and Desserts',
    ],
    price: 22.99,
    rating: 4.8,
  ),
  MalaysianFoodPackageModel(
    packageName: 'Roti Canai Package',
    description:
        'Indulge in the crispy goodness of Roti Canai with our Roti Canai Package!',
    imageUrl: 'assets/RotiCanaiSET.png',
    packageContents: [
      '2 Roti Canai',
      '2 Teh Tarik',
      '2 pcs of Curry Dip',
      '4 pcs of Prawn Fritters',
    ],
    price: 18.99,
    rating: 4.5,
  ),
  MalaysianFoodPackageModel(
    packageName: 'Mee Goreng Package',
    description:
        'Savor the spicy delights of Mee Goreng with our Mee Goreng Package!',
    imageUrl: 'assets/MeeGorengSET.png',
    packageContents: [
      '2 Mee Goreng',
      '2 Iced Milo',
      '2 Fried Egg',
      '2 slices of Chocolate Cake',
    ],
    price: 25.99,
    rating: 3.8,
  ),
  MalaysianFoodPackageModel(
    packageName: 'Asam Laksa Package',
    description:
        'Experience the authentic taste of Penang Asam Laksa with our instant noodles, featuring a tangy, spicy, and aromatic broth.',
    imageUrl: 'assets/AsamSet.png',
    packageContents: [
      '2 Asam Laksa',
      '2 Milk Tea',
      '2 hard boiled Eggs',
      '2 layered cake',
    ],
    price: 24.99,
    rating: 4.8,
  ),
];
