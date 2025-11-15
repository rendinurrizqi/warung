import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';

class StockHistoryItem {
  final String productName;
  final int qty;
  final DateTime time;

  StockHistoryItem({
    required this.productName,
    required this.qty,
    required this.time,
  });
}

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  List.StockHistoryItem> _history = [];
  List<StockHistoryItem> get history => _history;

  ProductProvider() {
    _listenProducts();
    _listenHistory();
  }

  void _listenProducts() {
    _db.collection('products').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        return ProductModel(
          id: doc.id,
          name: doc['name'] ?? '',
          price: (doc['price'] ?? 0) as int,
          stock: (doc['stock'] ?? 0) as int,
        );
      }).toList();
      notifyListeners();
    });
  }

  void _listenHistory() {
    _db
        .collection('stock_history')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      _history = snapshot.docs.map((doc) {
        return StockHistoryItem(
          productName: doc['productName'] ?? '',
          qty: (doc['qty'] ?? 0) as int,
          time: (doc['time'] as Timestamp).toDate(),
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addProduct(String name, int price, int stock) async {
    await _db.collection('products').add({
      'name': name,
      'price': price,
      'stock': stock,
    });
  }

  Future<void> updateProduct(
      String id, String name, int price, int stock) async {
    await _db.collection('products').doc(id).update({
      'name': name,
      'price': price,
      'stock': stock,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }

  Future<void> addStock(String id, int qty, String productName) async {
    await _db.collection('products').doc(id).update({
      'stock': FieldValue.increment(qty),
    });

    await _db.collection('stock_history').add({
      'productName': productName,
      'qty': qty,
      'time': Timestamp.now(),
    });
  }
}
