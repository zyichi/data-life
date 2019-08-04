import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/moment.dart';
import 'package:data_life/models/goal_moment.dart';

import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/action_repository.dart';
import 'package:data_life/repositories/moment_repository.dart';

import 'package:data_life/utils/time_util.dart';

import 'package:data_life/constants.dart';

abstract class GoalEditEvent {}

abstract class GoalEditState {}

class AddGoal extends GoalEditEvent {
  final Goal goal;
  AddGoal({@required this.goal}) : assert(goal != null);
}

class AddGoalAction extends GoalEditEvent {
  final GoalAction goalAction;
  AddGoalAction({@required this.goalAction}) : assert(goalAction != null);
}

class UpdateGoal extends GoalEditEvent {
  final Goal oldGoal;
  final Goal newGoal;

  UpdateGoal({@required this.oldGoal, @required this.newGoal})
      : assert(oldGoal != null),
        assert(newGoal != null);
}

class MomentAddedGoalEvent extends GoalEditEvent {
  final Moment moment;
  MomentAddedGoalEvent({this.moment});
}

class MomentDeletedGoalEvent extends GoalEditEvent {
  final Moment moment;
  MomentDeletedGoalEvent({this.moment});
}

class MomentUpdatedGoalEvent extends GoalEditEvent {
  final Moment newMoment;
  final Moment oldMoment;
  MomentUpdatedGoalEvent({this.newMoment, this.oldMoment});
}

class UpdateGoalStatus extends GoalEditEvent {}

class UpdateGoalAction extends GoalEditEvent {
  final GoalAction oldGoalAction;
  final GoalAction newGoalAction;

  UpdateGoalAction({@required this.oldGoalAction, @required this.newGoalAction})
      : assert(oldGoalAction != null),
        assert(newGoalAction != null);
}

class PauseGoal extends GoalEditEvent {
  final Goal goal;
  PauseGoal({@required this.goal}) : assert(goal != null);
}

class DeleteGoal extends GoalEditEvent {
  final Goal goal;
  DeleteGoal({@required this.goal}) : assert(goal != null);
}

class DeleteGoalAction extends GoalEditEvent {
  final GoalAction goalAction;
  DeleteGoalAction({@required this.goalAction}) : assert(goalAction != null);
}

class GoalNameUniqueCheck extends GoalEditEvent {
  final String name;

  GoalNameUniqueCheck({this.name}) : assert(name != null);
}

class GoalUninitialized extends GoalEditState {}

class GoalStatusUpdated extends GoalEditState {}

class GoalAdded extends GoalEditState {
  final Goal goal;
  GoalAdded({this.goal});
}

class GoalUpdated extends GoalEditState {
  final Goal newGoal;
  final Goal oldGoal;
  GoalUpdated({this.newGoal, this.oldGoal});
}

class GoalDeleted extends GoalEditState {
  final Goal goal;
  GoalDeleted({@required this.goal}) : assert(goal != null);
}

class GoalActionAdded extends GoalEditState {}

class GoalActionUpdated extends GoalEditState {}

class GoalActionDeleted extends GoalEditState {
  final GoalAction goalAction;
  GoalActionDeleted({@required this.goalAction}) : assert(goalAction != null);
}

class GoalNameUniqueCheckResult extends GoalEditState {
  final bool isUnique;
  final String text;

  GoalNameUniqueCheckResult({this.isUnique, this.text})
      : assert(isUnique != null),
        assert(text != null);
}

class GoalEditFailed extends GoalEditState {
  final String error;

  GoalEditFailed({this.error}) : assert(error != null);
}

class GoalEditBloc extends Bloc<GoalEditEvent, GoalEditState> {
  final GoalRepository goalRepository;
  final ActionRepository actionRepository;
  final MomentRepository momentRepository;

  GoalEditBloc(
      {@required this.goalRepository,
      @required this.actionRepository,
      @required this.momentRepository})
      : assert(goalRepository != null),
        assert(actionRepository != null),
        assert(momentRepository != null);

  @override
  GoalEditState get initialState => GoalUninitialized();

