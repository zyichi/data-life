import 'package:data_life/models/goal.dart';
import 'package:data_life/models/time_types.dart';


class GoalTable {
  static const name = 'goal';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnTarget = 'target';
  static const columnProgress = 'progress';
  static const columnStartTime = 'startTime';
  static const columnStopTime = 'stopTime';
  static const columnDurationType = 'durationType';
  static const columnLastActiveTime = 'lastActiveTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnName text not null,
  $columnTarget real default null,
  $columnProgress real default null,
  $columnStartTime integer default null,
  $columnStopTime integer default null,
  $columnDurationType integer default null,
  $columnLastActiveTime integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static const createIndexSql = '''
create unique index name_idx on $name(
  $columnName);
''';

  static List<String> get initSqlList => [createSql, createIndexSql];

  static Goal fromMap(Map map) {
    final Goal goal = Goal();
    goal.id = map[GoalTable.columnId] as int;
    goal.name = map[GoalTable.columnName] as String;
    goal.target = map[GoalTable.columnTarget] as num;
    goal.progress = map[GoalTable.columnProgress] as num;
    goal.startTime = map[GoalTable.columnStartTime] as int;
    goal.stopTime = map[GoalTable.columnStopTime] as int;
    var durationTypeIndex = map[GoalTable.columnDurationType];
    if (durationTypeIndex != null)
      goal.durationType = DurationType.values[durationTypeIndex];
    goal.lastActiveTime = map[GoalTable.columnLastActiveTime] as int;
    goal.createTime = map[GoalTable.columnCreateTime] as int;
    goal.updateTime = map[GoalTable.columnUpdateTime] as int;
    return goal;
  }

  static Map<String, dynamic> toMap(Goal goal) {
    var map = <String, dynamic>{
      GoalTable.columnName: name,
      GoalTable.columnTarget: goal.target,
      GoalTable.columnProgress: goal.progress,
      GoalTable.columnStartTime: goal.startTime,
      GoalTable.columnStopTime: goal.stopTime,
      GoalTable.columnDurationType: goal.durationType?.index,
      GoalTable.columnLastActiveTime: goal.lastActiveTime,
      GoalTable.columnCreateTime: goal.createTime,
      GoalTable.columnUpdateTime: goal.updateTime,
    };
    if (goal.id != null) {
      map[GoalTable.columnId] = goal.id;
    }
    return map;
  }

}
