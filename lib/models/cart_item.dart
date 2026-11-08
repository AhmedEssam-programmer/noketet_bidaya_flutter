class CartItem {
  const CartItem({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  CartItem copyWith({String? productId, int? quantity}) {
    return CartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };

  static CartItem fromJson(Map<String, dynamic> json) {
    final rawQuantity = json['quantity'];
    final quantity = rawQuantity is int
        ? rawQuantity
        : int.tryParse(rawQuantity?.toString() ?? '') ?? 1;
    return CartItem(
      productId: (json['productId'] ?? '').toString(),
      quantity: quantity < 1 ? 1 : quantity,
    );
  }
}
