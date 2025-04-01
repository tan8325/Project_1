import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:project1/services/auth_service.dart';

class Transaction {
  final int? id;
  final String description;
  final String type;  // 'income' or 'expense'
  final double amount;
  final DateTime date;
  final int userId;

  Transaction({
    this.id,
    required this.description,
    required this.type,
    required this.amount,
    required this.date,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'type': type,
    'amount': amount,
    'date': date.millisecondsSinceEpoch,
    'user_id': userId,
  };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
    id: map['id'] as int,
    description: map['description'] as String,
    type: map['type'] as String,
    amount: map['amount'] as double,
    date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
    userId: map['user_id'] as int,
  );
}

class TransactionService {
  final AuthService _authService = AuthService();
  
  Future<Database> get database async => await _authService.database;

  Future<void> initTransactionTable() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        type TEXT,
        amount REAL,
        date INTEGER,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<int> addTransaction(Transaction transaction) async {
    final db = await database;
    final map = transaction.toMap();
    final id = await db.insert('transactions', map);
    return id;
  }

  Future<List<Transaction>> getTransactions(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getRecentTransactions(int userId, {int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getTransactionsByType(int userId, String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<double> getTotalByType(int userId, String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?', 
      [userId, type]
    );
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addDemoData(int userId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM transactions WHERE user_id = ?', [userId]
    ));
    
    if (count != null && count > 0) return;
    
    final now = DateTime.now();
    final demoTransactions = [
      Transaction(
        description: 'Salary',
        type: 'income',
        amount: 2800.00,
        date: DateTime(now.year, now.month, 1),
        userId: userId,
      ),
      Transaction(
        description: 'Freelance Work',
        type: 'income',
        amount: 200.00,
        date: DateTime(now.year, now.month, 15),
        userId: userId,
      ),
      Transaction(
        description: 'Rent',
        type: 'expense',
        amount: 1200.00,
        date: DateTime(now.year, now.month, 5),
        userId: userId,
      ),
      Transaction(
        description: 'Groceries',
        type: 'expense',
        amount: 350.00,
        date: DateTime(now.year, now.month, 10),
        userId: userId,
      ),
      Transaction(
        description: 'Internet Bill',
        type: 'expense',
        amount: 75.99,
        date: DateTime(now.year, now.month, 12),
        userId: userId,
      ),
      Transaction(
        description: 'Coffee Shop',
        type: 'expense',
        amount: 12.50,
        date: DateTime(now.year, now.month, now.day - 2),
        userId: userId,
      ),
      Transaction(
        description: 'Movie Tickets',
        type: 'expense',
        amount: 25.00,
        date: DateTime(now.year, now.month, now.day - 1),
        userId: userId,
      ),
      Transaction(
        description: 'New Car',
        type: 'expense',
        amount: 555.00,
        date: DateTime(now.year, now.month, now.day),
        userId: userId,
      ),
    ];
    
    for (var transaction in demoTransactions) {
      await db.insert('transactions', transaction.toMap());
    }
  }

  Future<void> clearUserTransactions(int userId) async {
    final db = await database;
    await db.delete('transactions', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<double> getMonthlyTotalByType(int userId, String type, DateTime startDate, DateTime endDate) async {
    final db = await database;
    final allTransactions = await db.query(
      'transactions',
      where: 'user_id = ? AND type = ?',
      whereArgs: [userId, type],
    );
    
    double total = 0.0;
    for (var txn in allTransactions) {
      final txnDateMillis = txn['date'] as int;
      final txnDate = DateTime.fromMillisecondsSinceEpoch(txnDateMillis);
      
      if (txnDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
          txnDate.isBefore(endDate.add(const Duration(days: 1)))) {
        total += txn['amount'] as double;
      }
    }
    
    return total;
  }

  Future<void> inspectTransaction(int transactionId) async {
    final db = await database;
    await db.query('transactions', where: 'id = ?', whereArgs: [transactionId]);
  }
  
  Future<void> debugRecentTransactions(int userId) async {
    final db = await database;
    await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 10,
    );
  }
}