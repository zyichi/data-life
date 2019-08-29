import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/moment.dart';

import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/action_repository.dart';
import 'package:data_life/repositories/moment_repository.dart';

import 'package:data_life/utils/time_util.dart';

import 'package:data_life/constants.dart';

abstract class GoalEvent {}

abstract class GoalState {}

class AddGoal extends GoalEvent {
  final Goal goal;
  AddGoal({@required this.goal}) : assert(goal != null);
}

class AddGoalAction extends GoalEvent {
  final GoalAction goalAction;
  AddGoalAction({@required this.goalAction}) : assert(goalAction != null);
}

class UpdateGoal extends GoalEvent {
  final Goal oldGoal;
  final Goal newGoal;

  UpdateGoal({@required this.oldGoal, @required this.newGoal})
      : assert(oldGoal != null),
        assert(newGoal != null);
}

class MomentAddedGoalEvent extends GoalEvent {
  final Moment moment;
  MomentAddedGoalEvent({this.moment});
}

class MomentDeletedGoalEvent extends GoalEvent {
  final Moment moment;
  MomentDeletedGoalEvent({this.moment});
}

class MomentUpdatedGoalEvent extends GoalEvent {
  final Moment newMoment;
  final Moment oldMoment;
  MomentUpdatedGoalEvent({this.newMoment, this.oldMoment});
}

class UpdateGoalStatus extends GoalEvent {}

class UpdateGoalAction extends GoalEvent {
  final Goal goal;
  final GoalAction oldGoalAction;
  final GoalAction newGoalAction;

  UpdateGoalAction(
      {@required this.goal,
      @required this.oldGoalAction,
      @required this.newGoalAction})
      : assert(goal != null),
        assert(oldGoalAction != null),
        assert(newGoalAction != null);
}

class PauseGoal extends GoalEvent {
  final Goal goal;
  PauseGoal({@required this.goal}) : assert(goal != null);
}

class ResumeGoal extends GoalEvent {
  final Goal goal;
  ResumeGoal({@required this.goal}) : assert(goal != null);
}

class FinishGoal extends GoalEvent {
  final Goal goal;
  FinishGoal({@required this.goal}) : assert(goal != null);
}

class DeleteGoal extends GoalEvent {
  final Goal goal;
  DeleteGoal({@required this.goal}) : assert(goal != null);
}

class DeleteGoalAction extends GoalEvent {
  final GoalAction goalAction;
  DeleteGoalAction({@required this.goalAction}) : assert(goalAction != null);
}

class GoalNameUniqueCheck extends GoalEvent {
  final String name;

  GoalNameUniqueCheck({this.name}) : assert(name != null);
}

class GoalUninitialized extends GoalState {}

class GoalStatusUpdated extends GoalState {}

class GoalAdded extends GoalState {
  final Goal goal;
  GoalAdded({this.goal});
}

class GoalUpdated extends GoalState {
  final Goal newGoal;
  final Goal oldGoal;
  GoalUpdated({this.newGoal, this.oldGoal});
}

class GoalDeleted extends GoalState {
  final Goal goal;
  GoalDeleted({@required this.goal}) : assert(goal != null);
}

class GoalPaused extends GoalState {
  final Goal goal;
  GoalPaused({this.goal});
}

class GoalResumed extends GoalState {
  final Goal goal;
  GoalResumed({this.goal});
}

class GoalFinished extends GoalState {
  final Goal goal;
  GoalFinished({this.goal});
}

class GoalActionAdded extends GoalState {}

class GoalActionUpdated extends GoalState {
  final Goal goal;
  final GoalAction oldGoalAction;
  final GoalAction newGoalAction;

  GoalActionUpdated(
      {@required this.goal,
      @required this.oldGoalAction,
      @required this.newGoalAction})
      : assert(goal != null),
        assert(oldGoalAction != null),
        assert(newGoalAction != null);
}

class GoalActionDeleted extends GoalState {
  final GoalAction goalAction;
  GoalActionDeleted({@required this.goalAction}) : assert(goalAction != null);
}

class GoalNameUniqueCheckResult extends GoalState {
  final bool isUnique;
  final String text;

  GoalNameUniqueCheckResult({this.isUnique, this.text})
      : assert(isUnique != null),
        assert(text != null);
}

class GoalFailed extends GoalState {
  final String error;

