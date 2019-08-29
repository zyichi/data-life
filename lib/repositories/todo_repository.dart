import 'package:data_life/models/todo.dart';
import 'package:data_life/repositories/todo_provider.dart';

import 'package:data_life/paging/page_repository.dart';


class TodoRepository extends PageRepository<Todo> {
  final TodoProvider _todoProvider;

  TodoRepository(this._todoProvider);

  Future<List<Todo>> get({int startIndex, int count}) async {
    return _todoProvider.get(startIndex: startIndex, count: count);
  }

  Future<List<Todo>> getViaGoalUuid(String goalUuid, bool rowOnly) async {
    return _todoProvider.getViaGoalUuid(goalUuid, rowOnly);
  }

  Future<Todo> getViaKey(String goalUuid, int actionId, bool rowOnly) async {
    return _todoProvider.getViaKey(goalUuid, actionId, rowOnly);
  }

  Future<int> count() async {
    return _todoProvider.count();
  }

  Future<int> getWaitingTodoCount() async {
    return _todoProvider.getWaitingTodoCount();
  }

  Future<int> add(Todo todo) async {
    return _todoProvider.insert(todo);
  }

  Future<int> save(Todo todo) async {
    return _todoProvider.save(todo);
  }

  Future<int> delete(Todo todo) async {
    return _todoProvider.delete(todo);
  }
  Future<int> deleteViaKey(int goalId, int goalActionId) async {
    return _todoProvider.deleteViaKey(goalId, goalActionId);
  }
  Future<int> deleteAll() async {
    return _todoProvider.deleteAll();
  }

  Future<int> deleteOlderThanTime(DateTime time) async {
    return _todoProvider.deleteOlderThanTime(time);
  }

}
