import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';

class InputPenjualanPage extends StatefulWidget {
  const InputPenjualanPage({super.key});

  @override
  State<InputPenjualanPage> createState() => _InputPenjualanPageState();
}

class _InputPenjualanPageState extends State<InputPenjualanPage> {
  int qty = 1;
  String? selectedProduct;

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final trxProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Input Penjualan")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Produk", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: selectedProduct,
              isExpanded: true,
              hint: const Text("Pilih produk"),
              items: productProvider.products.map((p) {
                return DropdownMenuItem(
                  value: p.id,
                  child: Text("${p.name} - Rp ${p.price}"),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedProduct = value),
            ),

            const SizedBox(height: 16),
            const Text("Jumlah", style: TextStyle(fontSize: 16)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: qty > 1 ? () => setState(() => qty--) : null,
                ),
                Text(qty.toString(), style: const TextStyle(fontSize: 22)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => qty++),
                ),
              ],
            ),

            const SizedBox(height: 25),

            /// TOMBOL SIMPAN TRANSAKSI
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedProduct == null
                    ? null
                    : () async {
                        final p = productProvider.products.firstWhere(
                          (e) => e.id == selectedProduct,
                        );

                        await trxProvider.addTransaction(p.name, qty, p.price);

                        await productProvider.addStock(p.id, -qty, p.name);

                        Navigator.pop(context);
                      },
                child: const Text("Simpan Transaksi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
