import 'package:equatable/equatable.dart';

import 'package:data_life/models/action.dart';
import 'package:data_life/models/time_types.dart';


class GoalAction extends Equatable {
  GoalAction();

  int id;
  int goalId;
  int actionId;
  num target;
  num progress;
  int durationValue;
  DurationUnit durationUnit;
  HowOften howOften;
  HowLong howLong;
  BestTime bestTime;
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
  List get props => [goalId, actionId];

  void copy(GoalAction goalAction) {
    id = goalAction.id;
    goalId = goalAction.goalId;
    actionId = goalAction.actionId;
    durationValue = goalAction.durationValue;
    durationUnit = goalAction.durationUnit;
    target = goalAction.target;
    progress = goalAction.progress;
    howOften = goalAction.howOften;
    howLong = goalAction.howLong;
    bestTime = goalAction.bestTime;
    totalTimeTaken = goalAction.totalTimeTaken;
    lastActiveTime = goalAction.lastActiveTime;
    createTime = goalAction.createTime;
    updateTime = goalAction.updateTime;
  }

  bool isSameWith(GoalAction goalAction) {
    if (id != goalAction.id) return false;
    if (!isContentSameWith(goalAction)) return false;
    if (action.id != goalAction.action.id) return false;
    if (!action.isContentSameWith(goalAction.action)) return false;
    return true;
  }

  bool isContentSameWith(GoalAction goalAction) {
    if (goalId != goalAction.goalId) return false;
    if (actionId != goalAction.actionId) return false;
    if (durationValue != goalAction.durationValue) return false;
    if (durationUnit != goalAction.durationUnit) return false;
    if (target != goalAction.target) return false;
    if (progress != goalAction.progress) return false;
    if (howOften != goalAction.howOften) return false;
    if (howLong != goalAction.howLong) return false;
    if (bestTime != goalAction.bestTime) return false;
    if (totalTimeTaken != goalAction.totalTimeTaken) return false;
    if (lastActiveTime != goalAction.lastActiveTime) return false;
    if (createTime != goalAction.createTime) return false;
    if (updateTime != goalAction.updateTime) return false;
    if (!action.isContentSameWith(goalAction.action)) return false;
    return true;
  }
}
