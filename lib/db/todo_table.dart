import 'package:data_life/models/todo.dart';


class TodoTable {
  static const name = 'todo';

  static const columnId = '_id';
  static const columnGoalId = 'goalId';
  static const columnGoalActionId = 'goalActionId';
  static const columnStatus = 'status';
  static const columnStartTime = 'startTime';
  static const columnDoneTime = 'doneTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnGoalId integer not null,
  $columnGoalActionId integer not null,
  $columnStatus integer not null,
  $columnStartTime integer not null,
  $columnDoneTime integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static List<String> get initSqlList => [createSql,];

  static Todo fromMap(Map map) {
    final todo = Todo();
    todo.id = map[TodoTable.columnId] as int;
    todo.goalId = map[TodoTable.columnGoalId] as int;
    todo.goalActionId = map[TodoTable.columnGoalActionId] as int;
    todo.status = TodoStatus.values[map[TodoTable.columnStatus] as int];
    todo.startTime = map[TodoTable.columnStartTime] as int;
    todo.doneTime = map[TodoTable.columnDoneTime] as int;
    todo.createTime = map[TodoTable.columnCreateTime] as int;
    todo.updateTime = map[TodoTable.columnUpdateTime] as int;
    return todo;
  }

  static Map<String, dynamic> toMap(Todo todo) {
    var map = <String, dynamic>{
      TodoTable.columnGoalId: todo.goalId,
      TodoTable.columnGoalActionId: todo.goalActionId,
      TodoTable.columnStatus: todo.status.index,
      TodoTable.columnStartTime: todo.startTime,
      TodoTable.columnDoneTime: todo.doneTime,
      TodoTable.columnCreateTime: todo.createTime,
      TodoTable.columnUpdateTime: todo.updateTime,
    };
    if (todo.id != null) {
      map[TodoTable.columnId] = todo.id;
    }
    return map;
  }

}
