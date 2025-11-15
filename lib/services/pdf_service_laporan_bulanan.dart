import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../providers/transaction_provider.dart';

class PdfServiceLaporanBulanan {
  static Future<Uint8List> generateMonthlyReport(
    List<TransactionModel> items,
    int month,
    int year,
  ) async {
    final pdf = pw.Document();

    final total = items.fold<int>(0, (sum, t) => sum + (t.qty * t.price));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "WARUNGKU - LAPORAN PENJUALAN BULANAN",
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Bulan: $month/$year"),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ["Produk", "Qty", "Harga", "Total", "Tanggal"],
              data: items
                  .map(
                    (t) => [
                      t.productName,
                      t.qty.toString(),
                      "Rp ${t.price}",
                      "Rp ${t.qty * t.price}",
                      "${t.time.day}/${t.time.month}",
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Total Transaksi: ${items.length}"),
            pw.Text(
              "Total Pendapatan: Rp $total",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }
}
