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
  int createTime;
  int updateTime;

  List<GoalAction> goalActions = <GoalAction>[];

  int get totalTimeTaken => goalActions.map((goalAction) {
        return goalAction.totalTimeTaken;
      }).reduce((a, b) => a + b);

  static Goal copyCreate(Goal goal) {
    Goal newGoal = Goal();
    newGoal.copy(goal);
    return newGoal;
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
    createTime = g.createTime;
    updateTime = g.updateTime;
    goalActions = g.goalActions;
  }
}
