import 'package:data_life/models/action.dart';


class ActionTable {
  static const name = 'action';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnTotalTimeTaken = 'totalTimeTaken';
  static const columnLastActiveTime = 'lastActiveTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnName text not null,
  $columnTotalTimeTaken integer default 0,
  $columnLastActiveTime integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static const createIndexSql = '''
create unique index action_name_idx on $name(
  $columnName);
''';

  static List<String> get initSqlList => [createSql, createIndexSql];

  static Action fromMap(Map map) {
    final action = Action();
    action.id = map[ActionTable.columnId] as int;
    action.name = map[ActionTable.columnName] as String;
    action.totalTimeTaken = map[ActionTable.columnTotalTimeTaken] as int;
    action.lastActiveTime = map[ActionTable.columnLastActiveTime] as int;
    action.createTime = map[ActionTable.columnCreateTime] as int;
    action.updateTime = map[ActionTable.columnUpdateTime] as int;
    return action;
  }

  static Map<String, dynamic> toMap(Action action) {
    var map = <String, dynamic>{
      ActionTable.columnName: action.name,
      ActionTable.columnTotalTimeTaken: action.totalTimeTaken,
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
