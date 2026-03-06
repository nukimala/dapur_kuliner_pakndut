import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  String? id;
  String buyerUid;
  String buyerName;
  double totalPrice;
  String status;
  DateTime timestamp;
  List<Map<String, dynamic>> items;

  OrderModel({
    this.id,
    required this.buyerUid,
    required this.buyerName,
    required this.totalPrice,
    required this.status,
    required this.timestamp,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'buyerUid': buyerUid,
      'buyerName': buyerName,
      'totalPrice': totalPrice,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'items': items,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      id: documentId,
      buyerUid: map['buyerUid'] ?? '',
      buyerName: map['buyerName'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
    );
  }

  // Helper function to extract a simplified representation of the cart items for the DB
  static List<Map<String, dynamic>> cartItemsToMapList(List<CartItemModel> cartItems) {
    return cartItems.map((item) {
      return {
        'menuId': item.menuId,
        'menuName': item.menu?.name ?? 'Unknown',
        'menuPrice': item.menu?.price ?? 0,
        'quantity': item.quantity,
      };
    }).toList();
  }
}
