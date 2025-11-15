// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import 'backup_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final trxProvider = Provider.of<TransactionProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final monthlyTotals = List.generate(12, (_) => 0);

    for (var t in trxProvider.transactions) {
      monthlyTotals[t.time.month - 1] += t.qty * t.price;
    }

    final maxY = monthlyTotals.reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxY == 0 ? 10000.0 : maxY * 1.2;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard WarungKu"),
        centerTitle: true,
        actions: [
          if (auth.isOwner)
            IconButton(
              icon: const Icon(Icons.cloud_download),
              tooltip: "Backup & Export Data",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BackupPage()),
                );
              },
            ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.blueGrey.shade900,
              child: ListTile(
                title: const Text("Total Penjualan Hari Ini"),
                trailing: Text(
                  "Rp ${trxProvider.totalToday}",
                  style: const TextStyle(
                    fontSize: 20,
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
                  "${trxProvider.totalTransactions}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              "Grafik Penjualan Bulanan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: chartMaxY.toDouble(),
                  barGroups: List.generate(12, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyTotals[index].toDouble(),
                          width: 14,
                          gradient: const LinearGradient(
                            colors: [Colors.tealAccent, Colors.blueAccent],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final labels = [
                            "Jan",
                            "Feb",
                            "Mar",
                            "Apr",
                            "Mei",
                            "Jun",
                            "Jul",
                            "Agu",
                            "Sep",
                            "Okt",
                            "Nov",
                            "Des",
                          ];
                          final index = value.toInt();
                          if (index < 0 || index > 11) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Total Produk: ${productProvider.products.length}",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
