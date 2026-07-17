class CartItem {
  final String name;
  final int price;
  int quantity;
  final String image;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        name: json['name'] as String,
        price: json['price'] as int,
        quantity: json['quantity'] as int,
        image: json['image'] as String,
      );
}
