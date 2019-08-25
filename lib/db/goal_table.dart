import 'package:data_life/models/goal.dart';
import 'package:data_life/models/time_types.dart';

class GoalTable {
  static const name = 'goal';
  static const deletedName = 'deleted_goal';

  static const columnUuid = 'uuid';
  static const columnName = 'name';
  static const columnTarget = 'target';
  static const columnProgress = 'progress';
  static const columnStartTime = 'startTime';
  static const columnStopTime = 'stopTime';
  static const columnStatus = 'status';
  static const columnDurationType = 'durationType';
  static const columnLastActiveTime = 'lastActiveTime';
  static const columnTotalTimeTaken = 'totalTimeTaken';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createIndexSql = '''
create unique index goal_name_idx on $name(
  $columnName);
''';

  static String getCreateTableSql(String tableName) {
    return '''
create table $tableName (
  $columnUuid text primary key,
  $columnName text not null,
  $columnTarget real default null,
  $columnProgress real default null,
  $columnStartTime integer default null,
  $columnStopTime integer default null,
  $columnStatus integer default null,
  $columnDurationType integer default null,
  $columnLastActiveTime integer default null,
  $columnTotalTimeTaken integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';
  }

  static List<String> get initSqlList => [
        getCreateTableSql(GoalTable.name),
        getCreateTableSql(GoalTable.deletedName),
        createIndexSql
      ];

  static Goal fromMap(Map map) {
    final Goal goal = Goal();
    goal.uuid = map[GoalTable.columnUuid];
    goal.name = map[GoalTable.columnName] as String;
    goal.target = map[GoalTable.columnTarget] as num;
    goal.progress = map[GoalTable.columnProgress] as num;
    goal.startTime = map[GoalTable.columnStartTime] as int;
    goal.stopTime = map[GoalTable.columnStopTime] as int;
    goal.status = GoalStatus.values[map[GoalTable.columnStatus] ?? GoalStatus.none.index];
    goal.durationType = DurationType.values[map[GoalTable.columnDurationType] ?? DurationType.none.index];
    goal.totalTimeTaken = map[GoalTable.columnTotalTimeTaken] as int;
    goal.lastActiveTime = map[GoalTable.columnLastActiveTime] as int;
    goal.createTime = map[GoalTable.columnCreateTime] as int;
    goal.updateTime = map[GoalTable.columnUpdateTime] as int;
    return goal;
  }

  static Map<String, dynamic> toMap(Goal goal) {
    var map = <String, dynamic>{
      GoalTable.columnUuid: goal.uuid,
      GoalTable.columnName: goal.name,
      GoalTable.columnTarget: goal.target,
      GoalTable.columnProgress: goal.progress,
      GoalTable.columnStartTime: goal.startTime,
      GoalTable.columnStopTime: goal.stopTime,
      GoalTable.columnStatus: goal.status?.index,
      GoalTable.columnDurationType: goal.durationType?.index,
      GoalTable.columnLastActiveTime: goal.lastActiveTime,
      GoalTable.columnTotalTimeTaken: goal.totalTimeTaken,
      GoalTable.columnCreateTime: goal.createTime,
      GoalTable.columnUpdateTime: goal.updateTime,
    };
    return map;
  }
}
