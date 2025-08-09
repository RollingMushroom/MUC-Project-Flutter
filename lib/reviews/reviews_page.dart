import 'package:flutter/material.dart';

class PreMadeReview {
  final String review;
  final double rating;

  PreMadeReview({
    required this.review,
    this.rating = 0.0,
  });
}

final List<PreMadeReview> reviews = [
  PreMadeReview(
    review: 'The service was excellent!',
    rating: 5,
  ),
  PreMadeReview(
    review: 'Easy to navigate.',
    rating: 5,
  ),
  PreMadeReview(
    review: 'Great ambiance and friendly UI.',
    rating: 4,
  ),
  PreMadeReview(
    review: 'Hard to understand some steps.',
    rating: 3,
  ),
  PreMadeReview(
    review: 'Disappointing.',
    rating: 1,
  ),
  PreMadeReview(
    review: 'Amazing Experience!',
    rating: 5,
  ),
];

class ReviewsPage extends StatelessWidget {
  final List<PreMadeReview> reviews;
  final String? userReview;
  final double? userRating;

  const ReviewsPage({
    super.key,
    required this.reviews,
    this.userReview,
    this.userRating,
  });

  @override
  Widget build(BuildContext context) {
    final hasUserReview = userReview != null && userRating != null;
    final totalReviewCount = reviews.length + (hasUserReview ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reviews',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalReviewCount,
              itemBuilder: (context, index) {
                if (hasUserReview && index == 0) {
                  // Display user's review at the top
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStarRating(userRating!),
                        const SizedBox(height: 8),
                        Text(
                          userReview!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Adjust index for user review
                  final reviewIndex = hasUserReview ? index - 1 : index;
                  final review = reviews[reviewIndex];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStarRating(review.rating),
                        const SizedBox(height: 8),
                        Text(
                          review.review,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStarRating(double rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey,
        ),
      ),
    );
  }
}