  GoalFailed({this.error}) : assert(error != null);
}

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository goalRepository;
  final ActionRepository actionRepository;
  final MomentRepository momentRepository;

  GoalBloc(
      {@required this.goalRepository,
      @required this.actionRepository,
      @required this.momentRepository})
      : assert(goalRepository != null),
        assert(actionRepository != null),
        assert(momentRepository != null);

  @override
  GoalState get initialState => GoalUninitialized();

  @override
  Stream<GoalState> mapEventToState(GoalEvent event) async* {
    final now = DateTime.now();
    final nowInMillis = DateTime.now().millisecondsSinceEpoch;
    DateTime todayDate = TimeUtil.todayStart(now);
    DateTime tomorrowDate = TimeUtil.tomorrowStart(now);
    if (event is UpdateGoalStatus) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int lastTimeUpdateGoalStatus =
          prefs.getInt(SP_KEY_lastTimeUpdateGoalStatus) ?? 0;
      if (lastTimeUpdateGoalStatus >= todayDate.millisecondsSinceEpoch &&
          lastTimeUpdateGoalStatus < tomorrowDate.millisecondsSinceEpoch) {
        return;
      }
      var goals = await goalRepository.getAll();
      for (var goal in goals) {
        switch (goal.status) {
          case GoalStatus.none:
          case GoalStatus.ongoing:
          case GoalStatus.paused:
            if (goal.stopTime < now.millisecondsSinceEpoch) {
              goal.status = GoalStatus.expired;
              goal.updateTime = nowInMillis;
              await goalRepository.save(goal);
            }
            break;
          case GoalStatus.expired:
          case GoalStatus.finished:
            break;
        }
      }
      await prefs.setInt(
          SP_KEY_lastTimeUpdateGoalStatus, todayDate.millisecondsSinceEpoch);
      yield GoalStatusUpdated();
    }
    if (event is AddGoal) {
      try {
        final goal = event.goal;
        await _addGoal(goal, nowInMillis);
        yield GoalAdded(goal: goal);
      } catch (e) {
        var error = 'Add goal ${event.goal.name} failed: ${e.toString()}';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is UpdateGoal) {
      final oldGoal = event.oldGoal;
      final newGoal = event.newGoal;
      try {
        await _deleteGoal(oldGoal, nowInMillis);
        await _addGoal(newGoal, nowInMillis);
        yield GoalUpdated(newGoal: newGoal, oldGoal: oldGoal);
      } catch (e) {
        var error = 'Update goal ${oldGoal.name} failed: ${e.toString()}';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is DeleteGoal) {
      final goal = event.goal;
      try {
        await _deleteGoal(goal, nowInMillis);
        yield GoalDeleted(goal: goal);
      } catch (e) {
        var error = 'Delete goal ${goal.name} failed: ${e.toString()}';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is PauseGoal) {
      final goal = event.goal;
      try {
        goal.status = GoalStatus.paused;
        goal.updateTime = nowInMillis;
        await goalRepository.save(goal);
        yield GoalPaused(goal: goal);
      } catch (e) {
        var error = 'Pause goal ${goal.name} failed: ${e.toString()}';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is ResumeGoal) {
      final goal = event.goal;
      try {
        goal.status = GoalStatus.ongoing;
        goal.updateTime = nowInMillis;
        await goalRepository.save(goal);
        yield GoalResumed(goal: goal);
      } catch (e) {
        var error = 'Resume goal ${goal.name} failed: ${e.toString()}';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is FinishGoal) {
      final goal = event.goal;
      try {
        goal.status = GoalStatus.finished;
        goal.updateTime = nowInMillis;
        await goalRepository.save(goal);
        yield GoalFinished(goal: goal);
      } catch (e) {
        var error = 'Finish goal ${goal.name} failed: ${e.toString()}';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is DeleteGoalAction) {
      yield GoalActionDeleted(goalAction: event.goalAction);
    }
    if (event is AddGoalAction) {
      yield GoalActionAdded();
    }
    if (event is UpdateGoalAction) {
      try {
        await goalRepository.saveGoalAction(event.newGoalAction);
        yield GoalActionUpdated(
            goal: event.goal,
            newGoalAction: event.newGoalAction,
            oldGoalAction: event.oldGoalAction);
      } catch (e) {
        var error = 'Process UpdateGoalAction failed: $e';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is MomentAddedGoalEvent) {
      try {
        var moment = event.moment;
        List<Goal> goals =
            await goalRepository.getViaActionId(moment.action.id, false);
        for (var goal in goals) {
          await _updateGoalWhenAddMoment(goal, moment, nowInMillis);
          yield GoalUpdated(oldGoal: null, newGoal: goal);
        }
      } catch (e) {
        var error = 'Process MomentAddedGoalEvent failed: $e';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is MomentUpdatedGoalEvent) {
      try {
        var oldMoment = event.oldMoment;
        var newMoment = event.newMoment;
        List<Goal> goals =
            await goalRepository.getViaActionId(oldMoment.action.id, false);
        for (var goal in goals) {
          await _updateGoalWhenDeleteMoment(goal, oldMoment, nowInMillis);
          await _updateGoalWhenAddMoment(goal, newMoment, nowInMillis);
          yield GoalUpdated(oldGoal: null, newGoal: goal);
        }
      } catch (e) {
        var error = 'Process MomentUpdatedGoalEvent failed: $e';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is MomentDeletedGoalEvent) {
      try {
        var moment = event.moment;
        List<Goal> goals =
            await goalRepository.getViaActionId(moment.action.id, false);
        for (var goal in goals) {
          await _updateGoalWhenDeleteMoment(goal, moment, nowInMillis);
          yield GoalUpdated(oldGoal: null, newGoal: goal);
        }
      } catch (e) {
        var error = 'Process MomentDeletedGoalEvent failed: $e';
        print(error);
        yield GoalFailed(error: error);
      }
    }
    if (event is GoalNameUniqueCheck) {
      try {
        Goal goal = await goalRepository.getViaName(event.name);
        yield GoalNameUniqueCheckResult(
            isUnique: goal == null, text: event.name);
      } catch (e) {
        var error = 'Check if goal name unique failed: ${e.toString()}';
        print(error);
        yield GoalFailed(error: error);
      }
    }
  }

  Future<void> _deleteGoal(Goal goal, int nowInMillis) async {
    await goalRepository.delete(goal);
    for (var goalAction in goal.goalActions) {
      await goalRepository.deleteGoalAction(goalAction);
    }
  }

  Future<void> _addGoal(Goal goal, int nowInMillis) async {
    for (var goalAction in goal.goalActions) {
      await _updateActionInfo(goalAction, nowInMillis);
      goalAction.lastActiveTime =
          await momentRepository.getActionLastActiveTimeBetweenTime(
              goalAction.actionId, goal.startTime, goal.stopTime);
      goalAction.totalTimeTaken =
          await momentRepository.getActionTotalTimeTakenBetweenTime(
              goalAction.actionId, goal.startTime, goal.stopTime);
    }
    if (goal.createTime != null) {
      goal.updateTime = nowInMillis;
    } else {
      goal.createTime = nowInMillis;
    }
    goal.updateFieldFromGoalAction();
    for (var goalAction in goal.goalActions) {
      if (goalAction.createTime != null) {
        goalAction.updateTime = nowInMillis;
      } else {
        goalAction.createTime = nowInMillis;
      }
      goalAction.goalUuid = goal.uuid;
      await goalRepository.addGoalAction(goalAction);
    }
    await goalRepository.add(goal);
  }

  Future<void> _saveGoal(Goal goal, int now) async {
    goal.updateFieldFromGoalAction();
    goal.updateTime = now;
    await goalRepository.save(goal);
  }

  Future<void> _updateGoalWhenAddMoment(
      Goal goal, Moment moment, int nowInMillis) async {
    if (goal.status != GoalStatus.ongoing) {
      return;
    }
    if (moment.beginTime < goal.startTime ||
        moment.beginTime >= goal.stopTime) {
      return;
    }
    for (var goalAction in goal.goalActions) {
      if (goalAction.action.id != moment.action.id) continue;
      goalAction.lastActiveTime =
          max(goalAction.lastActiveTime, moment.beginTime);
      goalAction.totalTimeTaken += moment.duration;
      goalAction.updateTime = nowInMillis;
      await goalRepository.saveGoalAction(goalAction);
    }
    await _saveGoal(goal, nowInMillis);
  }

  Future<void> _updateGoalWhenDeleteMoment(
      Goal goal, Moment moment, int now) async {
    if (goal.status != GoalStatus.ongoing) {
      return;
    }
    if (moment.beginTime < goal.startTime ||
        moment.beginTime >= goal.stopTime) {
      return;
    }
    for (var goalAction in goal.goalActions) {
      if (goalAction.action.id != moment.action.id) continue;
      if (moment.beginTime >= goalAction.lastActiveTime) {
        await momentRepository.getActionLastActiveTimeBetweenTime(
            goalAction.actionId, goal.startTime, goal.stopTime);
      }
      goalAction.totalTimeTaken -= moment.duration;
      await goalRepository.saveGoalAction(goalAction);
    }
    _saveGoal(goal, now);
  }

  Future<void> _updateActionInfo(GoalAction goalAction, int now) async {
    var dbAction = await actionRepository.getViaName(goalAction.action.name);
    if (dbAction != null) {
      dbAction.updateTime = now;
      goalAction.action = dbAction;
    } else {
      goalAction.action.createTime = now;
      await actionRepository.save(goalAction.action);
      goalAction.actionId = goalAction.action.id;
    }
  }

  Future<bool> goalNameUniqueCheck(String name) async {
    Goal goal = await goalRepository.getViaName(name);
    return goal == null;
  }

  Future<List<MyAction>> getActionSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return actionRepository.get(startIndex: 0, count: 8);
    } else {
      return actionRepository.search(pattern);
    }
  }
}
