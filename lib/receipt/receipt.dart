import 'package:flutter/material.dart';
import '../checkout/cart_item.dart';
import '../reviews/rising_star.dart';
import '../reviews/reviews_page.dart';

class RatingHandler {
  static void rateOrder(BuildContext context, String review, double rating) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewsPage(
          userReview: review,
          userRating: rating,
          reviews: reviews,
        ),
      ),
    );
  }
}

class ReceiptPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  final bool isDiscountApplied;
  final double discountAmount;
  final double priceBeforeDiscount;
  final double priceAfterDiscount;

  const ReceiptPage({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
    required this.isDiscountApplied,
    required this.discountAmount,
    required this.priceBeforeDiscount,
    required this.priceAfterDiscount,
  }) : super(key: key);

  @override
  _ReceiptPageState createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  double _rating = 0.0; // Declare _rating variable
  String _review = ''; // Declare _review variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receipt',
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
              const Text(
                'Order Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Generate ListTile widgets directly
              ...widget.cartItems
                  .map((item) => ListTile(
                        title: Text(
                          item.packageName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Quantity: ${item.quantity}'),
                        trailing: Text(
                          'RM${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
              const SizedBox(height: 20),
              Text(
                'Total Price: RM${widget.priceBeforeDiscount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                'Discount Amount: RM${widget.discountAmount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                'Price After Discount: RM${widget.priceAfterDiscount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // "Rate this order" button below "Price After Discount"
              FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Rate this order',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // Adjust the font size
                            color: Colors.black,
                            // Change the color as needed
                          ),
                        ),
                        // Background color
                        content: SingleChildScrollView(
                          // Add SingleChildScrollView
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Please rate your experience:'),
                              RatingStars(
                                onRatingChanged: (double rating) {
                                  setState(() {
                                    _rating = rating;
                                  });
                                },
                              ),
                              const SizedBox(height: 10), // Adjust spacing
                              const Text('Leave a review:'),
                              TextFormField(
                                onChanged: (value) {
                                  setState(() {
                                    _review = value;
                                  });
                                },
                                maxLines: 1, // Adjust the number of lines
                                decoration: const InputDecoration(
                                  hintText: 'Type your review here...',
                                ),
                              ),
                              // Adjust spacing
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_rating == 0.0) {
                                        // Show a reminder dialog to rate the order
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Reminder'),
                                              content: const Text(
                                                  'A star rating is at least required to submit a review'),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        // Proceed with rating the order
                                        RatingHandler.rateOrder(
                                            context, _review, _rating);
                                      }
                                    },
                                    child: const Text('Submit'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate back to the menu details page
                                      Navigator.popUntil(
                                          context, ModalRoute.withName('/'));
                                    },
                                    child: const Text('No Thanks'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                label: const Text('Rate this order'),
                icon: const Icon(Icons.star),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
