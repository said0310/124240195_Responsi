import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbService {
  static final DbService instance = DbService._init();
  static Database? _database;

  DbService._init();

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rick_and_morty_users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL
      )
    ''');
  }

  Future<int> register(String username, String password) async {
    final db = await database;
    final trimmedUser = username.trim();
    final existing = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [trimmedUser.toLowerCase()],
    );

    if (existing.isNotEmpty) {
      throw Exception(
        'Username "$trimmedUser" sudah terdaftar. Silakan gunakan username lain.',
      );
    }

    final id = await db.insert('users', {
      'username': trimmedUser,
      'password_hash': hashPassword(password),
    });

    return id;
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;
    final trimmedUser = username.trim();
    final hashed = hashPassword(password);

    final results = await db.query(
      'users',
      where: 'LOWER(username) = ? AND password_hash = ?',
      whereArgs: [trimmedUser.toLowerCase(), hashed],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
