import 'package:equatable/equatable.dart';

import 'package:data_life/models/action.dart';
import 'package:data_life/models/repeat_types.dart';


class GoalAction extends Equatable {
  GoalAction();

  int id;
  int goalId;
  int actionId;
  int startTime;
  int stopTime;
  RepeatType repeatType;
  RepeatEvery repeatEvery;
  int repeatEveryStep;
  MonthRepeatOn monthRepeatOn;
  WeekdaySeqOfMonth weekdaySeqOfMonth;
  List<int> repeatOnList = <int>[];
  int totalTimeTaken = 0;
  int lastActiveTime;
  int createTime;
  int updateTime;
  
  Action _action;

  Action get action => _action;
  set action(Action a) {
    _action = a;
    actionId = a?.id;
  }

  @override
  List get props => [goalId, actionId, action.name];

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

  bool isContentSameWith(GoalAction goalAction) {
    if (goalId != goalAction.goalId) return false;
    if (actionId != goalAction.actionId) return false;
    if (startTime != goalAction.startTime) return false;
    if (stopTime != goalAction.stopTime) return false;
    if (totalTimeTaken != goalAction.totalTimeTaken) return false;
    if (lastActiveTime != goalAction.lastActiveTime) return false;
    if (createTime != goalAction.createTime) return false;
    if (updateTime != goalAction.updateTime) return false;
    if (!action.isContentSameWith(goalAction.action)) return false;
    return true;
  }
}
