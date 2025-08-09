// booking.dart

class Booking {
  int? bookId;
  int? usrId;
  final DateTime bookDate;
  final DateTime bookTime;
  final DateTime eventDate;
  final DateTime eventTime;
  final int numGuests;
  final double packagePrice;
  final String menuPackage;
  final String function;

  Booking({
    this.bookId,
    this.usrId,
    required this.bookDate,
    required this.bookTime,
    required this.eventDate,
    required this.eventTime,
    required this.numGuests,
    required this.packagePrice,
    required this.menuPackage,
    required this.function,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'usrId': usrId,
      'bookdate': bookDate.toIso8601String(),
      'booktime': bookTime.toIso8601String(),
      'eventdate': eventDate.toIso8601String(),
      'eventtime': eventTime.toIso8601String(),
      'numguests': numGuests,
      'packageprice': packagePrice,
      'menupackage': menuPackage,
      'function': function,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      bookId: map['bookId'],
      usrId: map['usrId'],
      bookDate: DateTime.parse(map['bookdate']),
      bookTime: DateTime.parse(map['booktime']),
      eventDate: DateTime.parse(map['eventdate']),
      eventTime: DateTime.parse(map['eventtime']),
      numGuests: map['numguests'],
      packagePrice: map['packageprice'],
      menuPackage: map['menupackage'],
      function: map['function'],
    );
  }
}
