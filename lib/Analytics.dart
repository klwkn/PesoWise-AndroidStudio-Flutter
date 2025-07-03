import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealTimeVerticalBarChart extends StatefulWidget {
  @override
  _RealTimeVerticalBarChartState createState() => _RealTimeVerticalBarChartState();
}

class _RealTimeVerticalBarChartState extends State<RealTimeVerticalBarChart> {
  Map<String, double> _monthlyTotals = {};

  @override
  void initState() {
    super.initState();
    _listenToTransactions();
  }

  void _listenToTransactions() {
    FirebaseFirestore.instance
        .collection('transaction')
        .snapshots()
        .listen((snapshot) {
      Map<String, double> monthlyTotals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('amount') && data.containsKey('date_time')) {
          final amount = (data['amount'] as num).toDouble();
          final timestamp = data['date_time'] as Timestamp;
          final date = timestamp.toDate();
          final monthKey = DateFormat('yyyy-MM').format(date);

          monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + amount;
        }
      }

      setState(() {
        _monthlyTotals = monthlyTotals;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_monthlyTotals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Monthly Transactions"),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final sortedKeys = _monthlyTotals.keys.toList()..sort();
    final maxAmount = _monthlyTotals.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Monthly Transactions"),
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Card(
            elevation: 4,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Monthly Total Amount",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                "${sortedKeys[group.x]}: ₱${rod.toY.toStringAsFixed(2)}",
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,

                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                int index = value.toInt();
                                if (index < 0 || index >= sortedKeys.length) return SizedBox();
                                final month = sortedKeys[index];
                                return Text(
                                  DateFormat('MMM').format(DateTime.parse(month + "-01")),
                                  style: TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: maxAmount / 4,
                              getTitlesWidget: (value, _) => Text("₱${value.toInt()}"),
                              reservedSize: 50,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: maxAmount / 4,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade300,
                            strokeWidth: 1,
                          ),
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(sortedKeys.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: _monthlyTotals[sortedKeys[i]]!,
                                width: 20,
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.teal,
                              ),
                            ],
                          );
                        }),
                        maxY: maxAmount + (maxAmount * 0.2),
                        groupsSpace: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.bar_chart, color: Colors.teal),
                      SizedBox(width: 6),
                      Text(
                        "Total ₱ amount deposited per month",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}