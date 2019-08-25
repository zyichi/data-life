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
        List<Todo> todoList = <Todo>[];
        List<Goal> goals =
            await goalRepository.getViaStatus(GoalStatus.ongoing, false);
        for (Goal goal in goals) {
          if (!_isCreateTodoForGoal(goal, now)) {
            continue;
          }
          for (GoalAction goalAction in goal.goalActions) {
            if (isTodoGoalActionToday(goalAction, now)) {
              var todo = _newTodo(goalAction, now);
              todoList.add(todo);
              todoRepository.save(todo);
            }
          }
        }
        await _updateWaitingTodoCount();
        await prefs.setInt(
            SP_KEY_lastTimeCreateTodayTodo, todayDate.millisecondsSinceEpoch);
        yield TodayTodoCreated(count: todoList.length);
      } catch (e) {
        print("Create today's todo failed: ${e.toString()}");
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
        var goal = event.goal;
        if (!_isCreateTodoForGoal(goal, now)) {
          return;
        }
        var todoList = <Todo>[];
        for (var goalAction in goal.goalActions) {
          if (isTodoGoalActionToday(goalAction, now)) {
            Todo todo = _newTodo(goalAction, now);
            todoList.add(todo);
            await todoRepository.save(todo);
          }
        }
        await _updateWaitingTodoCount();
        yield TodoUpdated(addedList: todoList);
      } catch (e) {
        print("Todo bloc - process AddGoal event failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is GoalDeletedTodoEvent) {
      try {
        var todoList = await todoRepository.getViaGoalId(event.goal.id, true);
        for (var todo in todoList) {
          await todoRepository.delete(todo.id);
        }
        await _updateWaitingTodoCount();
        yield TodoDeleted(todoList: todoList);
      } catch (e) {
        print("Todo bloc - process DelGoal event failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is GoalUpdatedTodoEvent) {
      try {
        Goal newGoal = event.newGoal;
        Goal oldGoal = event.oldGoal;
        var deletedList = <Todo>[];
        var addedList = <Todo>[];
        var updatedList = <Todo>[];
        if (oldGoal != null) {
          for (var oldGoalAction in oldGoal.goalActions) {
            var foundedInNew = newGoal.goalActions.firstWhere((newGoalAction) {
              if (oldGoalAction.actionId != newGoalAction.actionId &&
                  oldGoalAction.action?.name != newGoalAction.action?.name) return true;
              return false;
            }, orElse: () => null);
            Todo dbTodo = await todoRepository.getViaUniqueIndexId(
                oldGoal.id, oldGoalAction.id, true);
            if (foundedInNew == null) {
              if (dbTodo != null) {
                deletedList.add(dbTodo);
                await todoRepository.delete(dbTodo.id);
              }
            } else {
              if (dbTodo != null) {
                // Because we update goal by first delete then insert.
                // We must update old goalId to new goalId.
                dbTodo.goalId = newGoal.id;
                await todoRepository.delete(dbTodo.id);
                await todoRepository.save(dbTodo);
              }
            }
          }
        }
        await _updateTodoFromGoal(newGoal, now, todayDate, tomorrowDate,
            deletedList, addedList, updatedList);
        await _updateWaitingTodoCount();
        yield TodoUpdated(
            addedList: addedList,
            updatedList: updatedList,
            deletedList: deletedList);
      } catch (e) {
        print("Todo bloc - process UpdateGoal event failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
  }

  bool _isCreateTodoForGoal(Goal goal, DateTime now) {
    if (goal.status == GoalStatus.ongoing ||
        goal.stopTime > now.millisecondsSinceEpoch) {
      return true;
    }
    return false;
  }

  Future<void> _updateTodoFromGoal(
      Goal goal,
      DateTime now,
      DateTime todayDate,
      DateTime tomorrowDate,
      List<Todo> deletedList,
      List<Todo> addedList,
      List<Todo> updatedList) async {
    for (var goalAction in goal.goalActions) {
      print(
          '_updateTodoFromGoal: goal: ${goal.name}, goalAction: ${goalAction.action.name}');
      Todo dbTodo = await todoRepository.getViaUniqueIndexId(
          goal.id, goalAction.id, true);
      print('dbTodo is null ${dbTodo == null}');
      if (goal.status == GoalStatus.finished ||
          goal.status == GoalStatus.expired) {
        if (dbTodo != null) {
          deletedList.add(dbTodo);
          await todoRepository.delete(dbTodo.id);
        }
      } else if (goal.status == GoalStatus.paused) {
        if (dbTodo != null) {
          updatedList.add(dbTodo);
          dbTodo.status = TodoStatus.dismiss;
          await todoRepository.dismissTodo(dbTodo.id);
        }
      } else if (goal.status == GoalStatus.ongoing) {
        if (isTodoGoalActionToday(goalAction, now)) {
          if (dbTodo != null) {
            if (dbTodo.status == TodoStatus.waiting) {
              if (_isToday(
                  goalAction.lastActiveTime,
                  TimeUtil.todayStart(now).millisecondsSinceEpoch,
                  TimeUtil.tomorrowStart(now).millisecondsSinceEpoch)) {
                dbTodo.status = TodoStatus.done;
                dbTodo.doneTime = goalAction.lastActiveTime;
                updatedList.add(dbTodo);
              }
            }
            await todoRepository.save(dbTodo);
          } else {
            Todo todo = _newTodo(goalAction, now);
            addedList.add(todo);
            await todoRepository.save(todo);
          }
        } else {
          if (dbTodo != null) {
            deletedList.add(dbTodo);
            await todoRepository.delete(dbTodo.id);
          }
        }
      }
    }
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
    todo.goalId = goalAction.goalId;
    todo.goalActionId = goalAction.id;
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
