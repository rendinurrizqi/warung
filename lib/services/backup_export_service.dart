// lib/services/backup_export_service.dart
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';

class BackupExportService {
  static Future<String> exportAllData({
    required List<ProductModel> products,
    required List<TransactionModel> transactions,
    required List<StockHistoryItem> stockHistory,
  }) async {
    final excel = Excel.createExcel();

    // SHEET PRODUK
    final sheetProduk = excel['Produk'];
    sheetProduk.appendRow(["ID", "Nama", "Harga", "Stok"]);

    for (var p in products) {
      sheetProduk.appendRow([p.id, p.name, p.price, p.stock]);
    }

    // SHEET TRANSAKSI
    final sheetTransaksi = excel['Transaksi'];
    sheetTransaksi.appendRow([
      "ID",
      "Produk",
      "Qty",
      "Harga",
      "Total",
      "Tanggal",
      "Jam",
    ]);

    for (var t in transactions) {
      sheetTransaksi.appendRow([
        t.id,
        t.productName,
        t.qty,
        t.price,
        t.qty * t.price,
        "${t.time.day}/${t.time.month}/${t.time.year}",
        "${t.time.hour.toString().padLeft(2, '0')}:${t.time.minute.toString().padLeft(2, '0')}",
      ]);
    }

    // SHEET RIWAYAT STOK
    final sheetHistory = excel['RiwayatStok'];
    sheetHistory.appendRow(["Produk", "Qty", "Tanggal", "Jam"]);

    for (var h in stockHistory) {
      sheetHistory.appendRow([
        h.productName,
        h.qty,
        "${h.time.day}/${h.time.month}/${h.time.year}",
        "${h.time.hour.toString().padLeft(2, '0')}:${h.time.minute.toString().padLeft(2, '0')}",
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        "${dir.path}/backup_warungku_${DateTime.now().millisecondsSinceEpoch}.xlsx";

    final bytes = excel.encode();
    if (bytes != null) {
      final file = File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
      return file.path;
    } else {
      throw Exception("Gagal membuat file Excel backup");
    }
  }
}
