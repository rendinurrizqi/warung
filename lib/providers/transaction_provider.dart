import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String productName;
  final int qty;
  final int price;
  final DateTime time;

  TransactionModel({
    required this.id,
    required this.productName,
    required this.qty,
    required this.price,
    required this.time,
  });
}

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  int get totalToday {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.time.day == now.day &&
            t.time.month == now.month &&
            t.time.year == now.year)
        .fold(0, (sum, t) => sum + t.qty * t.price);
  }

  int get totalTransactions => _transactions.length;

  TransactionProvider() {
    _listenTransactions();
  }

  void _listenTransactions() {
    _db
        .collection('transactions')
        .orderBy('time', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) {
        return TransactionModel(
          id: doc.id,
          productName: doc['productName'] ?? '',
          qty: (doc['qty'] ?? 0) as int,
          price: (doc['price'] ?? 0) as int,
          time: (doc['time'] as Timestamp).toDate(),
        );
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addTransaction(String productName, int qty, int price) async {
    await _db.collection('transactions').add({
      'productName': productName,
      'qty': qty,
      'price': price,
      'time': Timestamp.now(),
    });
  }
}
