import 'package:data_life/models/goal_action.dart';

import 'package:data_life/models/time_types.dart';

class Goal {
  Goal();

  int id;
  String name;
  num target;
  num progress;
  int startTime;
  int stopTime;
  DurationType durationType;
  int lastActiveTime;
  int totalTimeTaken = 0;
  int createTime;
  int updateTime;

  List<GoalAction> goalActions = <GoalAction>[];

  int calculateTotalTimeTakenFromGoalAction() {
    return goalActions.map((goalAction) {
      return goalAction.totalTimeTaken;
    }).reduce((a, b) => a + b);
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
    if (id != goal.id) return false;
    if (!_isSameGoalActionList(goalActions, goal.goalActions)) return false;
    if (!isContentSameWith(goal)) return false;
    return true;
  }

  void copy(Goal g) {
    id = g.id;
    name = g.name;
    target = g.target;
    progress = g.progress;
    startTime = g.startTime;
    stopTime = g.stopTime;
    durationType = g.durationType;
    lastActiveTime = g.lastActiveTime;
    totalTimeTaken = g.totalTimeTaken;
    createTime = g.createTime;
    updateTime = g.updateTime;
    goalActions = g.goalActions;
  }
}
