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
    final path = join(await getDatabasesPath(), 'finance_app.db');
    return openDatabase(
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
    return db.insert('users', user.toMap());
  }

  Future<User?> getUser(String email, String password) async {
    if (email == demoEmail && password == demoPassword) {
      final db = await database;
      final maps = await db.query('users', where: 'email = ?', whereArgs: [demoEmail]);
      
      if (maps.isEmpty) {
        final demoUserId = await createUser(User(
          name: demoName,
          email: demoEmail,
          password: demoPassword,
        ));
        
        final demoUser = User(
          id: demoUserId,
          name: demoName,
          email: demoEmail,
          password: demoPassword,
        );
        
        await TransactionService().addDemoData(demoUser.id!);
        return demoUser;
      } 
      
      return User.fromMap(maps.first);
    }
    
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_user_id', userId);
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id');
      
      if (userId == null) return null;
      
      final db = await database;
      final maps = await db.query('users', where: 'id = ?', whereArgs: [userId]);
      
      return maps.isNotEmpty ? User.fromMap(maps.first) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<int> updateUserEmail(int userId, String newEmail) async {
    final db = await database;
    return db.update('users', {'email': newEmail}, where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updateUserPassword(int userId, String newPassword) async {
    final db = await database;
    return db.update('users', {'password': newPassword}, where: 'id = ?', whereArgs: [userId]);
  }
}
