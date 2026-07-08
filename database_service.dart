import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'bank_transaction.dart';
import 'bank_user.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _database;
  SharedPreferences? _prefs;
  final List<BankUser> _webUsers = <BankUser>[];
  final Map<int, List<BankTransaction>> _webTransactions =
      <int, List<BankTransaction>>{};

  Future<void> initialize() async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      await _loadWebData();
      return;
    }

    if (_database != null) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/brightcare.db';

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _loadWebData() async {
    final usersJson = _prefs?.getStringList('brightcare_users') ?? const <String>[];
    _webUsers.clear();

    for (final raw in usersJson) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _webUsers.add(BankUser.fromMap(decoded));
      }
    }

    final txJson = _prefs?.getStringList('brightcare_transactions') ?? const <String>[];
    _webTransactions.clear();

    for (final raw in txJson) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final tx = BankTransaction.fromMap(decoded);
        _webTransactions.putIfAbsent(tx.userId, () => <BankTransaction>[]).add(tx);
      }
    }
  }

  Future<void> _persistWebData() async {
    if (_prefs == null) {
      return;
    }

    final usersJson = _webUsers.map((user) => jsonEncode(user.toMap())).toList();
    await _prefs!.setStringList('brightcare_users', usersJson);

    final txJson = _webTransactions.entries
        .expand((entry) => entry.value.map((tx) => jsonEncode(tx.toMap())))
        .toList();
    await _prefs!.setStringList('brightcare_transactions', txJson);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        accountName TEXT NOT NULL,
        accountNumber TEXT NOT NULL,
        biometricEnabled INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        FOREIGN KEY(userId) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN biometricEnabled INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<BankUser?> getUserByCredentials(
    String username,
    String password,
  ) async {
    if (kIsWeb) {
      for (final user in _webUsers) {
        if (user.username == username && user.password == password) {
          return user.copyWith();
        }
      }
      return null;
    }

    final db = _database;
    if (db == null) return null;

    final results = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return BankUser.fromMap(results.first);
  }

  Future<BankUser?> getUserByUsername(String username) async {
    if (kIsWeb) {
      for (final user in _webUsers) {
        if (user.username == username) {
          return user.copyWith();
        }
      }
      return null;
    }

    final db = _database;
    if (db == null) return null;

    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return BankUser.fromMap(results.first);
  }

  Future<bool> usernameExists(String username) async {
    if (kIsWeb) {
      for (final user in _webUsers) {
        if (user.username == username) {
          return true;
        }
      }
      return false;
    }

    final db = _database;
    if (db == null) return false;

    final results = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  Future<BankUser> createUser(BankUser user) async {
    if (kIsWeb) {
      final nextId = (_webUsers.map((entry) => entry.id ?? 0).fold<int>(0, (maxId, id) => id > maxId ? id : maxId) + 1);
      final created = user.copyWith(id: nextId);
      _webUsers.add(created);
      await _persistWebData();
      return created;
    }

    final db = _database;
    if (db == null) {
      throw Exception('Database not initialized');
    }

    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<void> updateBiometricSetting(int userId, bool enabled) async {
    if (kIsWeb) {
      for (final user in _webUsers) {
        if (user.id == userId) {
          final index = _webUsers.indexOf(user);
          _webUsers[index] = user.copyWith(biometricEnabled: enabled);
          await _persistWebData();
          return;
        }
      }
      return;
    }

    final db = _database;
    if (db == null) return;

    await db.update(
      'users',
      {'biometricEnabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> addSampleTransactions(int userId) async {
    if (kIsWeb) {
      final now = DateTime.now();
      final sample = <Map<String, Object?>>[
        {
          'userId': userId,
          'date': now.subtract(const Duration(days: 1)).toIso8601String(),
          'description': 'Monthly salary deposit',
          'amount': 3250.00,
          'type': 'credit',
          'category': 'Salary',
        },
        {
          'userId': userId,
          'date': now.subtract(const Duration(days: 1)).toIso8601String(),
          'description': 'Electricity bill payment',
          'amount': 120.45,
          'type': 'debit',
          'category': 'Utilities',
        },
        {
          'userId': userId,
          'date': now.subtract(const Duration(days: 2)).toIso8601String(),
          'description': 'Grocery store purchase',
          'amount': 84.20,
          'type': 'debit',
          'category': 'Groceries',
        },
        {
          'userId': userId,
          'date': now.subtract(const Duration(days: 4)).toIso8601String(),
          'description': 'Cashback reward',
          'amount': 15.00,
          'type': 'credit',
          'category': 'Rewards',
        },
        {
          'userId': userId,
          'date': now.subtract(const Duration(days: 5)).toIso8601String(),
          'description': 'Online subscription',
          'amount': 9.99,
          'type': 'debit',
          'category': 'Subscriptions',
        },
      ];

      final transactionList = _webTransactions.putIfAbsent(userId, () => <BankTransaction>[]);
      for (final raw in sample) {
        final nextId = (transactionList.map((entry) => entry.id ?? 0).fold<int>(0, (maxId, id) => id > maxId ? id : maxId) + 1);
        transactionList.add(
          BankTransaction(
            id: nextId,
            userId: userId,
            date: raw['date'] as String,
            description: raw['description'] as String,
            amount: (raw['amount'] as num).toDouble(),
            type: raw['type'] as String,
            category: raw['category'] as String,
          ),
        );
      }

      await _persistWebData();
      return;
    }

    final db = _database;
    if (db == null) return;

    final now = DateTime.now();
    final sample = <Map<String, Object?>>[
      {
        'userId': userId,
        'date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'description': 'Monthly salary deposit',
        'amount': 3250.00,
        'type': 'credit',
        'category': 'Salary',
      },
      {
        'userId': userId,
        'date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'description': 'Electricity bill payment',
        'amount': 120.45,
        'type': 'debit',
        'category': 'Utilities',
      },
      {
        'userId': userId,
        'date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'description': 'Grocery store purchase',
        'amount': 84.20,
        'type': 'debit',
        'category': 'Groceries',
      },
      {
        'userId': userId,
        'date': now.subtract(const Duration(days: 4)).toIso8601String(),
        'description': 'Cashback reward',
        'amount': 15.00,
        'type': 'credit',
        'category': 'Rewards',
      },
      {
        'userId': userId,
        'date': now.subtract(const Duration(days: 5)).toIso8601String(),
        'description': 'Online subscription',
        'amount': 9.99,
        'type': 'debit',
        'category': 'Subscriptions',
      },
    ];

    for (final transaction in sample) {
      await db.insert('transactions', transaction);
    }
  }

  Future<List<BankTransaction>> getTransactionsForUser(int userId) async {
    if (kIsWeb) {
      return List<BankTransaction>.from(_webTransactions[userId] ?? const <BankTransaction>[]);
    }

    final db = _database;
    if (db == null) return [];

    final results = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return results.map((map) {
      final amountValue = map['amount'];
      final amount = (amountValue is num)
          ? amountValue.toDouble()
          : 0.0;
      return BankTransaction(
        id: map['id'] as int?,
        userId: map['userId'] as int,
        date: map['date'] as String,
        description: map['description'] as String,
        amount: amount,
        type: map['type'] as String,
        category: map['category'] as String,
      );
    }).toList();
  }
}
