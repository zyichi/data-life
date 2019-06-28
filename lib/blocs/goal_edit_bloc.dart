import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/action_repository.dart';

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

class UpdateGoalAction extends GoalEditEvent {
  final GoalAction oldGoalAction;
  final GoalAction newGoalAction;

  UpdateGoalAction({@required this.oldGoalAction, @required this.newGoalAction})
      : assert(oldGoalAction != null),
        assert(newGoalAction != null);
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

class GoalAdded extends GoalEditState {}
class GoalActionAdded extends GoalEditState {}
class GoalUpdated extends GoalEditState {}
class GoalActionUpdated extends GoalEditState {}
class GoalDeleted extends GoalEditState {
  final Goal goal;
  GoalDeleted({@required this.goal}) : assert(goal != null);
}
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

  GoalEditBloc({@required this.goalRepository, @required this.actionRepository})
      : assert(goalRepository != null), assert(actionRepository != null);

  @override
  GoalEditState get initialState => GoalUninitialized();

  @override
  Stream<GoalEditState> mapEventToState(GoalEditEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is AddGoal) {
      try {
        final goal = event.goal;
        goal.createTime = now;
        await goalRepository.save(event.goal);
        for (var goalAction in goal.goalActions) {
          await goalRepository.saveGoalAction(goalAction);
        }
        yield GoalAdded();
      } catch (e) {
        yield GoalEditFailed(
            error:
            'Add goal ${event.goal.name} failed: ${e.toString()}');
      }
    }
    if (event is UpdateGoal) {
      final oldGoal = event.oldGoal;
      final newGoal = event.newGoal;
      try {
        newGoal.updateTime = now;
        await goalRepository.save(newGoal);
        yield GoalUpdated();
      } catch (e) {
        yield GoalEditFailed(
            error:
            'Update goal ${oldGoal.name} failed: ${e.toString()}');
      }
    }
    if (event is DeleteGoal) {
      final goal = event.goal;
      try {
        await goalRepository.delete(goal);
        await goalRepository.saveDeleted(goal);
        for (var goalAction in goal.goalActions) {
          await goalRepository.deleteGoalAction(goalAction);
          await goalRepository.saveDeletedGoalAction(goalAction);
        }
        yield GoalDeleted(goal: goal);
      } catch (e) {
        yield GoalEditFailed(
            error:
            'Update goal ${goal.name} failed: ${e.toString()}');
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
    if (event is GoalNameUniqueCheck) {
      try {
        Goal goal =
        await goalRepository.getViaName(event.name);
        yield GoalNameUniqueCheckResult(
            isUnique: goal == null, text: event.name);
      } catch (e) {
        yield GoalEditFailed(
            error: 'Check if goal name unique failed: ${e.toString()}');
      }
    }
  }

  Future<bool> goalNameUniqueCheck(String name) async {
    Goal goal = await goalRepository.getViaName(name);
    return goal == null;
  }

  Future<List<Action>> getActionSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return actionRepository.get(startIndex: 0, count: 8);
    } else {
      return actionRepository.search(pattern);
    }
  }

}
