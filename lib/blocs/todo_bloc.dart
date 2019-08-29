import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/todo_repository.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/todo.dart';
import 'package:data_life/models/repeat_types.dart';

import 'package:data_life/utils/time_util.dart';
import 'package:data_life/constants.dart';

abstract class TodoEvent {}

abstract class TodoState {}

class CreateTodayTodo extends TodoEvent {}
class ForceCreateTodo extends TodoEvent {}

class DismissTodo extends TodoEvent {
  final Todo todo;
  DismissTodo({this.todo}) : assert(todo != null);
}

class MarkTodoAsDone extends TodoEvent {
  final Todo todo;
  MarkTodoAsDone({this.todo}) : assert(todo != null);
}

class GoalDeletedTodoEvent extends TodoEvent {
  final Goal goal;
  GoalDeletedTodoEvent({this.goal});
}

class GoalUpdatedTodoEvent extends TodoEvent {
  final Goal newGoal;
  final Goal oldGoal;
  GoalUpdatedTodoEvent({this.newGoal, this.oldGoal});
}

class GoalActionUpdatedTodoEvent extends TodoEvent {
  final Goal goal;
  final GoalAction newGoalAction;
  final GoalAction oldGoalAction;
  GoalActionUpdatedTodoEvent(
      {this.goal, this.newGoalAction, this.oldGoalAction});
}

class GoalAddedTodoEvent extends TodoEvent {
  final Goal goal;
  GoalAddedTodoEvent({this.goal});
}

class TodoUninitialized extends TodoState {}

class TodayTodoCreated extends TodoState {
  final int count;
  TodayTodoCreated({this.count});
}

class TodoDismissed extends TodoState {
  final Todo todo;
  TodoDismissed({this.todo});
}

class TodoDone extends TodoState {
  final Todo todo;
  TodoDone({this.todo});
}

class TodoUpdated extends TodoState {
  final List<Todo> addedList;
  final List<Todo> deletedList;
  final List<Todo> updatedList;
  TodoUpdated({this.addedList, this.updatedList, this.deletedList});
}

class TodoAdded extends TodoState {
  final List<Todo> todoList;
  TodoAdded({this.todoList});
}

class TodoDeleted extends TodoState {
  final List<Todo> todoList;
  TodoDeleted({this.todoList});
}

