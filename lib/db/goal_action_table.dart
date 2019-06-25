import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/time_types.dart';


class GoalActionTable {
  static const name = 'action';
  static const columnId = '_id';
  static const columnGoalId = 'goalId';
  static const columnActionId = 'actionId';
  static const columnDurationValue = 'durationValue';
  static const columnDurationUnit = 'durationUnit';
  static const columnTarget = 'target';
  static const columnProgress = 'progress';
  static const columnHowOften = 'howOften';
  static const columnHowLong = 'howLong';
  static const columnBestTime = 'bestTime';
  static const columnTotalTimeTaken = 'totalTimeTaken';
  static const columnLastActiveTime = 'lastActiveTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnGoalId integer not null,
  $columnActionId integer not null,
  $columnDurationValue integer default null,
  $columnDurationUnit integer default null,
  $columnTarget real default null,
  $columnProgress real default null,
  $columnHowOften integer default null,
  $columnHowLong integer default null,
  $columnBestTime integer default null,
  $columnTotalTimeTaken integer default 0,
  $columnLastActiveTime integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static List<String> get initSqlList => [createSql];

  static GoalAction fromMap(Map map) {
    final goalAction = GoalAction();
    goalAction.id = map[GoalActionTable.columnId] as int;
    goalAction.goalId = map[GoalActionTable.columnGoalId] as int;
    goalAction.actionId = map[GoalActionTable.columnActionId] as int;
    goalAction.durationValue = map[GoalActionTable.columnDurationValue] as int;
    var durationUnitIndex = map[GoalActionTable.columnDurationUnit];
    if (durationUnitIndex != null)
      goalAction.durationUnit = DurationUnit.values[durationUnitIndex];
    goalAction.target = map[GoalActionTable.columnTarget] as num;
    goalAction.progress = map[GoalActionTable.columnProgress] as num;
    var howOftenIndex = map[GoalActionTable.columnHowOften];
    if (howOftenIndex != null)
      goalAction.howOften = HowOften.values[howOftenIndex];
    var howLongIndex = map[GoalActionTable.columnHowLong];
    if (howLongIndex != null)
      goalAction.howLong = HowLong.values[howLongIndex];
    var bestTimeIndex = map[GoalActionTable.columnBestTime];
    if (howLongIndex != null)
      goalAction.bestTime = BestTime.values[bestTimeIndex];
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
      GoalActionTable.columnDurationValue: goalAction.durationValue,
      GoalActionTable.columnDurationUnit: goalAction.durationUnit?.index,
      GoalActionTable.columnTarget: goalAction.target,
      GoalActionTable.columnProgress: goalAction.progress,
      GoalActionTable.columnHowOften: goalAction.howOften?.index,
      GoalActionTable.columnHowLong: goalAction.howLong?.index,
      GoalActionTable.columnBestTime: goalAction.bestTime?.index,
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
