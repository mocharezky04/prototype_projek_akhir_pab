import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/clay_colors.dart';
import '../../widgets/clay_card.dart';
import '../../widgets/clay_fade_slide.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();

    if (tx.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tx.error != null) {
      return Center(child: Text('Gagal memuat data: ${tx.error}'));
    }

    final transactions = tx.transactions;
    final todayTotal = tx.todayTotal;
    final monthTotal = tx.monthTotal;
    final last7Days = tx.last7Days;
    final monthDays = tx.monthDays;

    return RefreshIndicator(
      onRefresh: () => tx.loadTransactions(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isWide)
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Penghasilan Hari Ini',
                        value: formatRupiah(todayTotal),
                        color: ClayColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Penghasilan Bulan Ini',
                        value: formatRupiah(monthTotal),
                        color: ClayColors.success,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _StatCard(
                      title: 'Penghasilan Hari Ini',
                      value: formatRupiah(todayTotal),
                      color: ClayColors.warning,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      title: 'Penghasilan Bulan Ini',
                      value: formatRupiah(monthTotal),
                      color: ClayColors.success,
                    ),
                  ],
                ),
          const SizedBox(height: 16),
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik 7 Hari Terakhir',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= last7Days.length) {
                                    return const SizedBox.shrink();
                                  }
                                  final date = last7Days[index].key;
                                  return Text(formatDateShort(date));
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(last7Days.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: last7Days[i].value,
                                  color: ClayColors.primary,
                                  width: 14,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            );
                          }),
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 20),
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grafik Bulan Ini',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          titlesData: const FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: ClayColors.success,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                              spots: List.generate(monthDays.length, (i) {
                                return FlSpot(i.toDouble(), monthDays[i].value);
                              }),
                            )
                          ],
                        ),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 16),
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaksi Terbaru',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (transactions.isEmpty)
                      const Center(child: Text('Belum ada transaksi'))
                    else
                      ...transactions.take(10).toList().asMap().entries.map((entry) {
                        final index = entry.key;
                        final t = entry.value;
                        final date = t.createdAt?.toString() ?? '-';
                        return ClayFadeSlide(
                          index: index,
                          child: ListTile(
                            title: Text(formatRupiah(t.total)),
                            subtitle: Text(date),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
