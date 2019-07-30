import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/repeat_types.dart';
import 'dart:convert';


class GoalActionTable {
  static const name = 'goal_action';
  static const deletedName = 'deleted_goal_action';

  static const columnId = '_id';
  static const columnGoalId = 'goalId';
  static const columnActionId = 'actionId';
  static const columnStartTime = 'startTime';
  static const columnStopTime = 'stopTime';
  static const columnStatus = 'status';
  static const columnRepeatType = 'repeatType';
  static const columnRepeatEvery = 'repeatEvery';
  static const columnRepeatEveryStep = 'repeatEveryStep';
  static const columnMonthRepeatOn = 'monthRepeatOn';
  static const columnWeekdaySeqOfMonth = 'weekdaySeqOfMonth';
  static const columnRepeatOnList = 'repeatOnList';
  static const columnTotalTimeTaken = 'totalTimeTaken';
  static const columnLastActiveTime = 'lastActiveTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createIndexSql = '''
create unique index goal_action_idx on $name(
  $columnGoalId, $columnActionId);
''';

  static String getCreateTableSql(String tableName) {
    return '''
create table $tableName (
  $columnId integer primary key autoincrement,
  $columnGoalId integer not null,
  $columnActionId integer not null,
  $columnStartTime integer default null,
  $columnStopTime integer default null,
  $columnStatus integer default null,
  $columnRepeatType integer not null,
  $columnRepeatEvery integer not null,
  $columnRepeatEveryStep integer not null,
  $columnMonthRepeatOn integer default null,
  $columnWeekdaySeqOfMonth integer default null,
  $columnRepeatOnList text not null,
  $columnTotalTimeTaken integer default 0,
  $columnLastActiveTime integer default 0,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';
  }

  static List<String> get initSqlList => [
    getCreateTableSql(GoalActionTable.name),
    getCreateTableSql(GoalActionTable.deletedName),
    createIndexSql,
  ];

  static GoalAction fromMap(Map map) {
    final goalAction = GoalAction();
    goalAction.id = map[GoalActionTable.columnId] as int;
    goalAction.goalId = map[GoalActionTable.columnGoalId] as int;
    goalAction.actionId = map[GoalActionTable.columnActionId] as int;
    goalAction.startTime = map[GoalActionTable.columnStartTime] as int;
    goalAction.stopTime = map[GoalActionTable.columnStopTime] as int;
    goalAction.status = GoalActionStatus.values[map[GoalActionTable.columnStatus]];
    goalAction.repeatType = RepeatType.values[map[GoalActionTable.columnRepeatType]];
    goalAction.repeatEvery = RepeatEvery.values[map[GoalActionTable.columnRepeatEvery]];
    goalAction.repeatEveryStep = map[GoalActionTable.columnRepeatEveryStep] as int;
    var repeatOnIndex = map[GoalActionTable.columnMonthRepeatOn];
    if (repeatOnIndex != null) goalAction.monthRepeatOn = MonthRepeatOn.values[repeatOnIndex];
    var weekSeqIndex = map[GoalActionTable.columnWeekdaySeqOfMonth];
    if (weekSeqIndex != null) goalAction.weekdaySeqOfMonth = WeekdaySeqOfMonth.values[weekSeqIndex];
    List<dynamic> l = jsonDecode(map[GoalActionTable.columnRepeatOnList]);
    goalAction.repeatOnList = l.cast<int>();
    goalAction.totalTimeTaken = map[GoalActionTable.columnTotalTimeTaken] as int;
    goalAction.lastActiveTime = map[GoalActionTable.columnLastActiveTime] as int;
    goalAction.createTime = map[GoalActionTable.columnCreateTime] as int;
    goalAction.updateTime = map[GoalActionTable.columnUpdateTime] as int;
    return goalAction;
  }

  static Map<String, dynamic> toMap(GoalAction goalAction) {
    var map = <String, dynamic>{
      GoalActionTable.columnGoalId: goalAction.goalId,
      GoalActionTable.columnActionId: goalAction.actionId,
      GoalActionTable.columnStartTime: goalAction.startTime,
      GoalActionTable.columnStopTime: goalAction.stopTime,
      GoalActionTable.columnStatus: goalAction.status.index,
      GoalActionTable.columnRepeatType: goalAction.repeatType.index,
      GoalActionTable.columnRepeatEvery: goalAction.repeatEvery.index,
      GoalActionTable.columnRepeatEveryStep: goalAction.repeatEveryStep,
      GoalActionTable.columnMonthRepeatOn: goalAction.monthRepeatOn?.index,
      GoalActionTable.columnWeekdaySeqOfMonth: goalAction.weekdaySeqOfMonth?.index,
      GoalActionTable.columnRepeatOnList: jsonEncode(goalAction.repeatOnList),
      GoalActionTable.columnTotalTimeTaken: goalAction.totalTimeTaken,
      GoalActionTable.columnLastActiveTime: goalAction.lastActiveTime,
      GoalActionTable.columnCreateTime: goalAction.createTime,
      GoalActionTable.columnUpdateTime: goalAction.updateTime,
    };
    if (goalAction.id != null) {
      map[GoalActionTable.columnId] = goalAction.id;
    }
    return map;
  }

}
