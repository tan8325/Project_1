import 'package:flutter/material.dart';
import 'package:project1/services/auth_service.dart';
import 'package:project1/services/transaction_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();
  
  User? currentUser;
  List<Transaction> monthlyExpenses = [];
  List<Transaction> recentTransactions = [];
  double income = 0.0;
  double spent = 0.0;
  double budget = 0.0;
  
  bool isIncomeExpanded = false;
  bool isExpensesExpanded = false;
  
  final TextEditingController expenseDescriptionController = TextEditingController();
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController incomeAmountController = TextEditingController();
  final TextEditingController incomeSourceController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    currentUser = await _authService.getCurrentUser();
    
    if (currentUser != null) {
      await _transactionService.initTransactionTable();
      await _loadTransactions();
    }
  }
  
  Future<void> _loadTransactions() async {
    if (currentUser == null) return;
    
    try {
      final expensesList = await _transactionService.getTransactionsByType(currentUser!.id!, 'expense');
      final recentList = await _transactionService.getRecentTransactions(currentUser!.id!);
      final totalIncome = await _transactionService.getTotalByType(currentUser!.id!, 'income');
      final totalExpenses = await _transactionService.getTotalByType(currentUser!.id!, 'expense');
      
      setState(() {
        monthlyExpenses = expensesList;
        recentTransactions = recentList;
        income = totalIncome;
        spent = totalExpenses;
        budget = income - spent;
      });
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }
  
  Future<void> _addTransaction(String type) async {
    if (currentUser == null) return;
    
    try {
      if (type == 'expense') {
        final description = expenseDescriptionController.text;
        final amount = double.parse(expenseAmountController.text);
        
        if (description.isNotEmpty && amount > 0) {
          final transaction = Transaction(
            description: description,
            type: 'expense',
            amount: amount,
            date: DateTime.now(),
            userId: currentUser!.id!,
          );
          
          await _transactionService.addTransaction(transaction);
          expenseDescriptionController.clear();
          expenseAmountController.clear();
        }
      } else if (type == 'income') {
        final source = incomeSourceController.text;
        final amount = double.parse(incomeAmountController.text);
        
        if (source.isNotEmpty && amount > 0) {
          final transaction = Transaction(
            description: source,
            type: 'income',
            amount: amount,
            date: DateTime.now(),
            userId: currentUser!.id!,
          );
          
          await _transactionService.addTransaction(transaction);
          incomeSourceController.clear();
          incomeAmountController.clear();
        }
      }
      
      await _loadTransactions();
    } catch (e) {
      // Handle errors
      print('Error adding transaction: $e');
    }
  }

  @override
  void dispose() {
    expenseDescriptionController.dispose();
    expenseAmountController.dispose();
    incomeAmountController.dispose();
    incomeSourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double remaining = income - spent;
    double progressValue = spent / income > 1 ? 1 : spent / income; // Cap at 1 to prevent overflow
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.purple.shade50;
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[300]! : Colors.grey[700]!;
    
    // Get the user's name or use "User" as fallback
    String userName = currentUser?.name ?? "User";
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $userName'),
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
                        Text(
                          "\$${income.toStringAsFixed(2)} of \$${spent.toStringAsFixed(2)} Spent",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10, // Small font to fit the space
                            color: textColor,
                          ),
                        ),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: incomeSourceController,
                            decoration: InputDecoration(
                              labelText: 'Source (e.g. Paycheck, Freelance)',
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
                                  controller: incomeAmountController,
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
                                  _addTransaction('income');
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
                                  _addTransaction('expense');
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
                            final transaction = recentTransactions[index];
                            return ListTile(
                              title: Text(transaction.description),
                              subtitle: Text(DateFormat('MMM d, yyyy').format(transaction.date)),
                              trailing: Text(
                                "\$${transaction.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: transaction.type == 'expense' ? Colors.red : Colors.green,
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
