import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Menu/menudetailspage.dart';
import '../services/restaurantpack.dart';

class EditBookingAdminPage extends StatefulWidget {
  final int bookingId;
  final int userId;
  final Map<String, dynamic> bookingDetails;

  const EditBookingAdminPage({
    Key? key,
    required this.bookingId,
    required this.userId,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  _EditBookingAdminPageState createState() => _EditBookingAdminPageState();
}

class _EditBookingAdminPageState extends State<EditBookingAdminPage> {
  late TextEditingController _bookingDateController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventTimeController;
  late TextEditingController _numGuestsController;
  MalaysianFoodPackageModel? _selectedPackage;

  double totalPrice = 0.0;
  List<Map<String, Object>> _packages = [];

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate = controller.text.isEmpty
        ? DateTime.now()
        : DateFormat('yyyy-MM-dd').parse(controller.text);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay initialTime = controller.text.isEmpty
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(controller.text));
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _bookingDateController = TextEditingController(
        text: widget.bookingDetails['bookdate'] as String);
    _eventDateController = TextEditingController(
        text: widget.bookingDetails['eventdate'] as String);
    _eventTimeController = TextEditingController(
        text: widget.bookingDetails['eventtime'] as String);
    _numGuestsController = TextEditingController(
        text: (widget.bookingDetails['numguests'] as int).toString());
    _initializePackages();
  }

  void _initializePackages() {
    if (widget.bookingDetails['menupackage'] is String) {
      List<String> packageEntries =
          (widget.bookingDetails['menupackage'] as String).split(', ');
      _packages = packageEntries.map((entry) {
        List<String> parts = entry.split(':');
        return {
          'packageName': parts[0],
          'quantity': int.tryParse(parts[1]) ?? 0,
          'price': foodPackages
              .firstWhere((p) => p.packageName == parts[0],
                  orElse: () => MalaysianFoodPackageModel(
                      packageName: parts[0],
                      price: 0.0,
                      description: '',
                      imageUrl: '',
                      packageContents: []))
              .price,
        };
      }).toList();
    }
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    totalPrice = _packages.fold(
        0,
        (sum, item) =>
            sum + ((item['price'] as double) * (item['quantity'] as int)));
  }

  void _updatePackageQuantity(String packageName, int change) {
    int index = _packages.indexWhere((p) => p['packageName'] == packageName);
    if (index != -1 && index < _packages.length) {
      setState(() {
        _packages[index]['quantity'] =
            (_packages[index]['quantity'] as int) + change;
        if ((_packages[index]['quantity'] as int) <= 0) {
          _confirmRemovePackage(index);
        } else {
          _calculateTotalPrice();
        }
      });
    } else {
      print("Error: Tried to update quantity for non-existent index $index");
    }
  }

  void _addPackage(MalaysianFoodPackageModel? package) {
    if (package == null) return;

    int index =
        _packages.indexWhere((p) => p['packageName'] == package.packageName);
    if (index == -1) {
      setState(() {
        _packages.add({
          'packageName': package.packageName,
          'quantity': 1,
          'price': package.price,
        });
        _calculateTotalPrice();
      });
    } else {
      _updatePackageQuantity(package.packageName, 1);
    }
  }

  void _confirmRemovePackage(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Package'),
          content: Text(
              'Do you want to remove ${_packages[index]['packageName']} from the cart?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _packages.removeAt(index);
                  _calculateTotalPrice();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBooking() async {
    if (_packages.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please add at least one package to continue.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    Map<String, Object> updatedDetails = {
      'bookdate': _bookingDateController.text,
      'eventdate': _eventDateController.text,
      'eventtime': _eventTimeController.text,
      'menupackage': _packages
          .map((p) => "${p['packageName']}:${p['quantity']}")
          .join(', '),
      'numguests': int.parse(_numGuestsController.text),
      'packageprice': totalPrice.toStringAsFixed(2)
    };

    DatabaseHelper databaseHelper = DatabaseHelper();
    try {
      await databaseHelper.updateBooking(widget.bookingId, updatedDetails);
      _showUpdateConfirmation(updatedDetails);
    } catch (e) {
      _showErrorDialog();
    }
  }

  void _showUpdateConfirmation(Map<String, Object> details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Updated'),
          content:
              const Text('Booking details have been updated successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to update booking.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Booking Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color.fromARGB(255, 123, 70, 66),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _bookingDateController,
              decoration: InputDecoration(
                labelText: 'Booking Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, _bookingDateController),
                ),
              ),
              readOnly: true,
            ),
            TextField(
              controller: _eventDateController,
              decoration: InputDecoration(
                labelText: 'Event Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, _eventDateController),
                ),
              ),
              readOnly: true,
            ),
            TextField(
              controller: _eventTimeController,
              decoration: InputDecoration(
                labelText: 'Event Time',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _selectTime(context, _eventTimeController),
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<MalaysianFoodPackageModel>(
              value: _selectedPackage,
              onChanged: (newValue) {
                setState(() {
                  _selectedPackage = newValue;
                });
              },
              items: foodPackages.map((MalaysianFoodPackageModel package) {
                return DropdownMenuItem<MalaysianFoodPackageModel>(
                  value: package,
                  child: Text(
                      "${package.packageName} - RM ${package.price.toStringAsFixed(2)}"),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: "Add Package",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addPackage(_selectedPackage);
                setState(() {
                  _selectedPackage = null; // Reset the dropdown selection
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 123, 70, 66), // Button color
                shape: const StadiumBorder(), // Rounded corners
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Padding
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ..._packages.map((package) => ListTile(
                  title: Text(package['packageName'] as String),
                  subtitle: Text('Quantity: ${package['quantity']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updatePackageQuantity(
                          package['packageName'] as String,
                          -1,
                        ),
                      ),
                      Text('${package['quantity']}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updatePackageQuantity(
                            package['packageName'] as String, 1),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            ListTile(
              title: Text('Total Price: RM ${totalPrice.toStringAsFixed(2)}'),
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
                  mainAxisAlignment: MainAxisAlignment.end,
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
                            int currentGuests =
                                int.tryParse(_numGuestsController.text) ?? 1;
                            if (currentGuests > 1) {
                              currentGuests--;
                              _numGuestsController.text =
                                  currentGuests.toString();
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _numGuestsController.text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            int currentGuests =
                                int.tryParse(_numGuestsController.text) ?? 1;
                            currentGuests++;
                            _numGuestsController.text =
                                currentGuests.toString();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _updateBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 123, 70, 66), // Button color
                shape: const StadiumBorder(), // Rounded corners
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Padding
              ),
              child: const Text(
                'Update Booking',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookingDateController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    _numGuestsController.dispose();
    super.dispose();
  }
}
