import 'package:flutter/material.dart';

class RatingStars extends StatefulWidget {
  final ValueChanged<double> onRatingChanged;

  const RatingStars({super.key, required this.onRatingChanged});

  @override
  // ignore: library_private_types_in_public_api
  _RatingStarsState createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
            widget.onRatingChanged(_rating);
          },
          child: Icon(
            _rating >= (index + 1) ? Icons.star : Icons.star_border,
            size: 40,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
