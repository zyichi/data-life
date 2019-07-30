import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';


enum TodoStatus {
  waiting,
  done,
  dismiss,
}

class Todo {
  Todo();

  int id;
  int goalId;
  int goalActionId;
  int startTime;
  int doneTime;
  TodoStatus status;
  int createTime;
  int updateTime;

  GoalAction goalAction;
  Goal goal;
}
