import 'package:data_life/models/action.dart';


class Goal {
  Goal();

  int id;
  String name;
  num target;
  num progress;
  int startTime;
  int duration;
  int lastActiveTime;
  int createTime;

  List<Action> actions;
}

