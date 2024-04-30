import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Employee {
  final int id;
  final String name;
  final DateTime joinDate;
  final bool isActive;

  Employee({required this.id, required this.name, required this.joinDate, required this.isActive});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'employees.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE employees(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            joinDate TEXT,
            isActive INTEGER
          )
        ''');
    });
  }

  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert('employees', employee.toMap());
  }

  Future<List<Employee>> getEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'],
        name: maps[i]['name'],
        joinDate: DateTime.parse(maps[i]['joinDate']),
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }
}
