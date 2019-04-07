import 'package:data_life/life_db.dart';

enum HowOften {
  onceMonth, twiceMonth, onceWeek, twiceWeek, threeTimesWeek, fourTimesWeek,
  fiveTimesWeek, sixTimesWeek, everyday,
}
enum HowLong {
  fifteenMinutes, thirtyMinutes, oneHour, twoHours, halfDay, wholeDay
}
enum BestTime {
  morning, afternoon, evening, anyTime,
}

class Activity {
  Activity();

  int id;
  int goalId;
  String name;
  num target;
  num alreadyCompleted;
  int startTime;
  int duration;
  int timeSpent;
  HowOften howOften;
  HowLong howLong;
  BestTime bestTime;
  int lastActiveTime;
  int createTime;
  int updateTime;

  Activity.fromMap(Map map) {
    id = map[ActivityTable.columnId] as int;
    goalId = map[ActivityTable.columnGoalId] as int;
    name = map[ActivityTable.columnName] as String;
    target = map[ActivityTable.columnTarget] as num;
    alreadyCompleted = map[ActivityTable.columnAlreadyDone] as num;
    startTime = map[ActivityTable.columnStartTime] as int;
    duration = map[ActivityTable.columnDuration] as int;
    timeSpent = map[ActivityTable.columnTimeSpent] as int;
    howOften = HowOften.values[map[ActivityTable.columnHowOften]];
    howLong = HowLong.values[map[ActivityTable.columnHowLong]];
    bestTime = BestTime.values[map[ActivityTable.columnBestTime]];
    lastActiveTime = map[ActivityTable.columnLastActiveTime] as int;
    createTime = map[ActivityTable.columnCreateTime] as int;
    updateTime = map[ActivityTable.columnUpdateTime] as int;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      ActivityTable.columnGoalId: goalId,
      ActivityTable.columnName: name,
      ActivityTable.columnTarget: target,
      ActivityTable.columnAlreadyDone: alreadyCompleted,
      ActivityTable.columnStartTime: startTime,
      ActivityTable.columnDuration: duration,
      ActivityTable.columnTimeSpent: timeSpent,
      ActivityTable.columnHowOften: howOften.index,
      ActivityTable.columnHowLong: howLong.index,
      ActivityTable.columnBestTime: bestTime.index,
      ActivityTable.columnLastActiveTime: lastActiveTime,
      ActivityTable.columnCreateTime: createTime,
      ActivityTable.columnUpdateTime: updateTime,
    };
    if (id != null) {
      map[ActivityTable.columnId] = id;
    }
    return map;
  }
}
