import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/transaction_provider.dart';
import '../services/pdf_service_laporan_bulanan.dart';
import '../services/excel_service_laporan_bulanan.dart';

class LaporanBulananPage extends StatefulWidget {
  const LaporanBulananPage({super.key});

  @override
  State<LaporanBulananPage> createState() => _LaporanBulananPageState();
}

class _LaporanBulananPageState extends State<LaporanBulananPage> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final trxProvider = Provider.of<TransactionProvider>(context);
    final allTrx = trxProvider.transactions;

    final monthlyTrx = allTrx.where((t) {
      return t.time.month == selectedMonth && t.time.year == selectedYear;
    }).toList();

    final totalMonth =
        monthlyTrx.fold<int>(0, (sum, t) => sum + t.qty * t.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Bulanan Penjualan"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bulan: $selectedMonth | Tahun: $selectedYear",
                  style: const TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(selectedYear, selectedMonth),
                      firstDate: DateTime(2024, 1, 1),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedMonth = picked.month;
                        selectedYear = picked.year;
                      });
                    }
                  },
                  child: const Text("Pilih Bulan"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.blueGrey.shade900,
              child: ListTile(
                title: const Text("Total Pendapatan Bulan Ini"),
                trailing: Text(
                  "Rp $totalMonth",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.blueGrey.shade900,
              child: ListTile(
                title: const Text("Total Transaksi"),
                trailing: Text(
                  "${monthlyTrx.length}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Detail Transaksi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: monthlyTrx.isEmpty
                  ? const Center(
                      child: Text("Belum ada transaksi bulan ini"),
                    )
                  : ListView.builder(
                      itemCount: monthlyTrx.length,
                      itemBuilder: (context, index) {
                        final t = monthlyTrx[index];
                        final itemTotal = t.qty * t.price;
                        return Card(
                          child: ListTile(
                            title: Text("${t.productName} x${t.qty}"),
                            subtitle: Text(
                              "${t.time.day}/${t.time.month} "
                              "${t.time.hour.toString().padLeft(2, '0')}:"
                              "${t.time.minute.toString().padLeft(2, '0')}",
                            ),
                            trailing: Text("Rp $itemTotal"),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: monthlyTrx.isEmpty
                    ? null
                    : () async {
                        final pdfBytes = await PdfServiceLaporanBulanan
                            .generateMonthlyReport(
                          monthlyTrx,
                          selectedMonth,
                          selectedYear,
                        );
                        await Printing.layoutPdf(
                          onLayout: (_) => pdfBytes,
                        );
                      },
                child: const Text("Download PDF Laporan Bulanan"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: monthlyTrx.isEmpty
                    ? null
                    : () async {
                        final path =
                            await ExcelServiceLaporanBulanan.generateExcel(
                                monthlyTrx);
                        await Share.shareXFiles(
                          [XFile(path)],
                          text: "Laporan Bulanan WarungKu",
                        );
                      },
                child: const Text("Export Excel (.xlsx)"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
