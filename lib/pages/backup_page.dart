import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/backup_export_service.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final trxProvider = Provider.of<TransactionProvider>(context);

    final isOwner = auth.isOwner;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup & Export Data"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isOwner
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Backup Semua Data WarungKu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "File Excel akan berisi:\n"
                    "- Produk\n"
                    "- Transaksi\n"
                    "- Riwayat Stok",
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_download),
                      label: const Text("Export Semua Data ke Excel"),
                      onPressed: () async {
                        try {
                          final path = await BackupExportService.exportAllData(
                            products: productProvider.products,
                            transactions: trxProvider.transactions,
                            stockHistory: productProvider.history,
                          );

                          await Share.shareXFiles(
                            [XFile(path)],
                            text:
                                "Backup Data WarungKu - Produk, Transaksi, Riwayat Stok",
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Backup tersimpan di:\n$path"),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Gagal backup: $e"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              )
            : const Center(
                child: Text(
                  "Menu ini hanya bisa diakses oleh Owner.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }
}
