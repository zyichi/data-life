import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';


enum TodoStatus {
  waiting,
  done,
  dismiss,
}

class Todo {
  Todo();

  String goalUuid;
  int actionId;
  int startTime;
  int doneTime;
  TodoStatus status;
  int createTime;
  int updateTime;

  GoalAction goalAction;
  Goal goal;

  DateTime get startDateTime => DateTime.fromMillisecondsSinceEpoch(this.startTime);
  set startDateTime(DateTime value) => this.startTime = value.millisecondsSinceEpoch;

  DateTime get doneDateTime => DateTime.fromMillisecondsSinceEpoch(this.doneTime ?? 0);
  set doneDateTime(DateTime value) => this.doneTime = value.millisecondsSinceEpoch;
}
