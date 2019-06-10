import 'package:data_life/models/goal.dart';


class GoalTable {
  static const name = 'goal';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnTarget = 'target';
  static const columnProgress = 'progress';
  static const columnStartTime = 'startTime';
  static const columnDuration = 'duration';
  static const columnCreateTime = 'createTime';
  static const columnLastActiveTime = 'lastActiveTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnName String not null,
  $columnTarget real default null,
  $columnProgress real default null,
  $columnStartTime integer default null,
  $columnDuration integer default null,
  $columnLastActiveTime integer default null,
  $columnCreateTime integer not null)
''';

  static List<String> get initSqlList => [createSql];

  static Goal fromMap(Map map) {
    final Goal goal = Goal();
    goal.id = map[GoalTable.columnId] as int;
    goal.name = map[GoalTable.columnName] as String;
    goal.target = map[GoalTable.columnTarget] as num;
    goal.progress = map[GoalTable.columnProgress] as num;
    goal.lastActiveTime = map[GoalTable.columnLastActiveTime] as int;
    goal.startTime = map[GoalTable.columnStartTime] as int;
    goal.duration = map[GoalTable.columnDuration] as int;
    goal.createTime = map[GoalTable.columnCreateTime] as int;
    return goal;
  }

  static Map<String, dynamic> toMap(Goal goal) {
    var map = <String, dynamic>{
      GoalTable.columnName: name,
      GoalTable.columnTarget: goal.target,
      GoalTable.columnProgress: goal.progress,
      GoalTable.columnStartTime: goal.startTime,
      GoalTable.columnDuration: goal.duration,
      GoalTable.columnLastActiveTime: goal.lastActiveTime,
      GoalTable.columnCreateTime: goal.createTime,
    };
    if (goal.id != null) {
      map[GoalTable.columnId] = goal.id;
    }
    return map;
  }

}
