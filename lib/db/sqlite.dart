import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
// import 'package:sqflite_common_ffi_web/sqflite_web.dart';

class PasswordItem {
  int id = -1;
  final String name;
  final String key;
  final String zone;
  final String special;
  final String password;
  int? lasttime;

  PasswordItem({
    this.lasttime,
    required this.name,
    required this.key,
    required this.zone,
    required this.special,
    required this.password,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'key': key,
      'zone': zone,
      'special': special,
      'password': password,
      'lasttime': lasttime,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  // 重写 toString 方法，以便使用 print 方法查看每个狗狗信息的时候能更清晰。
  @override
  String toString() {
    return 'password: $password, name: $name ';
  }
}

class FlowerDB {
  late Database db;
  bool isOpen = false;
  // ignore: constant_identifier_names
  static const String DB = "password.db";
  // ignore: constant_identifier_names
  static const String TABLE = "password";
  String tableName = "";

  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  open() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Open the database and store the reference.
    // open the database, if the table does not exist, create a new table. table conent is :
    // id, name, key, code, zone, password, lasttime
    late DatabaseFactory factory;
    if (kIsWeb) {
      factory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      factory = databaseFactoryFfi;
    } else if (Platform.isAndroid || Platform.isIOS) {
      factory = databaseFactory;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    final dbPath = await factory.getDatabasesPath();
    db = await factory.openDatabase('$dbPath/my_database.db');
    // create table if not exists
    await db.execute(
      "CREATE TABLE IF NOT EXISTS $TABLE("
      "id INTEGER PRIMARY KEY,"
      "name TEXT,"
      "key TEXT,"
      "zone TEXT,"
      "special TEXT,"
      "password TEXT,"
      "lasttime INTEGER)",
    );

    isOpen = true;
  }

  // Define a function that inserts dogs into the database
  insert(PasswordItem pwd) async {
    // Get a reference to the database.

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    return await db.insert(
      TABLE,
      pwd.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<PasswordItem>> passwords(int top) async {
    // Get a reference to the database.
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps =
        await db.query(TABLE, orderBy: "lasttime DESC", limit: top);
    // Convert the List<Map<String, dynamic> into a List<Dog> (将 List<Map<String, dynamic> 转换成 List<Dog> 数据类型)
    return List.generate(maps.length, (i) {
      return PasswordItem(
        lasttime: maps[i]['lasttime'],
        name: maps[i]['name'],
        key: maps[i]['key'],
        zone: maps[i]['zone'],
        special: maps[i]['special'],
        password: maps[i]['password'],
      );
    });
  }

  query(String name) async {
    // Get a reference to the database (获得数据库引用)
    // Update the given Dog (修改给定的狗狗的数据)
    return await db.query(
      TABLE,
      // Ensure that the Dog has a matching id.
      where: 'name = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [name],
    );
  }

  updateOrInsert(PasswordItem pwd) async {
    // Get a reference to the database (获得数据库引用)
    // Update the given Dog (修改给定的狗狗的数据)
    var items = await db.query(
      TABLE,
      // Ensure that the Dog has a matching id.
      where: 'name = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [pwd.name],
    );
    pwd.lasttime =
        (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).round();
    if (items.isNotEmpty) {
      await db.update(
        TABLE,
        pwd.toMap(),
        // Ensure that the Dog has a matching id.
        where: 'name = ?',
        // Pass the Dog's id as a whereArg to prevent SQL injection.
        whereArgs: [pwd.name],
      );
    } else {
      await insert(pwd);
    }
  }

  delete(String name) async {
    // Get a reference to the database (获得数据库引用)
    // Remove the Dog from the database (将狗狗从数据库移除)
    return await db.delete(
      TABLE,
      // Use a `where` clause to delete a specific dog.
      where: 'name = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [name],
    );
  }

  // 获取最新一条记录的key
  getLatestKey() async {
    var items = await db.query(
      TABLE,
      orderBy: "lasttime DESC",
      limit: 1,
    );
    if (items.isNotEmpty) {
      return items[0]['key'];
    }
    return "";
  }

  getLatestZone() async {
    var items = await db.query(
      TABLE,
      orderBy: "lasttime DESC",
      limit: 1,
    );
    if (items.isNotEmpty) {
      return items[0]['zone'];
    }
    return "";
  }

  // get latest record by lasttime, return key, zone, special
  getLatestRecord() async {
    var items = await db.query(
      TABLE,
      orderBy: "lasttime DESC",
      limit: 1,
    );
    if (items.isNotEmpty) {
      return {
        'key': items[0]['key'],
        'zone': items[0]['zone'],
        'special': items[0]['special']
      };
    }
    return "";
  }
}
