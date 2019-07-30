import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/todo_repository.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/todo.dart';
import 'package:data_life/models/repeat_types.dart';

import 'package:data_life/utils/time_util.dart';

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

class DelTodoFromGoal extends TodoEvent {
  final Goal goal;
  DelTodoFromGoal({this.goal});
}

class UpdateTodoFromGoal extends TodoEvent {
  final Goal goal;
  UpdateTodoFromGoal({this.goal});
}

class AddTodoFromGoal extends TodoEvent {
  final Goal goal;
  AddTodoFromGoal({this.goal});
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
    DateTime todayDate = DateTime(now.year, now.month, now.day);
    DateTime tomorrowDate =
        DateTime(now.year, now.month, now.day).add(Duration(days: 1));
    if (event is CreateTodayTodo) {
      try {
        int deletedOldTodoCount =
            await todoRepository.deleteOlderThanTime(todayDate);
        print('Number of old todo deleted: $deletedOldTodoCount');
        List<Todo> todoList = <Todo>[];
        List<Goal> goals =
            await goalRepository.getGoalViaStatus(GoalStatus.ongoing, false);
        for (Goal goal in goals) {
          for (GoalAction goalAction in goal.goalActions) {
            if (isTodoGoalActionToday(
                goalAction, now, todayDate, tomorrowDate)) {
              var todo = _newTodo(goalAction, now);
              todoList.add(todo);
              todoRepository.save(todo);
            }
          }
        }
        await _updateWaitingTodoCount();
        yield TodayTodoCreated(count: todoList.length);
      } catch (e) {
        print("Create today's todo failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is DismissTodo) {
      try {
        int result = await todoRepository.dismissTodo(event.todo.id);
        if (result == 1) {
          print("Dismiss todo failed: not found todo");
          yield TodoFailed();
        }
        await _updateWaitingTodoCount();
        yield TodoDismissed(todo: event.todo);
      } catch (e) {
        print("Dismiss todo failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is MarkTodoAsDone) {
      try {
        int result = await todoRepository.doneTodo(event.todo.id);
        if (result == 1) {
          print("Done todo failed: not found todo");
          yield TodoFailed();
        }
        await _updateWaitingTodoCount();
        yield TodoDone(todo: event.todo);
      } catch (e) {
        print("Done todo failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is AddTodoFromGoal) {
      try {
        var todoList = await _addTodoFromGoal(event.goal, now, todayDate, tomorrowDate);
        await _updateWaitingTodoCount();
        yield TodoAdded(todoList: todoList);
      } catch (e) {
        print("Todo bloc - process AddGoal event failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
    if (event is DelTodoFromGoal) {
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
    if (event is UpdateTodoFromGoal) {
      try {
        var todoList = await todoRepository.getViaGoalId(event.goal.id, true);
        for (var todo in todoList) {
          await todoRepository.delete(todo.id);
        }
        if (todoList.isNotEmpty) {
          await _updateWaitingTodoCount();
          yield TodoDeleted(todoList: todoList);
        }
        todoList = await _addTodoFromGoal(event.goal, now, todayDate, tomorrowDate);
        if (todoList.isNotEmpty) {
          await _updateWaitingTodoCount();
          yield TodoAdded(todoList: todoList);
        }
      } catch (e) {
        print("Todo bloc - process UpdateGoal event failed: ${e.toString()}");
        yield TodoFailed();
      }
    }
  }

  Future<List<Todo>> _addTodoFromGoal(Goal goal, DateTime now, DateTime todayDate,
      DateTime tomorrowDate) async {
    var todoList = <Todo>[];
    for (var goalAction in goal.goalActions) {
      if (isTodoGoalActionToday(goalAction, now, todayDate, tomorrowDate)) {
        Todo todo = _newTodo(goalAction, now);
        todoList.add(todo);
        await todoRepository.save(todo);
      }
    }
    return todoList;
  }

  Future<void> _updateWaitingTodoCount() async {
    waitingTodoCount = await todoRepository.getWaitingTodoCount();
  }

  bool isTodoGoalActionToday(GoalAction goalAction, DateTime now,
      DateTime todayDate, DateTime tomorrowDate) {
    if (goalAction.lastActiveTime >= todayDate.millisecondsSinceEpoch &&
        goalAction.lastActiveTime < tomorrowDate.millisecondsSinceEpoch) {
      return false;
    }
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
    todo.status = TodoStatus.waiting;
    return todo;
  }
}
