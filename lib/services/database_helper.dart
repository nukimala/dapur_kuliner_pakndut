import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';
import '../models/cart_item_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dapur_pakndut_v2.db'); // Changed DB name to start fresh
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Cart Table Only
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_id TEXT,
        quantity INTEGER,
        user_uid TEXT
      )
    ''');
  }

  // --- CART OPERATIONS --- //

  Future<int> addToCart(CartItemModel cartItem) async {
    Database db = await database;
    // Check if item already in cart for this user
    final List<Map<String, dynamic>> existing = await db.query(
      'cart',
      where: 'menu_id = ? AND user_uid = ?',
      whereArgs: [cartItem.menuId, cartItem.userUid],
    );

    if (existing.isNotEmpty) {
      // Update quantity
      int currentQty = existing.first['quantity'];
      return await db.update(
        'cart',
        {'quantity': currentQty + cartItem.quantity},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // Insert new
      return await db.insert('cart', cartItem.toMap());
    }
  }

  Future<List<CartItemModel>> getCartItems(String userUid) async {
    Database db = await database;
    
    // Get all cart items from SQLite
    final List<Map<String, dynamic>> maps = await db.query(
        'cart',
        where: 'user_uid = ?',
        whereArgs: [userUid]
    );

    List<CartItemModel> cartItems = [];

    // For each cart item, fetch the corresponding Menu details from Firestore
    for(var map in maps) {
       CartItemModel item = CartItemModel.fromMap(map);
       
       try {
           DocumentSnapshot doc = await FirebaseFirestore.instance.collection('menus').doc(item.menuId).get();
           if (doc.exists) {
               item.menu = MenuModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
               cartItems.add(item);
           } else {
               // If menu was deleted from firestore by admin, remove from local cart
               await removeCartItem(item.id!);
           }
       } catch (e) {
           debugPrint("Error fetching menu for cart item: $e");
           // Add without populated menu if offline/error, handled by UI
           cartItems.add(item); 
       }
    }

    return cartItems;
  }

  Future<int> updateCartQuantity(int cartId, int newQuantity) async {
    Database db = await database;
    if (newQuantity <= 0) {
      return await removeCartItem(cartId);
    }
    return await db.update(
      'cart',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeCartItem(int cartId) async {
    Database db = await database;
    return await db.delete('cart', where: 'id = ?', whereArgs: [cartId]);
  }

  Future<int> clearCart(String userUid) async {
    Database db = await database;
    return await db.delete('cart', where: 'user_uid = ?', whereArgs: [userUid]);
  }
}
