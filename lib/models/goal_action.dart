import 'package:data_life/models/action.dart';
import 'package:data_life/models/repeat_types.dart';
import 'package:flutter/cupertino.dart';


enum GoalActionStatus {
  ongoing,
  paused,
  finished,
}

class GoalAction {
  GoalAction();

  int id;
  int goalId;
  int actionId;
  int startTime;
  int stopTime;

  GoalActionStatus status = GoalActionStatus.ongoing;

  // Repeat field begin
  RepeatType repeatType;
  RepeatEvery repeatEvery;
  int repeatEveryStep;
  MonthRepeatOn monthRepeatOn;
  WeekdaySeqOfMonth weekdaySeqOfMonth;
  List<int> repeatOnList = <int>[];
  // Repeat field end

  int totalTimeTaken = 0;
  int lastActiveTime = 0;
  int createTime;
  int updateTime;
  
  MyAction _action;

  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(this.startTime);
  set startDateTime(DateTime dateTime) => this.startTime = dateTime.millisecondsSinceEpoch;
  DateTime get stopDateTime => DateTime.fromMillisecondsSinceEpoch(this.stopTime);
  set stopDateTime(DateTime dateTime) => this.stopTime = dateTime.millisecondsSinceEpoch;
  int get durationInDays => this.stopDateTime.difference(this.startDateTime).inDays;

  MyAction get action => _action;
  set action(MyAction a) {
    _action = a;
    actionId = a?.id;
  }

  bool equal(GoalAction goalAction) {
    if (goalId != goalAction.goalId) return false;
    if (actionId != goalAction.actionId) return false;
    if (action?.name != goalAction.action?.name) return false;
    return true;
  }

  String durationStrInHms(BuildContext context) {
    var parts = <String>[];
    Duration duration = this.stopDateTime.difference(this.startDateTime);
    int days = duration.inDays;
    if (days > 0) {
      parts.add('$days 天');
    }
    int hours = duration.inHours % 24;
    if (hours > 0) {
      parts.add('$hours 小时');
    }
    int minutes = duration.inMinutes % 60;
    if (minutes > 0) {
      parts.add('$minutes 分钟');
    }
    return parts.join(' ');
  }

  Repeat getRepeat() {
    var repeat = Repeat();
    repeat.type = this.repeatType;
    repeat.startTime = DateTime.fromMillisecondsSinceEpoch(this.startTime);
    repeat.every = this.repeatEvery;
    repeat.everyStep = this.repeatEveryStep;
    repeat.onList = this.repeatOnList;
    repeat.monthRepeatOn = this.monthRepeatOn;
    repeat.weekdaySeqOfMonth = this.weekdaySeqOfMonth;
    return repeat;
  }

  void setRepeat(Repeat repeat) {
    this.repeatType = repeat.type;
    this.startTime = repeat.startTime.millisecondsSinceEpoch;
    this.repeatEvery = repeat.every;
    this.repeatEveryStep = repeat.everyStep;
    this.repeatOnList = repeat.onList;
    this.monthRepeatOn = repeat.monthRepeatOn;
    this.weekdaySeqOfMonth = repeat.weekdaySeqOfMonth;
  }

  static GoalAction copeCreate(GoalAction g) {
    var goalAction = GoalAction();
    goalAction.copy(g);
    return goalAction;
  }

  void copy(GoalAction goalAction) {
    id = goalAction.id;
    goalId = goalAction.goalId;
    actionId = goalAction.actionId;
    startTime = goalAction.startTime;
    stopTime = goalAction.stopTime;
    status = goalAction.status;
    repeatType = goalAction.repeatType;
    repeatEvery = goalAction.repeatEvery;
    repeatEveryStep = goalAction.repeatEveryStep;
    monthRepeatOn = goalAction.monthRepeatOn;
    weekdaySeqOfMonth = goalAction.weekdaySeqOfMonth;
    repeatOnList = goalAction.repeatOnList;
    totalTimeTaken = goalAction.totalTimeTaken;
    lastActiveTime = goalAction.lastActiveTime;
    createTime = goalAction.createTime;
    updateTime = goalAction.updateTime;
    action = goalAction.action;
  }

  bool isSameWith(GoalAction goalAction) {
    if (id != goalAction.id) return false;
    if (!isContentSameWith(goalAction)) return false;
    if (!action.isSameWith(goalAction.action)) return false;
    return true;
  }

  bool isSameRepeatOnList(List<int> lhs, List<int> rhs) {
    if (lhs.length != rhs.length) return false;
    for (int i = 0; i < lhs.length; i++) {
      if (lhs[i] != rhs[i]) {
        return false;
      }
    }
    return true;
  }

  bool isContentSameWith(GoalAction goalAction) {
    if (goalId != goalAction.goalId) return false;
    if (actionId != goalAction.actionId) return false;
    if (startTime != goalAction.startTime) return false;
    if (stopTime != goalAction.stopTime) return false;
    if (status != goalAction.status) return false;
    if (repeatType != goalAction.repeatType) return false;
    if (repeatEvery != goalAction.repeatEvery) return false;
    if (repeatEveryStep != goalAction.repeatEveryStep) return false;
    if (monthRepeatOn != goalAction.monthRepeatOn) return false;
    if (weekdaySeqOfMonth != goalAction.weekdaySeqOfMonth) return false;
    if (!isSameRepeatOnList(repeatOnList, goalAction.repeatOnList)) return false;
    if (totalTimeTaken != goalAction.totalTimeTaken) return false;
    if (lastActiveTime != goalAction.lastActiveTime) return false;
    if (createTime != goalAction.createTime) return false;
    if (updateTime != goalAction.updateTime) return false;
    if (!action.isContentSameWith(goalAction.action)) return false;
    return true;
  }
}
