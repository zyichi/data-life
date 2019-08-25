import 'package:data_life/models/todo.dart';


class TodoTable {
  static const name = 'todo';

  static const columnGoalUuid = 'goalUuid';
  static const columnGoalActionUuid = 'goalActionUuid';
  static const columnStatus = 'status';
  static const columnStartTime = 'startTime';
  static const columnDoneTime = 'doneTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnGoalUuid text not null,
  $columnGoalActionUuid text not null,
  $columnStatus integer not null,
  $columnStartTime integer not null,
  $columnDoneTime integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null,
  primary key ($columnGoalUuid, $columnGoalActionUuid)
  )
''';

  static List<String> get initSqlList => [createSql,];

  static Todo fromMap(Map map) {
    final todo = Todo();
    todo.goalUuid = map[TodoTable.columnGoalUuid];
    todo.goalActionUuid = map[TodoTable.columnGoalActionUuid];
    todo.status = TodoStatus.values[map[TodoTable.columnStatus] as int];
    todo.startTime = map[TodoTable.columnStartTime] as int;
    todo.doneTime = map[TodoTable.columnDoneTime] as int;
    todo.createTime = map[TodoTable.columnCreateTime] as int;
    todo.updateTime = map[TodoTable.columnUpdateTime] as int;
    return todo;
  }

  static Map<String, dynamic> toMap(Todo todo) {
    var map = <String, dynamic>{
      TodoTable.columnGoalUuid: todo.goalUuid,
      TodoTable.columnGoalActionUuid: todo.goalActionUuid,
      TodoTable.columnStatus: todo.status.index,
      TodoTable.columnStartTime: todo.startTime,
      TodoTable.columnDoneTime: todo.doneTime,
      TodoTable.columnCreateTime: todo.createTime,
      TodoTable.columnUpdateTime: todo.updateTime,
    };
    return map;
  }

}
