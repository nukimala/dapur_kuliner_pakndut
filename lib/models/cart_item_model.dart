import 'menu_model.dart';

class CartItemModel {
  int? id;
  String menuId;
  int quantity;
  String userUid;
  MenuModel? menu; // This will hold the populated menu data when joining tables

  CartItemModel({
    this.id,
    required this.menuId,
    required this.quantity,
    required this.userUid,
    this.menu,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menu_id': menuId,
      'quantity': quantity,
      'user_uid': userUid,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map, {MenuModel? populatedMenu}) {
    return CartItemModel(
      id: map['id'],
      menuId: map['menu_id'],
      quantity: map['quantity'],
      userUid: map['user_uid'],
      menu: populatedMenu,
    );
  }
}
