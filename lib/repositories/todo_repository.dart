import 'package:data_life/models/todo.dart';
import 'package:data_life/repositories/todo_provider.dart';

import 'package:data_life/paging/page_repository.dart';


class TodoRepository extends PageRepository<Todo> {
  final TodoProvider _todoProvider;

  TodoRepository(this._todoProvider);

  Future<List<Todo>> get({int startIndex, int count}) async {
    return _todoProvider.get(startIndex: startIndex, count: count);
  }

  Future<Todo> getViaGoalActionId(int goalActionId) async {
    return _todoProvider.getViaGoalActionId(goalActionId);
  }

  Future<List<Todo>> getViaGoalId(int goalId, bool rowOnly) async {
    return _todoProvider.getViaGoalId(goalId, rowOnly);
  }

  Future<Todo> getViaUniqueIndexId(int goalId, int goalActionId, bool rowOnly) async {
    return _todoProvider.getViaUniqueIndexId(goalId, goalActionId, rowOnly);
  }

  Future<int> count() async {
    return _todoProvider.count();
  }

  Future<int> getWaitingTodoCount() async {
    return _todoProvider.getWaitingTodoCount();
  }

  Future<int> save(Todo todo) async {
    return _todoProvider.save(todo);
  }

  Future<int> delete(int id) async {
    return _todoProvider.delete(id);
  }
  Future<int> deleteViaUniqueId(int goalId, int goalActionId) async {
    return _todoProvider.deleteViaUniqueId(goalId, goalActionId);
  }
  Future<int> deleteAll() async {
    return _todoProvider.deleteAll();
  }

  Future<int> deleteOlderThanTime(DateTime time) async {
    return _todoProvider.deleteOlderThanTime(time);
  }

  Future<int> dismissTodo(int id) async {
    return _todoProvider.dismissTodo(id);
  }

  Future<int> doneTodo(int id) async {
    return _todoProvider.doneTodo(id);
  }
}
