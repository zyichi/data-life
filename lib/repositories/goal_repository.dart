import 'package:data_life/paging/page_repository.dart';
import 'package:data_life/models/goal.dart';

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

}
