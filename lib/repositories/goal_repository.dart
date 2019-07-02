import 'package:data_life/paging/page_repository.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/repositories/goal_provider.dart';


class GoalRepository extends PageRepository<Goal> {
  final GoalProvider _goalProvider;

  GoalRepository(this._goalProvider);

  @override
  Future<int> count() async {
    return _goalProvider.count();
  }

  @override
  Future<List<Goal>> get({int startIndex, int count}) async {
    return _goalProvider.get(startIndex: startIndex, count: count);
  }

  Future<int> save(Goal goal) async {
    return _goalProvider.save(goal);
  }

  Future<int> delete(Goal goal) async {
    return _goalProvider.delete(goal);
  }

  Future<int> saveDeleted(Goal goal) async {
    return _goalProvider.saveDeleted(goal);
  }

  Future<int> deleteGoalAction(GoalAction goalAction) async {
    return _goalProvider.deleteGoalAction(goalAction);
  }

  Future<int> saveDeletedGoalAction(GoalAction goalAction) async {
    return _goalProvider.saveDeletedGoalAction(goalAction);
  }

  Future<Goal> getViaName(String name) async {
    return _goalProvider.getViaName(name);
  }

  Future<int> saveGoalAction(GoalAction goalAction) async {
    return _goalProvider.saveGoalAction(goalAction);
  }

  Future<GoalAction> getGoalActionViaActionId(int goalId, int actionId) async {
    return _goalProvider.getGoalActionViaActionId(goalId, actionId);
  }

}
