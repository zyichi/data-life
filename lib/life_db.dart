import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    await db.execute(GoalTable.createSql);
    await db.execute(ActivityTable.createSql);
    await db.execute(EventTable.createSql);
  }

  static void upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute(PeopleTable.createSql);
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


class OldGoalTable {
  static const name = 'goal';
  static const columnId = '_id';
  static const columnType = 'type';
  static const columnActivityType = 'activity_type';
  static const columnActivity = 'activity';
  static const columnProgress = 'progress';
  static const columnHowOften = 'how_often';
  static const columnHowLong = 'how_long';
  static const columnBestTime = 'best_time';
  static const columnTimeSpent = 'time_spent';
  static const columnCreateTime = 'create_time';
  static const columnLastActiveTime = 'last_active_time';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnType integer not null,
  $columnActivityType integer not null,
  $columnActivity String default null,
  $columnProgress integer default 0,
  $columnHowOften integer not null,
  $columnHowLong integer not null,
  $columnBestTime integer not null,
  $columnTimeSpent integer default 0,
  $columnLastActiveTime integer default null,
  $columnCreateTime integer not null)
''';
}

class GoalTable {
  static const name = 'goal';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnTarget = 'target';
  static const columnAlreadyDone = 'alreadyDone';
  static const columnStartTime = 'startTime';
  static const columnDuration = 'duration';
  static const columnCreateTime = 'createTime';
  static const columnLastActiveTime = 'lastActiveTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnName String default null,
  $columnTarget real default null,
  $columnAlreadyDone real default null,
  $columnStartTime integer default null,
  $columnDuration integer default null,
  $columnLastActiveTime integer default null,
  $columnCreateTime integer not null)
''';
}

class ActivityTable {
  static const name = 'activity';
  static const columnId = '_id';
  static const columnGoalId = 'goalId';
  static const columnName = 'name';
  static const columnTarget = 'target';
  static const columnAlreadyDone = 'alreadyDone';
  static const columnStartTime = 'startTime';
  static const columnDuration = 'duration';
  static const columnTimeSpent = 'timeSpent';
  static const columnHowOften = 'howOften';
  static const columnHowLong = 'howLong';
  static const columnBestTime = 'bestTime';
  static const columnLastActiveTime = 'lastActiveTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const defaultGoalId = -1;

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnGoalId integer not null,
  $columnName String not null,
  $columnTarget real default null,
  $columnAlreadyDone real default null,
  $columnStartTime integer default null,
  $columnDuration integer default null,
  $columnTimeSpent integer not null,
  $columnHowOften integer not null,
  $columnHowLong integer not null,
  $columnBestTime integer not null,
  $columnLastActiveTime integer not null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';
}

class EventTable {
  static const name = 'event';
  static const columnId = '_id';
  static const columnActivityId = 'activityId';
  static const columnLocation = 'location';
  static const columnPeople = 'people';
  static const columnSentiment = 'sentiment';
  static const columnBeginTime = 'beginTime';
  static const columnEndTime = 'endTime';
  static const columnCost = 'cost';
  static const columnDetails = 'details';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnActivityId integer defalut null,
  $columnLocation String default null,
  $columnPeople String default null,
  $columnSentiment integer not null,
  $columnBeginTime integer not null,
  $columnEndTime integer not null,
  $columnCost real default 0.0,
  $columnDetails String default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';
}

class PeopleTable {
  static const name = 'people';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnName String not null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';
}
