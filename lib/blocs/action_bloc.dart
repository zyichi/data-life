import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/action.dart';

import 'package:data_life/repositories/action_repository.dart';

abstract class ActionEvent {}
abstract class ActionState {}

class UpdateAction extends ActionEvent {
  final MyAction oldAction;
  final MyAction newAction;
  UpdateAction({this.oldAction, this.newAction});
}

class ActionUninitialized extends ActionState {}
class ActionUpdated extends ActionState {}
class ActionFailed extends ActionState {
  final String error;
  ActionFailed({this.error}) : assert(error != null);
}

class ActionBloc extends Bloc<ActionEvent, ActionState> {
  final ActionRepository actionRepository;

  ActionBloc(
      {@required this.actionRepository})
      : assert(actionRepository != null);

  @override
  ActionState get initialState => ActionUninitialized();

  @override
  Stream<ActionState> mapEventToState(ActionEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is UpdateAction) {
      final newAction = event.newAction;
      try {
        newAction.updateTime = now;
        actionRepository.save(newAction);
        yield ActionUpdated();
      } catch (e) {
        yield ActionFailed(
            error: 'Update action ${newAction.name} failed: ${e.toString()}');
      }
    }
  }

  Future<bool> actionNameUniqueCheck(String name) async {
    MyAction action = await actionRepository.getViaName(name);
    return action == null;
  }

}
