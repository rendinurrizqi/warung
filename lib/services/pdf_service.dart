// lib/services/pdf_service_penjualan.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../providers/transaction_provider.dart';

class PdfServicePenjualan {
  static Future<Uint8List> generateDailyReport(
    List<TransactionModel> items,
    DateTime date,
  ) async {
    final pdf = pw.Document();

    final total = items.fold<int>(0, (sum, t) => sum + (t.qty * t.price));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "WARUNGKU - LAPORAN PENJUALAN HARIAN",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "Tanggal: ${date.day}/${date.month}/${date.year}",
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),

              pw.Table.fromTextArray(
                headers: ["Produk", "Qty", "Harga", "Total"],
                data: items
                    .map(
                      (t) => [
                        t.productName,
                        t.qty.toString(),
                        "Rp ${t.price}",
                        "Rp ${t.qty * t.price}",
                      ],
                    )
                    .toList(),
              ),

              pw.SizedBox(height: 16),
              pw.Text(
                "Total Transaksi: ${items.length}",
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                "Total Pendapatan: Rp $total",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
