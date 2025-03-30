import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  // Generate the last 7 months of data starting from a specified date
  final DateTime currentDate = DateTime(2025, 3, 30); // March 30, 2025
  late final List<MonthlyData> monthlyData;
  
  @override
  void initState() {
    super.initState();
    monthlyData = _generateSampleData();
  }
  
  List<MonthlyData> _generateSampleData() {
    final List<MonthlyData> data = [];
    
    // Month names starting from September
    final List<String> months = ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar'];
    
    // Create sample data with December showing overspending (expenses > income)
    for (int i = 0; i < 7; i++) {
      double expenses, income;
      
      if (months[i] == 'Dec') {
        // December shows overspending
        expenses = 1500; // Higher expenses
        income = 1200;   // Lower income
      } else if (months[i] == 'Jan' || months[i] == 'Feb') {
        // January and February have lower values
        expenses = 400 + (i * 20);
        income = 600 + (i * 30);
      } else {
        expenses = 700 + (i * 50) + (100 * (i % 3));
        income = 1200 + (i * 70) - (50 * (i % 2));
      }
      
      // Create a dip in income during January
      if (months[i] == 'Jan') {
        income = 500;
      }
      
      data.add(MonthlyData(
        months[i],
        expenses,
        income,
      ));
    }
    
    return data;
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
              
              // Reports section
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
                          expenseColor, 
                          textColor,
                          isDarkMode,
                          warningColor
                        )),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Warning legend
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: warningColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Months with overspending',
                            style: TextStyle(
                              color: warningColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _buildAreaChartData(
    Color expenseColor, 
    Color incomeColor, 
    Color textColor,
    bool isDarkMode,
  ) {
    // Calculate max Y value based on actual data
    double maxIncome = monthlyData.map((data) => data.income).reduce((a, b) => a > b ? a : b);
    double maxExpense = monthlyData.map((data) => data.expenses).reduce((a, b) => a > b ? a : b);
    double calculatedMaxY = maxIncome > maxExpense ? maxIncome : maxExpense;
    // Add 20% padding
    calculatedMaxY = calculatedMaxY * 1.2;
    
    return LineChartData(
      gridData: FlGridData(
        show: true, 
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, _) => value.toInt() < monthlyData.length 
              ? Text(monthlyData[value.toInt()].month, style: TextStyle(color: textColor, fontSize: 10))
              : const Text(''),
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(enabled: true),
      minX: 0,
      maxX: monthlyData.length - 1.0,
      minY: 0,
      maxY: calculatedMaxY,
      clipData: FlClipData.all(), // Ensure data stays within bounds
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
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, _) {
              if (value.toInt() < monthlyData.length) {
                final month = monthlyData[value.toInt()].month;
                // Highlight the month name for overspending months
                final isOverspending = _isOverspendingMonth(monthlyData[value.toInt()]);
                return Text(
                  month, 
                  style: TextStyle(
                    color: isOverspending ? warningColor : textColor,
                    fontSize: 12,
                    fontWeight: isOverspending ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(show: false),
      maxY: calculatedMaxY,
      alignment: BarChartAlignment.center,
      groupsSpace: 16, // Add space between bar groups
      barTouchData: BarTouchData(enabled: false), // Disable touch to prevent visual glitches
    );
  }

  // Helper method to check if a month has expenses exceeding income
  bool _isOverspendingMonth(MonthlyData data) {
    return data.expenses > data.income;
  }

  Widget _buildLegendItem(Color color, String text, Color textColor) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: textColor, fontSize: 14)),
      ],
    );
  }
}

// Model for monthly financial data
class MonthlyData {
  final String month;
  final double expenses;
  final double income;

  MonthlyData(this.month, this.expenses, this.income);
}