  @override
  Stream<GoalEditState> mapEventToState(GoalEditEvent event) async* {
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
        print('Goal status update already run for today');
        return;
      }
      var goals = await goalRepository.getAllGoals();
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
        var moments = await momentRepository.getAfterTime(
            todayDate.millisecondsSinceEpoch, true);
        final goal = event.goal;
        goal.createTime = nowInMillis;
        // Save goal first time to get goal.id
        await goalRepository.save(goal);
        for (var goalAction in goal.goalActions) {
          await _updateActionInfo(goalAction, nowInMillis);
          goalAction.goalId = goal.id;
          goalAction.createTime = nowInMillis;
          // Save goalAction first time to get goalAction.id
          await goalRepository.saveGoalAction(goalAction);
          var results = _getMomentOfGoalAction(moments, goalAction);
          for (var moment in results) {
            goalAction.lastActiveTime = max(goalAction.lastActiveTime, moment.beginTime);
            goalAction.totalTimeTaken += moment.durationInMillis();
            _saveGoalMoment(moment, goal, goalAction, nowInMillis);
          }
          // Save goalAction second time to update lastActiveTime/totalTimeTaken
          await goalRepository.saveGoalAction(goalAction);
          goal.totalTimeTaken += goalAction.totalTimeTaken;
          goal.lastActiveTime = max(goal.lastActiveTime, goalAction.lastActiveTime);
        }
        // Save goal second time to update lastActiveTime/totalTimeTaken
        await goalRepository.save(goal);
        yield GoalAdded(goal: goal);
      } catch (e) {
        yield GoalEditFailed(
            error: 'Add goal ${event.goal.name} failed: ${e.toString()}');
      }
    }
    if (event is UpdateGoal) {
      final oldGoal = event.oldGoal;
      final newGoal = event.newGoal;
      try {
        newGoal.updateTime = nowInMillis;
        await goalRepository.save(newGoal);
        for (var goalAction in newGoal.goalActions) {
          await _updateActionInfo(goalAction, nowInMillis);
          goalAction.goalId = newGoal.id;
          await _updateGoalActionInfo(goalAction, nowInMillis);
          await goalRepository.saveGoalAction(goalAction);
        }
        for (var goalAction in oldGoal.goalActions) {
          if (!newGoal.goalActions.contains(goalAction)) {
            // Goal action removed from old goal.
            await goalRepository.deleteGoalAction(goalAction);
            await goalRepository.saveDeletedGoalAction(goalAction);
          }
        }
        yield GoalUpdated(newGoal: newGoal, oldGoal: oldGoal);
      } catch (e) {
        yield GoalEditFailed(
            error: 'Update goal ${oldGoal.name} failed: ${e.toString()}');
      }
    }
    if (event is DeleteGoal) {
      final goal = event.goal;
      try {
        await goalRepository.delete(goal);
        await goalRepository.saveDeleted(goal);
        await goalRepository.deleteGoalMomentVidGoalId(goal.id);
        for (var goalAction in goal.goalActions) {
          await goalRepository.deleteGoalAction(goalAction);
          await goalRepository.saveDeletedGoalAction(goalAction);
        }
        yield GoalDeleted(goal: goal);
      } catch (e) {
        yield GoalEditFailed(
            error: 'Update goal ${goal.name} failed: ${e.toString()}');
      }
    }
    if (event is DeleteGoalAction) {
      yield GoalActionDeleted(goalAction: event.goalAction);
    }
    if (event is AddGoalAction) {
      yield GoalActionAdded();
    }
    if (event is UpdateGoalAction) {
      yield GoalActionUpdated();
    }
    if (event is MomentAddedGoalEvent) {
      try {
        var updatedGoals =
            await _updateGoalWhenAddMoment(event.moment, nowInMillis);
        for (Goal goal in updatedGoals) {
          await _updateGoalFromGoalMoment(goal, nowInMillis);
          await goalRepository.save(goal);
          yield GoalUpdated(oldGoal: null, newGoal: goal);
        }
      } catch (e) {
        print('Process MomentAddedGoalEvent failed: $e');
        yield GoalEditFailed(error: 'Process MomentAddedGoalEvent failed: $e}');
      }
    }
    if (event is MomentUpdatedGoalEvent) {
      try {
        var updatedGoals = await _updateGoalWhenUpdateMoment(
            event.newMoment, event.oldMoment, nowInMillis);
        for (Goal goal in updatedGoals) {
          await _updateGoalFromGoalMoment(goal, nowInMillis);
          await goalRepository.save(goal);
          yield GoalUpdated(oldGoal: null, newGoal: goal);
        }
      } catch (e) {
        print('Process MomentUpdatedGoalEvent failed: $e');
        yield GoalEditFailed(
            error: 'Process MomentUpdatedGoalEvent failed: $e}');
      }
    }
    if (event is MomentDeletedGoalEvent) {
      try {
        var updatedGoals =
            await _updateGoalWhenDeleteMoment(event.moment, nowInMillis);
        for (Goal goal in updatedGoals) {
          await _updateGoalFromGoalMoment(goal, nowInMillis);
          await goalRepository.save(goal);
          yield GoalUpdated(oldGoal: null, newGoal: goal);
        }
      } catch (e) {
        print('Process MomentDeletedGoalEvent failed: $e');
        yield GoalEditFailed(
            error: 'Process MomentDeletedGoalEvent failed: $e}');
      }
    }
    if (event is GoalNameUniqueCheck) {
      try {
        Goal goal = await goalRepository.getViaName(event.name);
        yield GoalNameUniqueCheckResult(
            isUnique: goal == null, text: event.name);
      } catch (e) {
        yield GoalEditFailed(
            error: 'Check if goal name unique failed: ${e.toString()}');
      }
    }
  }

  List<Moment> _getMomentOfGoalAction(List<Moment> moments, GoalAction goalAction) {
    var results = <Moment>[];
    for (var moment in moments) {
      if (moment.actionId == goalAction.actionId) {
        results.add(moment);
      }
    }
    return moments;
  }

  Future<List<Goal>> _updateGoalWhenAddMoment(Moment moment, int now) async {
    var updatedGoals = Set<Goal>();
    List<Goal> goals =
        await goalRepository.getGoalViaActionId(moment.action.id, false);
    print('_updateGoalWhenAddMoment - Goals num: ${goals.length}');
    for (var goal in goals) {
      if (moment.beginTime < goal.startTime ||
          moment.beginTime > goal.stopTime) {
        print('_updateGoalWhenAddMoment - Moment time not in goal duration');
        continue;
      }
      for (var goalAction in goal.goalActions) {
        if (goalAction.action.id != moment.action.id) continue;
        await _saveGoalMoment(moment, goal, goalAction, now);
        await _updateGoalActionFromGoalMoment(goalAction, now);
        await goalRepository.saveGoalAction(goalAction);
        updatedGoals.add(goal);
      }
    }
    return updatedGoals.toList();
  }

  Future<void> _saveGoalMoment(
      Moment moment, Goal goal, GoalAction goalAction, int now) async {
    var goalMoment = GoalMoment();
    goalMoment.goalId = goal.id;
    goalMoment.goalActionId = goalAction.id;
    goalMoment.momentId = moment.id;
    goalMoment.momentDuration = moment.durationInMillis();
    goalMoment.momentBeginTime = moment.beginTime;
    goalMoment.createTime = now;
    await goalRepository.saveGoalMoment(goalMoment);
  }

  Future<void> _updateGoalActionFromGoalMoment(
      GoalAction goalAction, int now) async {
    goalAction.lastActiveTime = await goalRepository
        .getGoalActionLastActiveTime(goalAction.goalId, goalAction.id);
    goalAction.totalTimeTaken = await goalRepository
        .getGoalActionTotalTimeTaken(goalAction.goalId, goalAction.id);
    goalAction.updateTime = now;
  }

  Future<void> _updateGoalFromGoalMoment(Goal goal, int now) async {
    goal.lastActiveTime = await goalRepository.getGoalLastActiveTime(goal.id);
    goal.totalTimeTaken = await goalRepository.getGoalTotalTimeTaken(goal.id);
    goal.updateTime = now;
  }

  Future<List<Goal>> _updateGoalWhenUpdateMoment(
      Moment newMoment, Moment oldMoment, int now) async {
    var updatedGoals = Set<Goal>();
    List<Goal> goals =
        await goalRepository.getGoalViaActionId(oldMoment.action.id, false);
    print('_updateGoalWhenUpdateMoment - Goals num: ${goals.length}');
    for (var goal in goals) {
      for (var goalAction in goal.goalActions) {
        if (goalAction.action.id != oldMoment.action.id) continue;
        await goalRepository.deleteGoalMomentViaUniqueKey(
            goal.id, goalAction.id, oldMoment.id);
        await _saveGoalMoment(newMoment, goal, goalAction, now);
        await _updateGoalActionFromGoalMoment(goalAction, now);
        await goalRepository.saveGoalAction(goalAction);
        updatedGoals.add(goal);
      }
    }
    return updatedGoals.toList();
  }

  Future<List<Goal>> _updateGoalWhenDeleteMoment(Moment moment, int now) async {
    var updatedGoals = Set<Goal>();
    List<Goal> goals =
        await goalRepository.getGoalViaActionId(moment.action.id, false);
    print('_updateGoalWhenDeleteMoment - Goals num: ${goals.length}');
    for (var goal in goals) {
      for (var goalAction in goal.goalActions) {
        if (goalAction.action.id != moment.action.id) continue;
        await goalRepository.deleteGoalMomentViaUniqueKey(
            goal.id, goalAction.id, moment.id);
        await _updateGoalActionFromGoalMoment(goalAction, now);
        await goalRepository.saveGoalAction(goalAction);
        updatedGoals.add(goal);
      }
    }
    return updatedGoals.toList();
  }

  Future<void> _updateGoalActionInfo(GoalAction goalAction, int now) async {
    if (goalAction.id == null) {
      var dbGoalAction = await goalRepository.getGoalActionViaGoalAndAction(
          goalAction.goalId, goalAction.actionId, true);
      if (dbGoalAction != null) {
        goalAction.updateTime = now;
        goalAction.id = dbGoalAction.id;
      } else {
        goalAction.createTime = now;
      }
    }
  }

  Future<void> _updateActionInfo(GoalAction goalAction, int now) async {
    if (goalAction.action.id == null) {
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
