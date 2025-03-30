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
  
  final List<Transaction> recentTransactions = [
    Transaction('Auto & Transport', 'expense', 150.0),
    Transaction('Auto Insurance', 'expense', 200.0),
    Transaction('Auto Payment', 'expense', 288.0),
    Transaction('Gas & Fuel', 'expense', 100.0),
  ];

  @override
  Widget build(BuildContext context) {
    double remaining = budget - spent;
    double progressValue = spent / budget;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation:.0,
      ),
      body: Padding(
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
                      backgroundColor: Colors.purple.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade700),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${remaining.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text('Left', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Text('\$${spent.toInt()} of \$${budget.toInt()} Spent', 
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Income section
            Card(
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  setState(() {
                    isIncomeExpanded = expanded;
                  });
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    isIncomeExpanded ? Icons.remove : Icons.add,
                    color: Colors.purple,
                  ),
                ),
                title: Row(
                  children: [
                    const Text('Income'),
                    const Spacer(),
                    Text('\$${income.toInt()}'),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Add Income',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Add income functionality will go here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
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
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                onExpansionChanged: (expanded) {
                  setState(() {
                    isExpensesExpanded = expanded;
                  });
                },
                leading: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    isExpensesExpanded ? Icons.remove : Icons.add,
                    color: Colors.purple,
                  ),
                ),
                title: Row(
                  children: [
                    const Text('Expenses'),
                    const Spacer(),
                    Text('-\$${spent.toInt()}'),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Amount',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Add expense functionality will go here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
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
            
            const SizedBox(height: 20),
            
            // Recent transactions section
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: recentTransactions.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(recentTransactions[index].description),
                            trailing: Text(
                              recentTransactions[index].type == 'income'
                                  ? '\$${recentTransactions[index].amount.toInt()}'
                                  : '-\$${recentTransactions[index].amount.toInt()}',
                              style: TextStyle(
                                color: recentTransactions[index].type == 'income'
                                    ? Colors.green
                                    : Colors.black,
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
