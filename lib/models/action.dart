import 'package:equatable/equatable.dart';


class Action extends Equatable {
  Action();

  int id;
  String name;
  int totalTimeTaken = 0;
  int lastActiveTime;
  int createTime;
  int updateTime;

  @override
  List get props => [name];

  void copy(Action a) {
    id = a.id;
    name = a.name;
    totalTimeTaken = a.totalTimeTaken;
    lastActiveTime = a.lastActiveTime;
    createTime = a.createTime;
    updateTime = a.updateTime;
  }
  
  bool isSameWith(Action a) {
    if (id != a.id) return false;
    if (!isContentSameWith(a)) return false;
    return true;
  }
  
  bool isContentSameWith(Action a) {
    if ((name ?? '') != (a.name ?? '')) return false;
    if (totalTimeTaken != a.totalTimeTaken) return false;
    if (lastActiveTime != a.lastActiveTime) return false;
    if (createTime != a.createTime) return false;
    if (updateTime != a.updateTime) return false;
    return true;
  }
}
