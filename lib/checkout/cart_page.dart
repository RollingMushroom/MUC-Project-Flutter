import 'package:flutter/material.dart';
import '../checkout/cart_item.dart';
import '../receipt/receipt.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  // ignore: library_private_types_in_public_api
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late double totalPrice;
  String discountCode = '';
  bool isDiscountApplied = false;
  double discountAmount = 0.0;
  double priceBeforeDiscount = 0.0;
  double priceAfterDiscount = 0.0;

  @override
  void initState() {
    super.initState();
    totalPrice = calculateTotalPrice();
    updatePrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
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
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Prompt dialog to empty the cart
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Empty Cart'),
                  content:
                      const Text('Are you sure you want to empty the cart?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          widget.cartItems.clear();
                          totalPrice = 0;
                          isDiscountApplied = false;
                          updatePrices();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Empty'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Dismissible(
                  key: Key(item.packageName),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      widget.cartItems.removeAt(index);
                      totalPrice = calculateTotalPrice();
                      updatePrices();
                    });
                  },
                  child: ListTile(
                    title: Text(item.packageName),
                    subtitle: Text('RM${item.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (widget.cartItems[index].quantity > 1) {
                                widget.cartItems[index].quantity--;
                                totalPrice = calculateTotalPrice();
                                updatePrices();
                              } else {
                                // Prompt dialog to remove item
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Item'),
                                    content: const Text(
                                      'Are you sure you want to remove this item from the cart?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            widget.cartItems.removeAt(index);
                                            totalPrice = calculateTotalPrice();
                                            updatePrices();
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            });
                          },
                        ),
                        Text(item.quantity.toString()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              widget.cartItems[index].quantity++;
                              totalPrice = calculateTotalPrice();
                              updatePrices();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Enter discount code',
                        ),
                        onChanged: (value) {
                          setState(() {
                            discountCode = value;
                          });
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (!isDiscountApplied && discountCode == 'mb1') {
                          setState(() {
                            totalPrice *= 0.9;
                            isDiscountApplied = true;
                            updatePrices();
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Invalid Discount Code'),
                              content: const Text(
                                'Please enter a valid discount code.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Apply Discount'),
                    ),
                  ],
                ),
                if (isDiscountApplied)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Discount applied: 10% off',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: RM${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.cartItems.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReceiptPage(
                                  cartItems: widget.cartItems,
                                  totalPrice: totalPrice,
                                  isDiscountApplied: isDiscountApplied,
                                  discountAmount: discountAmount,
                                  priceBeforeDiscount: priceBeforeDiscount,
                                  priceAfterDiscount: priceAfterDiscount,
                                ),
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Empty Cart'),
                                content: const Text('Your cart is empty.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Back',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.cartItems.isNotEmpty
                              ? Colors.lightBlue
                              : Colors.grey,
                        ),
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updatePrices() {
    // Calculate discount amount, price before discount, and price after discount
    double subtotal = calculateTotalPrice();
    double discount = isDiscountApplied ? subtotal * 0.1 : 0.0;
    double totalBeforeDiscount = subtotal;
    setState(() {
      discountAmount = discount;
      priceBeforeDiscount = totalBeforeDiscount;
      priceAfterDiscount = subtotal - discountAmount;
    });
  }

  double calculateTotalPrice() {
    double totalPrice = 0.0;
    for (var item in widget.cartItems) {
      totalPrice += (item.price * item.quantity);
    }
    return totalPrice;
  }
}
