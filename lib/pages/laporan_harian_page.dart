import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../services/pdf_service_penjualan.dart';

class LaporanHarianPage extends StatefulWidget {
  const LaporanHarianPage({super.key});

  @override
  State<LaporanHarianPage> createState() => _LaporanHarianPageState();
}

class _LaporanHarianPageState extends State<LaporanHarianPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final trxProvider = Provider.of<TransactionProvider>(context);
    final allTrx = trxProvider.transactions;

    final dailyTrx = allTrx.where((t) {
      return t.time.day == _selectedDate.day &&
          t.time.month == _selectedDate.month &&
          t.time.year == _selectedDate.year;
    }).toList();

    final totalDaily = dailyTrx.fold<int>(0, (sum, t) => sum + t.qty * t.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Harian Penjualan"),
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
                  "Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2024, 1, 1),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: const Text("Pilih Tanggal"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              color: Colors.blueGrey.shade900,
              child: ListTile(
                title: const Text("Total Pendapatan Hari Ini"),
                trailing: Text(
                  "Rp $totalDaily",
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
                  "${dailyTrx.length}",
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
              child: dailyTrx.isEmpty
                  ? const Center(
                      child: Text("Belum ada transaksi di tanggal ini"),
                    )
                  : ListView.builder(
                      itemCount: dailyTrx.length,
                      itemBuilder: (context, index) {
                        final t = dailyTrx[index];
                        final itemTotal = t.qty * t.price;
                        return Card(
                          child: ListTile(
                            title: Text("${t.productName} x${t.qty}"),
                            subtitle: Text(
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
                onPressed: dailyTrx.isEmpty
                    ? null
                    : () async {
                        final pdfBytes =
                            await PdfServicePenjualan.generateDailyReport(
                          dailyTrx,
                          _selectedDate,
                        );
                        await Printing.layoutPdf(
                          onLayout: (_) => pdfBytes,
                        );
                      },
                child: const Text("Download Laporan PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
