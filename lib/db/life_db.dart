import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:data_life/db/moment_table.dart';
import 'package:data_life/db/goal_table.dart';
import 'package:data_life/db/todo_table.dart';
import 'package:data_life/db/goal_action_table.dart';
import 'package:data_life/db/contact_table.dart';
import 'package:data_life/db/location_table.dart';
import 'package:data_life/db/action_table.dart';
import 'package:data_life/db/goal_moment_table.dart';
import 'package:data_life/db/moment_contact_table.dart';

class LifeDb {
  static const dbFile = 'data_life.db';
  static const version = 2;
  static String dbPath;
  static Database db;

  static Future<String> getPath() async {
    var databasesPath = await getDatabasesPath();
    return join(databasesPath, LifeDb.dbFile);
  }

  static Future<Database> open() async {
    LifeDb.dbPath = await LifeDb.getPath();
    LifeDb.db = await openDatabase(
      LifeDb.dbPath,
      version: LifeDb.version,
      onCreate: LifeDb.create,
      onUpgrade: LifeDb.upgrade,
    );
    return LifeDb.db;
  }

  static void create(Database db, int version) async {
    var initSqlList = MomentTable.initSqlList +
        GoalTable.initSqlList +
        TodoTable.initSqlList +
        GoalActionTable.initSqlList +
        ContactTable.initSqlList +
        LocationTable.initSqlList +
        ActionTable.initSqlList +
        MomentContactTable.initSqlList;
    initSqlList.forEach((sql) => db.execute(sql));
  }

  static void upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute(ContactTable.createSql);
    }
  }

  static Future delete() async {
    LifeDb.dbPath ??= await LifeDb.getPath();
    await deleteDatabase(LifeDb.dbPath);
    LifeDb.db = null;
  }

  static void close() async {
    db?.close();
    db = null;
  }
}
