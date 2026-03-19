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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Gagal memuat data: ${tx.error}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => tx.loadTransactions(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    final todayTotal = tx.todayTotal;
    final monthTotal = tx.monthTotal;
    final last7Days = tx.last7Days;
    final monthDays = tx.monthDays;
    final transactions = tx.transactions;

    final has7DaysData = last7Days.any((e) => e.value > 0);
    final hasMonthData = monthDays.any((e) => e.value > 0);

    return RefreshIndicator(
      onRefresh: () => tx.loadTransactions(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: ClayFadeSlide(
                  index: 0,
                  child: _StatCard(
                    icon: Icons.today_rounded,
                    title: 'Hari Ini',
                    value: formatRupiah(todayTotal),
                    color: ClayColors.warning,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClayFadeSlide(
                  index: 1,
                  child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Bulan Ini',
                    value: formatRupiah(monthTotal),
                    color: ClayColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClayFadeSlide(
            index: 2,
            child: ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: ClayColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '7 Hari Terakhir',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: has7DaysData
                        ? BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
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
                                    reservedSize: 24,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= last7Days.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          formatDateShort(last7Days[index].key),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
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
                                      width: 16,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }),
                            ),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                          )
                        : const _EmptyChart(
                            icon: Icons.bar_chart_rounded,
                            message: 'Belum ada transaksi\n7 hari terakhir',
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClayFadeSlide(
            index: 3,
            child: ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.show_chart_rounded,
                        color: ClayColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Grafik Bulan Ini',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: hasMonthData
                        ? LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
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
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: ClayColors.success.withAlpha(40),
                                  ),
                                  spots: List.generate(
                                    monthDays.length,
                                    (i) => FlSpot(
                                      i.toDouble(),
                                      monthDays[i].value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                          )
                        : const _EmptyChart(
                            icon: Icons.show_chart_rounded,
                            message: 'Belum ada transaksi\nbulan ini',
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClayFadeSlide(
            index: 4,
            child: ClayCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        color: ClayColors.secondary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Transaksi Terbaru',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'Belum ada transaksi',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...transactions.take(10).toList().asMap().entries.map((entry) {
                      final t = entry.value;
                      final date = t.createdAt != null
                          ? '${t.createdAt!.day}/${t.createdAt!.month} '
                              '${t.createdAt!.hour.toString().padLeft(2, '0')}:'
                              '${t.createdAt!.minute.toString().padLeft(2, '0')}'
                          : '-';
                      return ClayFadeSlide(
                        index: entry.key,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: ClayColors.success.withAlpha(30),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: ClayColors.success,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(date,
                                    style: const TextStyle(fontSize: 13)),
                              ),
                              Text(
                                formatRupiah(t.total),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: ClayColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyChart({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
