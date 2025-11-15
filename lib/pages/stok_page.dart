import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import 'history_stok_page.dart';

class StokPage extends StatelessWidget {
  const StokPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          auth.isOwner ? "Stok Produk (Owner)" : "Stok Produk (Karyawan)",
        ),
        centerTitle: true,
      ),
      floatingActionButton: auth.isOwner
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahProdukPage()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryStokPage(),
                  ),
                ),
                child: const Text("Riwayat Stok Masuk"),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: provider.products.isEmpty
                ? const Center(child: Text("Belum ada data produk"))
                : ListView.builder(
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final p = provider.products[index];
                      return Card(
                        child: ListTile(
                          title: Text(p.name),
                          subtitle: Text(
                            "Stok: ${p.stock} • Harga: Rp ${p.price}",
                          ),
                          trailing: auth.isOwner
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.blue),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => _AddStockDialog(
                                            id: p.id,
                                            productName: p.name,
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.green),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditProdukPage(
                                              productId: p.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        provider.deleteProduct(p.id);
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AddStockDialog extends StatefulWidget {
  final String id;
  final String productName;

  const _AddStockDialog({
    super.key,
    required this.id,
    required this.productName,
  });

  @override
  State<_AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<_AddStockDialog> {
  final qtyCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    return AlertDialog(
      title: Text("Tambah Stok - ${widget.productName}"),
      content: TextField(
        controller: qtyCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: "Jumlah akan ditambah"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
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
              widget.id,
              qty,
              widget.productName,
            );
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text("Simpan"),
        ),
      ],
    );
  }
}

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga Jual"),
            ),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stok Awal"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty ||
                    priceCtrl.text.isEmpty ||
                    stockCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lengkapi semua data")),
                  );
                  return;
                }
                await provider.addProduct(
                  nameCtrl.text,
                  int.parse(priceCtrl.text),
                  int.parse(stockCtrl.text),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Simpan Produk"),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProdukPage extends StatefulWidget {
  final String productId;

  const EditProdukPage({super.key, required this.productId});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final product =
        provider.products.firstWhere((e) => e.id == widget.productId);

    nameCtrl.text = product.name;
    priceCtrl.text = product.price.toString();
    stockCtrl.text = product.stock.toString();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga Jual"),
            ),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stok"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await provider.updateProduct(
                  widget.productId,
                  nameCtrl.text,
                  int.parse(priceCtrl.text),
                  int.parse(stockCtrl.text),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text("Simpan Perubahan"),
            ),
          ],
        ),
      ),
    );
  }
}
