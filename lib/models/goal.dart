import 'package:data_life/life_db.dart';
import 'package:data_life/models/activity.dart';


class Goal {
  Goal();

  int id;
  String name;
  num target;
  num alreadyDone;
  int startTime;
  int duration;
  int lastActiveTime;
  int createTime;

  List<Activity> actions;

  static dynamic keyFromValue(Map map, dynamic value) {
    for (var k in map.keys) {
      var v = map[k];
      if (v == value) {
        return k;
      }
    }
    return null;
  }

  Goal.fromMap(Map map) {
    id = map[GoalTable.columnId] as int;
    name = map[GoalTable.columnName] as String;
    target = map[GoalTable.columnTarget] as num;
    alreadyDone = map[GoalTable.columnAlreadyDone] as num;
    lastActiveTime = map[GoalTable.columnLastActiveTime] as int;
    startTime = map[GoalTable.columnStartTime] as int;
    duration = map[GoalTable.columnDuration] as int;
    createTime = map[GoalTable.columnCreateTime] as int;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      GoalTable.columnName: name,
      GoalTable.columnTarget: target,
      GoalTable.columnAlreadyDone: alreadyDone,
      GoalTable.columnStartTime: startTime,
      GoalTable.columnDuration: duration,
      GoalTable.columnLastActiveTime: lastActiveTime,
      GoalTable.columnCreateTime: createTime,
    };
    if (id != null) {
      map[GoalTable.columnId] = id;
    }
    return map;
  }

}

