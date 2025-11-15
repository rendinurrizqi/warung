import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class TambahStokPage extends StatefulWidget {
  final String productId;
  final String productName;

  const TambahStokPage({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<TambahStokPage> createState() => _TambahStokPageState();
}

class _TambahStokPageState extends State<TambahStokPage> {
  final qtyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Stok - ${widget.productName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah tambah"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (qty <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jumlah harus > 0")),
                  );
                  return;
                }

                await provider.addStock(
                  widget.productId,
                  qty,
                  widget.productName,
                );

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
