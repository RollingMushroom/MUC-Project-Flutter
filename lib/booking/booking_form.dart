import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Menu/menudetailspage.dart';
import '../services/restaurantpack.dart';

class BookingPage extends StatefulWidget {
  final int usrId;

  const BookingPage({Key? key, required this.usrId}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  int guestCount = 1;
  String function = '';
  DateTime? reservationDateTime;
  List<SelectedPackage> selectedPackages = [];
  double totalPrice = 0.0;
  // Database Helper instance
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    reservationDateTime = DateTime.now();
  }

  void _calculateTotalPrice() {
    setState(() {
      totalPrice = selectedPackages.fold(
        0.0,
        (sum, item) => sum + (item.package.price * item.quantity),
      );
      totalPrice = double.parse(totalPrice.toStringAsFixed(2));
    });
  }

  Future<void> submitBooking() async {
    if (_formKey.currentState!.validate()) {
      if (function.isEmpty && selectedPackages.isEmpty) {
        // Show error message if address field is empty
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please select atleast one package and enter your function.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop submission if address field is empty
      }
      if (function.isEmpty) {
        // Show error message if no package is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your function.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop submission if no package is selected
      }
      if (selectedPackages.isEmpty) {
        // Show error message if no package is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one package.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop submission if no package is selected
      }

      try {
        double totalPrice = selectedPackages.fold(
          0.0,
          (sum, item) => sum + (item.package.price * item.quantity),
        );
        totalPrice = double.parse(totalPrice.toStringAsFixed(2));

        await _databaseHelper.insertBooking({
          'usrId': widget.usrId,
          'function': function,
          'bookdate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'booktime': DateFormat('hh:mm a').format(DateTime.now()),
          'eventdate': DateFormat('yyyy-MM-dd').format(reservationDateTime!),
          'eventtime': DateFormat('hh:mm a').format(reservationDateTime!),
          'numguests': guestCount,
          'packageprice': totalPrice,
          'menupackage': selectedPackages
              .map((e) => "${e.package.packageName}:${e.quantity}")
              .join(', '),
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your booking details submitted successfully:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    'Function: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(function),
                  const SizedBox(height: 10),
                  const Text(
                    'Date & Time: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(DateFormat('yyyy-MM-dd hh:mm a').format(reservationDateTime!)),
                  const SizedBox(height: 10),
                  const Text(
                    'Number of Guests: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(guestCount.toString()),
                  const SizedBox(height: 10),
                  const Text(
                    'Selected Packages:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedPackages.map((selectedPackage) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          '${selectedPackage.package.packageName} (Quantity: ${selectedPackage.quantity})',
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Total Price: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('RM ${totalPrice.toStringAsFixed(2)}'),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        // Log the error

        // Show error dialog
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to submit booking: $error'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) {
      setState(() {
        reservationDateTime = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        reservationDateTime = DateTime(
          reservationDateTime!.year,
          reservationDateTime!.month,
          reservationDateTime!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _addPackage(MalaysianFoodPackageModel package) {
    setState(() {
      final index = selectedPackages
          .indexWhere((selectedPackage) => selectedPackage.package == package);
      if (index != -1) {
        selectedPackages[index].quantity++;
      } else {
        selectedPackages.add(SelectedPackage(package: package, quantity: 1));
      }
      _calculateTotalPrice();
    });
  }

  void _removePackage(MalaysianFoodPackageModel package) {
    setState(() {
      final index = selectedPackages
          .indexWhere((selectedPackage) => selectedPackage.package == package);
      if (index != -1) {
        if (selectedPackages[index].quantity == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Removal'),
                content:
                    const Text('Are you sure you want to remove this package?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedPackages.removeAt(index);
                        _calculateTotalPrice();
                      });
                      Navigator.of(context).pop();
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                ],
              );
            },
          );
        } else {
          selectedPackages[index].quantity--;
        }
        _calculateTotalPrice();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Function',
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    hintText: 'What function are you having ? ',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    function = value;
                  },
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          reservationDateTime == null
                              ? 'Select Date'
                              : 'Date: ${DateFormat('yyyy-MM-dd').format(reservationDateTime!)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectTime(context),
                        child: Text(
                          reservationDateTime == null
                              ? 'Select Time'
                              : 'Time: ${DateFormat('hh:mm a').format(reservationDateTime!)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<MalaysianFoodPackageModel>(
                  decoration: const InputDecoration(
                    labelText: 'Select Package',
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  items: foodPackages
                      .map((package) => DropdownMenuItem(
                            value: package,
                            child: Text(package.packageName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _addPackage(value);
                    }
                  },
                ),
                const SizedBox(height: 20),
                Column(
                  children: selectedPackages.map((selectedPackage) {
                    return ListTile(
                      title: Text(
                        selectedPackage.package.packageName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'Price: RM ${selectedPackage.package.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () =>
                                _removePackage(selectedPackage.package),
                          ),
                          Text(
                            selectedPackage.quantity.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () =>
                                _addPackage(selectedPackage.package),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ListTile(
                  title:
                      Text('Total Price: RM ${totalPrice.toStringAsFixed(2)}'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Number of Guests:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 123, 70, 66),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                if (guestCount > 1) {
                                  guestCount--;
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Center(
                            child: Text(
                              guestCount.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 123, 70, 66),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                guestCount++;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 55.0,
                        vertical: 10.0,
                      ),
                      minimumSize: const Size(30, 15),
                      backgroundColor: const Color.fromARGB(255, 123, 70, 66),
                    ),
                    onPressed: submitBooking,
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedPackage {
  final MalaysianFoodPackageModel package;
  int quantity;

  SelectedPackage({required this.package, this.quantity = 1});
}
