import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:project1/services/auth_service.dart';
import 'package:project1/services/transaction_service.dart';
import 'dart:math';

class MonthlyData {
  final DateTime date;
  final double income;
  final double expenses;

  MonthlyData({
    required this.date,
    required this.income,
    required this.expenses,
  });
}

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();
  
  User? currentUser;
  List<MonthlyData> monthlyData = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserDataAndTransactions();
  }
  
  Future<void> _loadUserDataAndTransactions() async {
    setState(() {
      isLoading = true;
    });
    
    // Get the current user
    currentUser = await _authService.getCurrentUser();
    
    if (currentUser != null) {
      // Generate the last 7 months of data (6 previous + current)
      final now = DateTime.now();
      final List<MonthlyData> generatedData = [];
      
      // Random number generator for historical data
      final random = Random();
      
      // Get current month's actual data
      final currentMonthIncome = await _transactionService.getMonthlyTotalByType(
        currentUser!.id!, 
        'income',
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0),
      );
      
      final currentMonthExpenses = await _transactionService.getMonthlyTotalByType(
        currentUser!.id!,
        'expense',
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month + 1, 0),
      );
      
      // Add current month's actual data
      generatedData.add(MonthlyData(
        date: DateTime(now.year, now.month, 1),
        income: currentMonthIncome,
        expenses: currentMonthExpenses,
      ));
      
      // Generate random data for previous 6 months
      for (int i = 1; i <= 6; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        
        // Generate random values
        // For income, generate between 1500 and 4000
        final randomIncome = 1500.0 + random.nextDouble() * 2500.0;
        
        // For expenses, generate between 40% and 90% of the income
        final randomExpensePercentage = 0.4 + random.nextDouble() * 0.5;
        final randomExpenses = randomIncome * randomExpensePercentage;
        
        generatedData.add(MonthlyData(
          date: monthDate,
          income: randomIncome,
          expenses: randomExpenses,
        ));
      }
      
      // Sort by date (older to newer)
      generatedData.sort((a, b) => a.date.compareTo(b.date));
      
      setState(() {
        monthlyData = generatedData;
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color cardColor = isDarkMode ? Colors.black : Colors.white;
    final Color expenseColor = Colors.blue;
    final Color incomeColor = Colors.red.shade300;
    final Color warningColor = Colors.red;
    
    return Scaffold(
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserDataAndTransactions,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Area Chart Card
                    Card(
                      color: cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Financial Overview',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: LineChart(_buildAreaChartData(
                                expenseColor, 
                                incomeColor,
                                textColor,
                                isDarkMode
                              )),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(expenseColor, 'Expenses', textColor),
                                const SizedBox(width: 24),
                                _buildLegendItem(incomeColor, 'Income', textColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Monthly Financial Summary
                    Card(
                      color: cardColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Financial Summary',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Income bar chart
                            Text('Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: BarChart(_buildBarChartData(
                                true, 
                                expenseColor, 
                                textColor,
                                isDarkMode,
                                warningColor
                              )),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Expenses bar chart
                            Text('Expenses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: BarChart(_buildBarChartData(
                                false, 
                                incomeColor, 
                                textColor,
                                isDarkMode,
                                warningColor
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  bool _isOverspendingMonth(MonthlyData data) {
    return data.expenses > data.income;
  }

  LineChartData _buildAreaChartData(
    Color expenseColor, 
    Color incomeColor,
    Color textColor,
    bool isDarkMode,
  ) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1000,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: textColor.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: textColor.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MMM').format(monthlyData[value.toInt()].date),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  value >= 1000 ? '\$${(value/1000).toStringAsFixed(1)}k' : '\$${value.toInt()}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: textColor.withOpacity(0.2), width: 1),
      ),
      minX: 0,
      maxX: monthlyData.length - 1.0,
      minY: 0,
      maxY: _getMaxY() * 1.1, // Add 10% padding
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              final isIncome = barSpot.barIndex == 1; // Income is the second line (index 1)
              
              return LineTooltipItem(
                isIncome 
                  ? 'Income: \$${monthlyData[index].income.toStringAsFixed(2)}'
                  : 'Expenses: \$${monthlyData[index].expenses.toStringAsFixed(2)}',
                TextStyle(
                  color: isIncome ? incomeColor : expenseColor,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        // Expenses Line
        LineChartBarData(
          spots: List.generate(monthlyData.length, 
            (i) => FlSpot(i.toDouble(), monthlyData[i].expenses)),
          isCurved: true,
          color: expenseColor,
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: expenseColor.withOpacity(0.3),
          ),
        ),
        // Income Line
        LineChartBarData(
          spots: List.generate(monthlyData.length, 
            (i) => FlSpot(i.toDouble(), monthlyData[i].income)),
          isCurved: true,
          color: incomeColor,
          barWidth: 3,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: incomeColor.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  BarChartData _buildBarChartData(
    bool isIncome, 
    Color barColor, 
    Color textColor,
    bool isDarkMode,
    Color warningColor,
  ) {
    // Calculate the appropriate max Y value based on actual data
    double calculatedMaxY = 0;
    
    if (isIncome) {
      calculatedMaxY = monthlyData.map((data) => data.income).reduce((a, b) => a > b ? a : b);
      // Add 20% padding to ensure bars don't hit the top
      calculatedMaxY = calculatedMaxY * 1.2;
    } else {
      calculatedMaxY = monthlyData.map((data) => data.expenses).reduce((a, b) => a > b ? a : b);
      // Add 20% padding to ensure bars don't hit the top
      calculatedMaxY = calculatedMaxY * 1.2;
    }
    
    // Create more appropriate intervals for Y axis
    // For expenses graph, use 500 or 1000 intervals depending on the max value
    final interval = calculatedMaxY > 4000 ? 1000.0 : 
                    calculatedMaxY > 2000 ? 500.0 : 250.0;
    
    return BarChartData(
      barGroups: List.generate(
        monthlyData.length,
        (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: isIncome 
                ? monthlyData[i].income 
                : monthlyData[i].expenses,
              // Use warning color for the month where expenses > income
              color: _isOverspendingMonth(monthlyData[i]) && !isIncome
                  ? warningColor  // Expenses bar becomes red for overspending month
                  : barColor,     // Normal color otherwise
              width: 14,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: calculatedMaxY,
                color: textColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MMM').format(monthlyData[value.toInt()].date),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: interval, // Set specific interval for y-axis labels
            getTitlesWidget: (value, meta) {
              // Only show specific values to avoid overcrowding
              if (value % interval != 0 && value != 0) {
                return const SizedBox.shrink();
              }
              
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  value >= 1000 ? '\$${(value/1000).toStringAsFixed(1)}k' : '\$${value.toInt()}',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        horizontalInterval: interval, // Match grid lines with our intervals
        getDrawingHorizontalLine: (value) => FlLine(
          color: textColor.withOpacity(0.1),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.8),
          tooltipRoundedRadius: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              isIncome 
                ? 'Income: \$${monthlyData[group.x].income.toStringAsFixed(2)}'
                : 'Expenses: \$${monthlyData[group.x].expenses.toStringAsFixed(2)}',
              TextStyle(
                color: isIncome ? barColor : rod.color,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  double _getMaxY() {
    double maxIncome = monthlyData.map((data) => data.income).reduce((a, b) => a > b ? a : b);
    double maxExpenses = monthlyData.map((data) => data.expenses).reduce((a, b) => a > b ? a : b);
    return maxIncome > maxExpenses ? maxIncome : maxExpenses;
  }
}
