import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/transaction_provider.dart';

class ExcelServiceLaporanBulanan {
  static Future<String> generateExcel(List<TransactionModel> items) async {
    final excel = Excel.createExcel();
    final sheet = excel['Laporan Bulanan'];

    sheet.appendRow(["Produk", "Qty", "Harga", "Total", "Tanggal"]);

    for (var t in items) {
      sheet.appendRow([
        t.productName,
        t.qty,
        t.price,
        t.qty * t.price,
        "${t.time.day}/${t.time.month}/${t.time.year}",
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/laporan_bulanan.xlsx";

    final fileBytes = excel.encode();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    return filePath;
  }
}
