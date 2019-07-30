import 'package:equatable/equatable.dart';


class MyAction extends Equatable {
  MyAction();

  int id;
  String name;
  int totalTimeTaken = 0;
  int lastActiveTime = 0;
  int createTime;
  int updateTime;

  @override
  List get props => [name];

  void copy(MyAction a) {
    id = a.id;
    name = a.name;
    totalTimeTaken = a.totalTimeTaken;
    lastActiveTime = a.lastActiveTime;
    createTime = a.createTime;
    updateTime = a.updateTime;
  }
  
  bool isSameWith(MyAction a) {
    if (id != a.id) return false;
    if (!isContentSameWith(a)) return false;
    return true;
  }
  
  bool isContentSameWith(MyAction a) {
    if ((name ?? '') != (a.name ?? '')) return false;
    if (totalTimeTaken != a.totalTimeTaken) return false;
    if (lastActiveTime != a.lastActiveTime) return false;
    if (createTime != a.createTime) return false;
    if (updateTime != a.updateTime) return false;
    return true;
  }
}
