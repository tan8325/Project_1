import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Static data for testing
  final double budget = 2550.0;
  final double spent = 738.0;
  final double income = 3000.0;
  
  bool isIncomeExpanded = false;
  bool isExpensesExpanded = false;
  
  final TextEditingController expenseDescriptionController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController incomeAmountController = TextEditingController();
  
  // Monthly expenses
  final List<Transaction> monthlyExpenses = [
    Transaction('Auto & Transport', 'expense', 150.0),
    Transaction('Auto Insurance', 'expense', 200.0),
    Transaction('Auto Payment', 'expense', 288.0),
    Transaction('Gas & Fuel', 'expense', 100.0),
  ];
  
  // Recent transactions (bank history)
  final List<Transaction> recentTransactions = [
    Transaction('Starbucks', 'expense', 5.75),
    Transaction('Grocery Store', 'expense', 43.21),
    Transaction('Amazon', 'expense', 29.99),
    Transaction('Paycheck', 'income', 1500.0),
  ];

  @override
  void dispose() {
    expenseDescriptionController.dispose();
    expenseAmountController.dispose();
    incomeAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double remaining = budget - spent;
    double progressValue = spent / budget;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.purple.shade50;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome User'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Budget progress indicator
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 180,
                      width: 180,
                      child: CircularProgressIndicator(
                        value: progressValue,
                        strokeWidth: 10,
                        backgroundColor: isDarkMode ? Colors.purple.shade200.withOpacity(0.3) : Colors.purple.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.white : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${remaining.toInt()}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Always black for visibility on white container
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('Left', style: TextStyle(color: secondaryTextColor)),
                        const SizedBox(height: 5),
                        Text('\$${spent.toInt()} of \$${budget.toInt()} Spent', 
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Income section
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isIncomeExpanded = expanded;
                    });
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.add,
                      color: Colors.purple,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text('Income', style: TextStyle(color: textColor)),
                      const Spacer(),
                      Text('\$${income.toInt()}', style: TextStyle(color: textColor)),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: incomeAmountController,
                              decoration: InputDecoration(
                                labelText: 'Add Income',
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: secondaryTextColor),
                              ),
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Add income functionality will go here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Expenses section
              Card(
                color: cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  onExpansionChanged: (expanded) {
                    setState(() {
                      isExpensesExpanded = expanded;
                    });
                  },
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.remove,
                      color: Colors.purple,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text('Expenses', style: TextStyle(color: textColor)),
                      const Spacer(),
                      Text('-\$${spent.toInt()}', style: TextStyle(color: textColor)),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: expenseDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: const OutlineInputBorder(),
                              labelStyle: TextStyle(color: secondaryTextColor),
                            ),
                            style: TextStyle(color: textColor),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: expenseAmountController,
                                  decoration: InputDecoration(
                                    labelText: 'Amount',
                                    border: const OutlineInputBorder(),
                                    labelStyle: TextStyle(color: secondaryTextColor),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(color: textColor),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  // Add expense functionality will go here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Monthly Expenses',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 150, // Reduce height
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: monthlyExpenses.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        monthlyExpenses[index].description,
                                        style: TextStyle(color: textColor),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '-\$${monthlyExpenses[index].amount.toInt()}',
                                            style: TextStyle(color: textColor),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.edit, size: 18, color: Colors.purple.shade300),
                                        ],
                                      ),
                                    ),
                                    if (index < monthlyExpenses.length - 1)
                                      Divider(height: 1, color: secondaryTextColor.withOpacity(0.5)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Recent transactions section
              Container(
                height: 300, // Fixed height for recent transactions
                child: Card(
                  color: isDarkMode ? Colors.black : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      Divider(height: 1, color: secondaryTextColor.withOpacity(0.5)),
                      Expanded(
                        child: ListView.separated(
                          itemCount: recentTransactions.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1, 
                            color: secondaryTextColor.withOpacity(0.5),
                          ),
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                recentTransactions[index].description,
                                style: TextStyle(color: textColor),
                              ),
                              trailing: Text(
                                recentTransactions[index].type == 'income'
                                    ? '\$${recentTransactions[index].amount.toInt()}'
                                    : '-\$${recentTransactions[index].amount.toInt()}',
                                style: TextStyle(
                                  color: recentTransactions[index].type == 'income'
                                      ? Colors.green
                                      : textColor,
                                ),
                              ),
                            );
                          },
                        ),
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
}

// Model for transactions
class Transaction {
  final String description;
  final String type; // 'income' or 'expense'
  final double amount;

  Transaction(this.description, this.type, this.amount);
}
