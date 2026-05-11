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

  // Jika database belum ada, buat baru. Jika sudah ada, gunakan yang lama.
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
    // Membuat tabel 'cart' (keranjang) di penyimpanan memori HP (SQLite)
    // Kenapa pakai SQLite? Agar simpan keranjang tidak makan kuota internet Firebase.
    await db.execute('''
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        menu_id TEXT,
        quantity INTEGER,
        user_uid TEXT
      )
    ''');
  }

  // --- OPERASI KERANJANG (CART) --- //

  // Fungsi untuk memasukkan makanan ke dalam keranjang
  Future<int> addToCart(CartItemModel cartItem) async {
    Database db = await database;
    // 1. Cek dulu, apakah makanan ini sudah ada di keranjang untuk user tersebut?
    final List<Map<String, dynamic>> existing = await db.query(
      'cart',
      where: 'menu_id = ? AND user_uid = ?',
      whereArgs: [cartItem.menuId, cartItem.userUid],
    );

    if (existing.isNotEmpty) {
      // 2a. Jika sudah ada, jangan buat item baru, cukup tambahkan JUMLAHNYA (Quantity) saja
      int currentQty = existing.first['quantity'];
      return await db.update(
        'cart',
        {'quantity': currentQty + cartItem.quantity},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // 2b. Jika belum ada sama sekali, masukkan sebagai menu baru di keranjang
      return await db.insert('cart', cartItem.toMap());
    }
  }

  // Fungsi untuk menarik (melihat) semua isi keranjang
  Future<List<CartItemModel>> getCartItems(String userUid) async {
    Database db = await database;
    
    // 1. Ambil data mentah keranjang dari HP (hanya berisi ID menu dan Jumlah)
    final List<Map<String, dynamic>> maps = await db.query(
        'cart',
        where: 'user_uid = ?',
        whereArgs: [userUid]
    );

    List<CartItemModel> cartItems = [];

    // 2. Karena data di HP hanya ID, kita perlu mengambil Detail Makanannya (Nama, Harga) dari Firebase Firestore
    for(var map in maps) {
       CartItemModel item = CartItemModel.fromMap(map);
       
       try {
           DocumentSnapshot doc = await FirebaseFirestore.instance.collection('menus').doc(item.menuId).get();
           if (doc.exists) {
               // Gabungkan data keranjang HP dengan data Menu dari Firebase
               item.menu = MenuModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
               cartItems.add(item);
           } else {
               // Jika menu sudah dihapus oleh Admin, otomatis hapus juga dari keranjang user
               await removeCartItem(item.id!);
           }
       } catch (e) {
           debugPrint("Error fetching menu for cart item: $e");
           // Tetap tampilkan (walau error internet)
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
