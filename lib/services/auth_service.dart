import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:project1/services/transaction_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int? id;
  final String name;
  final String email;
  final String password;

  User({this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email, 'password': password};

  static User fromMap(Map<String, dynamic> map) => User(
    id: map['id'], name: map['name'], email: map['email'], password: map['password']);
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static Database? _database;

  static const demoEmail = "demo@example.com";
  static const demoPassword = "password123";
  static const demoName = "Demo User";

  factory AuthService() => _instance;
  AuthService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'finance_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT,
            type TEXT,
            amount REAL,
            date INTEGER,
            user_id INTEGER,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
      },
    );
  }

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String email, String password) async {
    if (email == demoEmail && password == demoPassword) {
      // Check if demo user exists in database
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [demoEmail],
      );
      
      User demoUser;
      if (maps.isEmpty) {
        // Create demo user if it doesn't exist
        final demoUserId = await createUser(User(
          name: demoName,
          email: demoEmail,
          password: demoPassword,
        ));
        
        demoUser = User(
          id: demoUserId,
          name: demoName,
          email: demoEmail,
          password: demoPassword,
        );
        
        // Add demo transactions ONLY for the demo user and ONLY when first created
        final transactionService = TransactionService();
        await transactionService.addDemoData(demoUser.id!);
      } else {
        demoUser = User.fromMap(maps.first);
      }
      
      return demoUser;
    }
    
    // Regular user login - no demo data added
    final db = await database;
    final maps = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return maps.isNotEmpty ? User.fromMap(maps.first) : null;
  }

  Future<void> saveCurrentUser(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', userId);
  }

  Future<User?> getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');
      
      if (userId == null) return null;
      
      final db = await database;
      List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      
      if (maps.isEmpty) return null;
      
      return User.fromMap(maps.first);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> updateUserEmail(int userId, String newEmail) async {
    final db = await database;
    return await db.update('users', {'email': newEmail}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updateUserPassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update('users', {'password': newPassword}, where: 'id = ?', whereArgs: [userId]);
  }
}
