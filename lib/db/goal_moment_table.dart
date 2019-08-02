import 'package:data_life/models/goal_moment.dart';


class GoalMomentTable {
  static const name = 'goal_moment';

  static const columnId = '_id';
  static const columnGoalId = 'goalId';
  static const columnGoalActionId = 'actionId';
  static const columnMomentId = 'momentId';
  static const columnMomentBeginTime = 'momentBeginTime';
  static const columnCreateTime = 'createTime';

  static const createIndexSql = '''
create unique index goal_action_moment_idx on $name(
  $columnGoalId, $columnGoalActionId, $columnMomentId);
''';

  static String getCreateTableSql(String tableName) {
    return '''
create table $tableName (
  $columnId integer primary key autoincrement,
  $columnGoalId integer not null,
  $columnGoalActionId integer not null,
  $columnMomentId integer not null,
  $columnMomentBeginTime integer not null,
  $columnCreateTime integer not null)
''';
  }

  static List<String> get initSqlList => [
    getCreateTableSql(GoalMomentTable.name),
    createIndexSql,
  ];

  static GoalMoment fromMap(Map map) {
    final goalMoment = GoalMoment();
    goalMoment.id = map[GoalMomentTable.columnId] as int;
    goalMoment.goalId = map[GoalMomentTable.columnGoalId] as int;
    goalMoment.goalActionId = map[GoalMomentTable.columnGoalActionId] as int;
    goalMoment.momentId = map[GoalMomentTable.columnMomentId] as int;
    goalMoment.momentBeginTime = map[GoalMomentTable.columnMomentBeginTime] as int;
    goalMoment.createTime = map[GoalMomentTable.columnCreateTime] as int;
    return goalMoment;
  }

  static Map<String, dynamic> toMap(GoalMoment goalMoment) {
    var map = <String, dynamic>{
      GoalMomentTable.columnGoalId: goalMoment.goalId,
      GoalMomentTable.columnGoalActionId: goalMoment.goalActionId,
      GoalMomentTable.columnMomentId: goalMoment.momentId,
      GoalMomentTable.columnMomentBeginTime: goalMoment.momentBeginTime,
      GoalMomentTable.columnCreateTime: goalMoment.createTime,
    };
    if (goalMoment.id != null) {
      map[GoalMomentTable.columnId] = goalMoment.id;
    }
    return map;
  }

}
