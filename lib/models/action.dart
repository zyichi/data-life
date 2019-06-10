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


class Action {
  Action();

  int id;
  int goalId;
  String name;
  num target;
  num progress;
  HowOften howOften;
  HowLong howLong;
  BestTime bestTime;
  int totalTimeSpend = 0;
  int lastActiveTime;
  int createTime;
  int updateTime;

  static bool isSameAction(Action lhs, Action rhs) {
    return lhs.name == rhs.name;
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
    totalTimeSpend = a.totalTimeSpend;
    lastActiveTime = a.lastActiveTime;
    createTime = a.createTime;
    updateTime = a.updateTime;
  }
}
