import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/time_types.dart';


enum GoalStatus {
  none,
  ongoing,
  finished,
  expired,
  paused,
}


class Goal {
  Goal() {
    this.uuid = Uuid().v4();
  }

  String uuid;
  String name;
  num target;
  num progress;
  int startTime;
  int stopTime;
  int doneTime;
  GoalStatus status = GoalStatus.ongoing;
  DurationType durationType;
  int lastActiveTime = 0;
  int totalTimeTaken = 0;
  int createTime;
  int updateTime;

  List<GoalAction> goalActions = <GoalAction>[];

  int calculateTotalTimeTakenFromGoalAction() {
    return goalActions.map((goalAction) {
      return goalAction.totalTimeTaken;
    }).reduce((a, b) => a + b);
  }

  int getProgressPercent() {
    try {
      var percent = (progress / target) * 100;
      return percent.toInt();
    } catch(e) {
      print('Get progress percent failed: ${e.toString()}');
      return 0;
    }
  }

  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(this.startTime);
  set startDateTime(DateTime dateTime) => this.startTime = dateTime.millisecondsSinceEpoch;
  DateTime get stopDateTime => DateTime.fromMillisecondsSinceEpoch(this.stopTime);
  set stopDateTime(DateTime dateTime) => this.stopTime = dateTime.millisecondsSinceEpoch;
  DateTime get doneDateTime => DateTime.fromMillisecondsSinceEpoch(this.doneTime);
  set doneDateTime(DateTime dateTime) => this.doneTime = dateTime.millisecondsSinceEpoch;
  Duration get duration => this.stopDateTime.difference(this.startDateTime);
  Duration get doneDuration => this.doneDateTime.difference(this.startDateTime);

  void updateFieldFromGoalAction() {
    if (goalActions.isNotEmpty) {
      totalTimeTaken = 0;
      lastActiveTime = 0;
      for (var goalAction in goalActions) {
        totalTimeTaken += goalAction.totalTimeTaken;
        lastActiveTime = max(lastActiveTime, goalAction.lastActiveTime);
      }
    }
  }

  static Goal copyCreate(Goal goal) {
    Goal newGoal = Goal();
    newGoal.copy(goal);
    return newGoal;
  }

  bool isContentSameWith(Goal goal) {
    if (name != goal.name) return false;
    if (target != goal.target) return false;
    if (progress != goal.progress) return false;
    if (startTime != goal.startTime) return false;
    if (stopTime != goal.stopTime) return false;
    if (status != goal.status) return false;
    if (durationType != goal.durationType) return false;
    if (lastActiveTime != goal.lastActiveTime) return false;
    if (totalTimeTaken != goal.totalTimeTaken) return false;
    if (createTime != goal.createTime) return false;
    if (updateTime != goal.updateTime) return false;
    if (!_isContentSameGoalActionList(goalActions, goal.goalActions)) return false;
    return true;
  }

  bool _isSameGoalActionList(List<GoalAction> lhs, List<GoalAction> rhs) {
    if (lhs.length != rhs.length) return false;
    for (GoalAction l in lhs) {
      bool founded = false;
      for (GoalAction r in rhs) {
        if (l.isSameWith(r)) {
          founded = true;
          break;
        }
      }
      if (!founded) return false;
    }
    return true;
  }

  bool _isContentSameGoalActionList(List<GoalAction> lhs, List<GoalAction> rhs) {
    if (lhs.length != rhs.length) return false;
    for (GoalAction l in lhs) {
      bool founded = false;
      for (GoalAction r in rhs) {
        if (l.isContentSameWith(r)) {
          founded = true;
          break;
        }
      }
      if (!founded) return false;
    }
    return true;
  }

  bool isSameWith(Goal goal) {
    if (uuid != goal.uuid) return false;
    if (!_isSameGoalActionList(goalActions, goal.goalActions)) return false;
    if (!isContentSameWith(goal)) return false;
    return true;
  }

  void copy(Goal g) {
    uuid = g.uuid;
    name = g.name;
    target = g.target;
    progress = g.progress;
    startTime = g.startTime;
    stopTime = g.stopTime;
    status = g.status;
    durationType = g.durationType;
    lastActiveTime = g.lastActiveTime;
    totalTimeTaken = g.totalTimeTaken;
    createTime = g.createTime;
    updateTime = g.updateTime;
    goalActions = g.goalActions;
  }
}
