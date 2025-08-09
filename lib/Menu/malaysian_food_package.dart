import 'package:flutter/material.dart';

class MalaysianFoodPackage extends StatelessWidget {
  final String packageName;
  final String description;
  final List<String> packageContents;
  final String imageUrl;
  final double price; // Add price field
  final VoidCallback onTap; // Add onTap parameter

  const MalaysianFoodPackage({
    super.key,
    required this.packageName,
    required this.description,
    required this.packageContents,
    required this.imageUrl,
    required this.price, // Add this line
    required this.onTap, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Call onTap function
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RM${price.toStringAsFixed(2)}', // Displaying price
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
