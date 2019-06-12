import 'package:equatable/equatable.dart';


enum HowOften {
  onceMonth,
  twiceMonth,
  onceWeek,
  twiceWeek,
  threeTimesWeek,
  fourTimesWeek,
  fiveTimesWeek,
  sixTimesWeek,
  everyday,
}
enum HowLong {
  fifteenMinutes,
  thirtyMinutes,
  oneHour,
  twoHours,
  halfDay,
  wholeDay
}
enum BestTime {
  morning,
  afternoon,
  evening,
  anyTime,
}


class Action extends Equatable {
  Action();

  int id;
  int goalId;
  String name;
  num target;
  num progress;
  HowOften howOften;
  HowLong howLong;
  BestTime bestTime;
  int totalTimeTaken = 0;
  int lastActiveTime;
  int createTime;
  int updateTime;

  @override
  List get props => [name];

  static bool isSameAction(Action lhs, Action rhs) {
    return lhs == rhs;
  }

  void copy(Action a) {
    id = a.id;
    goalId = a.goalId;
    name = a.name;
    target = a.target;
    progress = a.progress;
    howOften = a.howOften;
    howLong = a.howLong;
    bestTime = a.bestTime;
    totalTimeTaken = a.totalTimeTaken;
    lastActiveTime = a.lastActiveTime;
    createTime = a.createTime;
    updateTime = a.updateTime;
  }
  
  bool isSameWith(Action a) {
    if (id != a.id) return false;
    if (goalId != a.goalId) return false;
    if (!isContentSameWith(a)) return false;
    return true;
  }
  
  bool isContentSameWith(Action a) {
    if (goalId != a.goalId) return false;
    if (name != a.name) return false;
    if (target != a.target) return false;
    if (progress != a.progress) return false;
    if (howOften != a.howOften) return false;
    if (howLong != a.howLong) return false;
    if (bestTime != a.bestTime) return false;
    if (totalTimeTaken != a.totalTimeTaken) return false;
    if (lastActiveTime != a.lastActiveTime) return false;
    if (createTime != a.createTime) return false;
    if (updateTime != a.updateTime) return false;
    return true;
  }
}