class TodoFailed extends TodoState {}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;
  final GoalRepository goalRepository;
  var waitingTodoCount = 0;

  TodoBloc({this.todoRepository, this.goalRepository})
      : assert(todoRepository != null),
        assert(goalRepository != null);

  @override
  TodoState get initialState => TodoUninitialized();

  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    DateTime now = DateTime.now();
    DateTime todayDate = TimeUtil.todayStart(now);
    DateTime tomorrowDate = TimeUtil.tomorrowStart(now);
    if (event is CreateTodayTodo) {
      try {
        await todoRepository.deleteOlderThanTime(todayDate);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int lastTimeCreateTodayTodo =
            prefs.getInt(SP_KEY_lastTimeCreateTodayTodo) ?? 0;
        if (_isToday(lastTimeCreateTodayTodo, todayDate.millisecondsSinceEpoch,
            tomorrowDate.millisecondsSinceEpoch)) {
          await _updateWaitingTodoCount();
          yield TodayTodoCreated(count: 0);
          return;
        }
        var todoList = await _forceCreateTodo(now);
        await _updateWaitingTodoCount();
        await prefs.setInt(
            SP_KEY_lastTimeCreateTodayTodo, now.millisecondsSinceEpoch);
        yield TodayTodoCreated(count: todoList.length);
      } catch (e) {
        print("Create today's todo failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is ForceCreateTodo) {
      try {
        var todoList = await _forceCreateTodo(now);
        yield TodayTodoCreated(count: todoList.length);
      } catch (e) {
        print("Force create today's todo failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is DismissTodo) {
      try {
        Todo todo = event.todo;
        todo.status = TodoStatus.dismiss;
        todo.updateTime = now.millisecondsSinceEpoch;
        await todoRepository.save(todo);
        await _updateWaitingTodoCount();
        yield TodoDismissed(todo: todo);
      } catch (e) {
        print("Dismiss todo failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is MarkTodoAsDone) {
      try {
        Todo todo = event.todo;
        todo.status = TodoStatus.done;
        todo.doneTime = now.millisecondsSinceEpoch;
        todo.updateTime = now.millisecondsSinceEpoch;
        await todoRepository.save(todo);
        await _updateWaitingTodoCount();
        yield TodoDone(todo: todo);
      } catch (e) {
        print("Done todo failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is GoalAddedTodoEvent) {
      try {
        var todoList = await _goalAddedProcess(event.goal, now);
        await _updateWaitingTodoCount();
        yield TodoUpdated(addedList: todoList);
      } catch (e) {
        print("Todo bloc - process AddGoal event failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is GoalDeletedTodoEvent) {
      try {
        var todoList = await _goalDeletedProcess(event.goal);
        await _updateWaitingTodoCount();
        yield TodoDeleted(todoList: todoList);
      } catch (e) {
        print("Todo bloc - process DelGoal event failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is GoalUpdatedTodoEvent) {
      try {
        var deletedList =
            await _goalDeletedProcess(event.oldGoal ?? event.newGoal);
        var addedList = await _goalAddedProcess(event.newGoal, now);
        for (var todo in deletedList) {
          if (todo.status == TodoStatus.dismiss ||
              todo.status == TodoStatus.done) {
            for (var addedTodo in addedList) {
              if (addedTodo.goalUuid == todo.goalUuid &&
                  addedTodo.actionId == todo.actionId) {
                addedTodo.status = todo.status;
                await todoRepository.save(addedTodo);
                break;
              }
            }
          }
        }
        await _updateWaitingTodoCount();
        yield TodoUpdated(
            addedList: addedList, deletedList: deletedList, updatedList: []);
      } catch (e) {
        var error =
            "Todo bloc - process UpdateGoal event failed: ${e.toString()}";
        print(error);
        yield TodoFailed();
      }
    }
    if (event is GoalActionUpdatedTodoEvent) {
      try {
        var goal = event.goal;
        var newGoalAction = event.newGoalAction;
        if (!_isCreateTodoForGoal(goal, now)) {
          return;
        }
        var dbTodo = await todoRepository.getViaKey(goal.uuid, newGoalAction.actionId, true);
        if (isTodoGoalActionToday(event.newGoalAction, now)) {
          var todo = _newTodo(newGoalAction, now);
          if (dbTodo != null) {
            dbTodo.startTime = todo.startTime;
            await todoRepository.save(dbTodo);
          } else {
            await todoRepository.add(todo);
          }
        } else {
          if (dbTodo != null) {
            await todoRepository.delete(dbTodo);
          }
        }
      } catch (e) {
        var error = 'Todo bloc - process GoalActionUpdatedTodoEvent event failed: ${e.toString()}';
        print(error);
      }
    }
  }

  Future<List<Todo>> _forceCreateTodo(DateTime now) async {
    List<Todo> todoList = <Todo>[];
    List<Goal> goals =
        await goalRepository.getViaStatus(GoalStatus.ongoing, false);
    for (Goal goal in goals) {
      if (!_isCreateTodoForGoal(goal, now)) {
        continue;
      }
      for (GoalAction goalAction in goal.goalActions) {
        if (isTodoGoalActionToday(goalAction, now)) {
          var dbTodo = await todoRepository.getViaKey(goal.uuid, goalAction.actionId, true);
          var todo = _newTodo(goalAction, now);
          if (dbTodo != null) {
            if (dbTodo.status == TodoStatus.dismiss ||
                dbTodo.status == TodoStatus.done) {
              todo.status = dbTodo.status;
              await todoRepository.save(todo);
            }
          } else {
            await todoRepository.add(todo);
          }
          todoList.add(todo);
        }
      }
    }
    return todoList;
  }

  bool _isCreateTodoForGoal(Goal goal, DateTime now) {
    if (goal.status == GoalStatus.ongoing &&
        goal.stopTime > now.millisecondsSinceEpoch) {
      return true;
    }
    return false;
  }

  Future<List<Todo>> _goalDeletedProcess(Goal goal) async {
    var todoList = await todoRepository.getViaGoalUuid(goal.uuid, true);
    for (var todo in todoList) {
      await todoRepository.delete(todo);
    }
    return todoList;
  }

  Future<List<Todo>> _goalAddedProcess(Goal goal, DateTime now) async {
    var todoList = <Todo>[];
    if (!_isCreateTodoForGoal(goal, now)) {
      return todoList;
    }
    for (var goalAction in goal.goalActions) {
      if (isTodoGoalActionToday(goalAction, now)) {
        Todo todo = _newTodo(goalAction, now);
        todoList.add(todo);
        await todoRepository.add(todo);
      }
    }
    return todoList;
  }

  Future<void> _updateWaitingTodoCount() async {
    waitingTodoCount = await todoRepository.getWaitingTodoCount();
  }

  bool _isToday(int millis, int todayMillis, int tomorrowMillis) {
    if (millis >= todayMillis && millis < tomorrowMillis) {
      return true;
    }
    return false;
  }

  bool isTodoGoalActionToday(GoalAction goalAction, DateTime now) {
    return isTodoGoalAction(goalAction, now);
  }

  bool isTodoGoalAction(GoalAction goalAction, DateTime now) {
    Repeat repeat = goalAction.getRepeat();
    switch (repeat.type) {
      case RepeatType.custom:
        return _isCalculateCustomTodo(repeat, goalAction, now);
      case RepeatType.oneTime:
        return _isCalculateOneTimeTodo(repeat, goalAction, now);
      case RepeatType.daily:
        return _isCalculateDailyTodo(repeat, goalAction, now);
      case RepeatType.mondayToFriday:
        return _isCalculateWeeklyTodo(repeat, goalAction, now);
      case RepeatType.weekly:
        return _isCalculateWeeklyTodo(repeat, goalAction, now);
      case RepeatType.monthlyFirstWeekday:
        return _isCalculateMonthlyFirstWeekTodo(repeat, goalAction, now);
      case RepeatType.monthlySameDay:
        return _isCalculateMonthlyTodo(repeat, goalAction, now);
      case RepeatType.yearly:
        return _isCalculateYearlyTodo(repeat, goalAction, now);
      default:
        return false;
    }
  }

  bool _isCalculateCustomTodo(
      Repeat repeat, GoalAction goalAction, DateTime now) {
    switch (repeat.every) {
      case RepeatEvery.day:
        return _isCalculateDayTodo(repeat, goalAction, now);
      case RepeatEvery.week:
        return _isCalculateWeeklyTodo(repeat, goalAction, now);
      case RepeatEvery.month:
        return _isCalculateMonthlyTodo(repeat, goalAction, now);
      case RepeatEvery.year:
        return _isCalculateYearlyTodo(repeat, goalAction, now);
      default:
        return false;
    }
  }

  bool _isCalculateOneTimeTodo(
      Repeat repeat, GoalAction goalAction, DateTime now) {
    if (repeat.startTime.year == now.year &&
        repeat.startTime.month == now.month &&
        repeat.startTime.day == now.day) {
      return true;
    }
    return false;
  }

  bool _isCalculateDailyTodo(
      Repeat repeat, GoalAction goalAction, DateTime now) {
    return true;
  }

  bool _isCalculateDayTodo(Repeat repeat, GoalAction goalAction, DateTime now) {
    assert(repeat.onList.isNotEmpty);
    Duration diff = now.difference(repeat.startTime);
    int days = diff.inDays;
    bool isStep = days % repeat.everyStep == 0;
    if (isStep) {
      return true;
    }
    return false;
  }

  bool _isCalculateWeeklyTodo(
      Repeat repeat, GoalAction goalAction, DateTime now) {
    assert(repeat.onList.isNotEmpty);
    Duration diff = now.difference(repeat.startTime);
    int n = (now.weekday - repeat.startTime.weekday).abs();
    bool isStep = ((diff.inDays + n) % 7) % repeat.everyStep == 0;
    if (repeat.onList.contains(now.weekday) && isStep) {
      return true;
    }
    return false;
  }

  bool _isCalculateMonthlyTodo(
      Repeat repeat, GoalAction goalAction, DateTime now) {
    assert(repeat.onList.isNotEmpty);
    int monthDiff = (now.year - repeat.startTime.year) * 12 +
        now.month -
        repeat.startTime.month;
    bool isStep = monthDiff % repeat.everyStep == 0;
    if (repeat.onList.contains(now.day) && isStep) {
      return true;
    }
    return false;
  }

  bool _isCalculateMonthlyFirstWeekTodo(
      Repeat repeat, GoalAction goalAction, DateTime now) {
    assert(repeat.onList.isNotEmpty);
    int monthDiff = (now.year - repeat.startTime.year) * 12 +
        now.month -
        repeat.startTime.month;
    bool isStep = monthDiff % repeat.everyStep == 0;
    if (repeat.onList.contains(now.weekday) &&
        isStep &&
        TimeUtil.getWeekdaySeqOfMonth(now) == repeat.weekdaySeqOfMonth) {
      return true;
    }
    return false;
  }

  bool _isCalculateYearlyTodo(
      Repeat repeat, GoalAction goalAction, DateTime now) {
    assert(repeat.onList.isNotEmpty);
    bool isStep = (now.year - repeat.startTime.year) % repeat.everyStep == 0;
    if (repeat.onList.contains(now.month) &&
        repeat.startTime.day == now.day &&
        isStep) {
      return true;
    }
    return false;
  }

  Todo _newTodo(GoalAction goalAction, DateTime now) {
    Todo todo = Todo();
    DateTime d = DateTime.fromMillisecondsSinceEpoch(goalAction.startTime);
    TimeOfDay timeOfDay = TimeOfDay.fromDateTime(d);
    todo.startTime =
        DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute)
            .millisecondsSinceEpoch;
    todo.goalUuid = goalAction.goalUuid;
    todo.actionId = goalAction.actionId;
    todo.createTime = now.millisecondsSinceEpoch;
    if (_isToday(
        goalAction.lastActiveTime,
        TimeUtil.todayStart(now).millisecondsSinceEpoch,
        TimeUtil.tomorrowStart(now).millisecondsSinceEpoch)) {
      todo.status = TodoStatus.done;
      todo.doneTime = goalAction.lastActiveTime;
    } else {
      todo.status = TodoStatus.waiting;
    }
    return todo;
  }
}
