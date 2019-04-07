import 'package:rxdart/rxdart.dart';
import 'package:flutter/widgets.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/services/goal_service.dart';


class GoalBloc {
  final _invalidController = PublishSubject<bool>();
  final _items = BehaviorSubject<List<Goal>>.seeded([]);

  final GoalService _goalService;

  GoalBloc(this._goalService) {
    _invalidController.stream.listen(_handleInvalid);
  }

  Sink<bool> get invalid => _invalidController.sink;

  ValueObservable<List<Goal>> get goalsStream => _items.stream;

  void _handleInvalid(bool invalid) async {
    _goalService.getAllGoals().then((goals) {
      _items.add(goals);
    });
  }
}

class GoalProvider extends InheritedWidget {
  final GoalBloc goalBloc;

  GoalProvider({
    Key key,
    @required this.goalBloc,
    Widget child,
  })  : assert(goalBloc != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static GoalBloc of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(GoalProvider) as GoalProvider)
          .goalBloc;
}
