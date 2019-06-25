import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/goal.dart';

import 'package:data_life/repositories/goal_repository.dart';

abstract class GoalEditEvent {}

abstract class GoalEditState {}

class AddGoal extends GoalEditEvent {
  final Goal goal;
  AddGoal({@required this.goal}) : assert(goal != null);
}

class UpdateGoal extends GoalEditEvent {
  final Goal oldGoal;
  final Goal newGoal;

  UpdateGoal({@required this.oldGoal, @required this.newGoal})
      : assert(oldGoal != null),
        assert(newGoal != null);
}

class GoalNameUniqueCheck extends GoalEditEvent {
  final String name;

  GoalNameUniqueCheck({this.name}) : assert(name != null);
}

class GoalUninitialized extends GoalEditState {}

class GoalAdded extends GoalEditState {}
class GoalUpdated extends GoalEditState {}

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

  GoalEditBloc({@required this.goalRepository})
      : assert(goalRepository != null);

  @override
  GoalEditState get initialState => GoalUninitialized();

  @override
  Stream<GoalEditState> mapEventToState(GoalEditEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is AddGoal) {
      try {
        goalRepository.save(event.goal);
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
        goalRepository.save(newGoal);
        yield GoalUpdated();
      } catch (e) {
        yield GoalEditFailed(
            error:
            'Update goal ${oldGoal.name} failed: ${e.toString()}');
      }
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
}
