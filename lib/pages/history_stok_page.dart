import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class HistoryStokPage extends StatelessWidget {
  const HistoryStokPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final logs = provider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Stok Masuk"),
        centerTitle: true,
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text("Belum ada riwayat stok masuk"),
            )
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  child: ListTile(
                    title: Text("${log.productName} +${log.qty}"),
                    subtitle: Text(
                      "${log.time.day}/${log.time.month}/${log.time.year} "
                      "${log.time.hour.toString().padLeft(2, '0')}:"
                      "${log.time.minute.toString().padLeft(2, '0')}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
