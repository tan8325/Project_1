import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(''' 
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT UNIQUE,
          password TEXT
        )
      ''');
    });
  }

  Future<int> createUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String email, String password) async {
    if (email == demoEmail && password == demoPassword) {
      return User(id: 999, name: demoName, email: demoEmail, password: demoPassword);
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
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS current_user(id INTEGER PRIMARY KEY, user_id INTEGER)');
    await db.delete('current_user');
    await db.insert('current_user', {'id': 1, 'user_id': userId});
  }

  Future<User?> getCurrentUser() async {
    final db = await database;
    final currentUserMaps = await db.query('current_user');
    if (currentUserMaps.isEmpty) return null;

    final userId = currentUserMaps.first['user_id'] as int;
    final userMaps = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    return userMaps.isNotEmpty ? User.fromMap(userMaps.first) : null;
  }

  Future<void> logout() async {
    final db = await database;
    await db.delete('current_user');
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
