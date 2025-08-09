class CartItem {
  final String packageName;
  final double price;
  int quantity = 1;

  CartItem(this.packageName, this.price, {this.quantity = 1});
}
