import 'package:sqflite/sqflite.dart';

import 'package:data_life/life_db.dart';
import 'package:data_life/models/activity.dart';

class ActivityService {
  static int activitiesPerPage = 10;
  static int networkDelay = 500;

  Future<Database> open() async {
    return await LifeDb.open();
  }

  Future<int> requestTotalCount() async {
    Database db = await open();
    int count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${ActivityTable.name}'));
    return count;
  }

  Future<Activity> insert(Activity activity) async {
    Database db = await open();
    activity.id = await db.insert(ActivityTable.name, activity.toMap());
    return activity;
  }

  Future<int> delete(int id) async {
    Database db = await open();
    int affected = await db.delete(ActivityTable.name,
        where: '${ActivityTable.columnId} = ?', whereArgs: [id]);
    return affected;
  }

  Future<int> deleteAll(String tableName) async {
    Database db = await open();
    int affected = await db.delete(tableName);
    return affected;
  }

  Future<Activity> getActivity(int id) async {
    Database db = await open();
    List<Map> maps = await db.query(ActivityTable.name,
        where: '${ActivityTable.columnId} = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Activity.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Activity>> lastActiveActivity(int limit) async {
    Database db = await open();
    List<Map> maps = await db.query(ActivityTable.name,
        orderBy: '${ActivityTable.columnLastActiveTime} desc', limit: limit);
    return maps.map((item) {
      return Activity.fromMap(item);
    }).toList();
  }

  Future<List<Activity>> queryActivity(String keyword, int limit) async {
    Database db = await open();
    /*
    List<Map> maps = await db.query(
        ActivityTable.name,
        where: '${ActivityTable.columnName} like "%?%"',
        whereArgs: [keyword],
        orderBy: '${ActivityTable.columnLastActiveTime} desc',
        limit: limit
    );
    */
    List<Map> maps = await db.rawQuery(
        'select * from ${ActivityTable.name} where ${ActivityTable.columnName} like "%$keyword%" limit $limit');
    return maps.map((item) {
      return Activity.fromMap(item);
    }).toList();
  }

  Future<List<Activity>> getAllActivities() async {
    Database db = await open();
    List<Map> maps = await db.query(ActivityTable.name);
    var activities = <Activity>[];
    for (var map in maps) {
      activities.add(Activity.fromMap(map));
    }
    return activities;
  }

  Future<int> update(Activity activity) async {
    Database db = await open();
    int affected = await db.update(ActivityTable.name, activity.toMap(),
        where: "${ActivityTable.columnId} = ?", whereArgs: [activity.id]);
    return affected;
  }

  Future close() async => LifeDb.close();
}

void createTestActivity() async {
  final _activityService = ActivityService();
  _activityService.deleteAll(ActivityTable.name);
  for (var i = 0; i < 111; i++) {
    final activity = Activity();
    activity.name = 'Test activity $i';
    activity.createTime = DateTime.now().millisecondsSinceEpoch;
    await _activityService.insert(activity);
  }
}
