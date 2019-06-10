import 'package:data_life/models/action.dart';


class ActionTable {
  static const name = 'action';
  static const columnId = '_id';
  static const columnGoalId = 'goalId';
  static const columnName = 'name';
  static const columnTarget = 'target';
  static const columnProgress = 'progress';
  static const columnHowOften = 'howOften';
  static const columnHowLong = 'howLong';
  static const columnBestTime = 'bestTime';
  static const columnTotalTimeSpend = 'totalTimeSpend';
  static const columnLastActiveTime = 'lastActiveTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnGoalId integer default null,
  $columnName String not null,
  $columnTarget real default null,
  $columnProgress real default null,
  $columnHowOften integer default null,
  $columnHowLong integer default null,
  $columnBestTime integer default null,
  $columnTotalTimeSpend integer default 0,
  $columnLastActiveTime integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static List<String> get initSqlList => [createSql];

  static Action fromMap(Map map) {
    final action = Action();
    action.id = map[ActionTable.columnId] as int;
    action.goalId = map[ActionTable.columnGoalId] as int;
    action.name = map[ActionTable.columnName] as String;
    action.target = map[ActionTable.columnTarget] as num;
    action.progress = map[ActionTable.columnProgress] as num;
    var howOftenIndex = map[ActionTable.columnHowOften];
    if (howOftenIndex != null)
      action.howOften = HowOften.values[howOftenIndex];
    var howLongIndex = map[ActionTable.columnHowLong];
    if (howLongIndex != null)
      action.howLong = HowLong.values[howLongIndex];
    var bestTimeIndex = map[ActionTable.columnBestTime];
    if (howLongIndex != null)
      action.bestTime = BestTime.values[bestTimeIndex];
    action.totalTimeSpend = map[ActionTable.columnTotalTimeSpend] as int;
    action.lastActiveTime = map[ActionTable.columnLastActiveTime] as int;
    action.createTime = map[ActionTable.columnCreateTime] as int;
    action.updateTime = map[ActionTable.columnUpdateTime] as int;
    return action;
  }

  static Map<String, dynamic> toMap(Action action) {
    var map = <String, dynamic>{
      ActionTable.columnGoalId: action.goalId,
      ActionTable.columnName: action.name,
      ActionTable.columnTarget: action.target,
      ActionTable.columnProgress: action.progress,
      ActionTable.columnHowOften: action.howOften?.index,
      ActionTable.columnHowLong: action.howLong?.index,
      ActionTable.columnBestTime: action.bestTime?.index,
      ActionTable.columnTotalTimeSpend: action.totalTimeSpend,
      ActionTable.columnLastActiveTime: action.lastActiveTime,
      ActionTable.columnCreateTime: action.createTime,
      ActionTable.columnUpdateTime: action.updateTime,
    };
    if (action.id != null) {
      map[ActionTable.columnId] = action.id;
    }
    return map;
  }

}
