import 'package:rxdart/rxdart.dart';

import 'package:data_life/models/activity.dart';
import 'package:data_life/services/activity_service.dart';


class ActivityHintsBloc {
  final _queryController = PublishSubject<String>();

  final ActivityService _activityService;

  ActivityHintsBloc(this._activityService) {
    _queryController.stream.listen(_handleHint);
  }

  final _hintsSubject = BehaviorSubject<List<Activity>>.seeded([]);

  Sink<String> get query => _queryController.sink;
  ValueObservable<List<Activity>> get hints => _hintsSubject.stream;

  void _handleHint(String query) async {
    const hintLimit = 16;
    var activities = <Activity>[];
    if (query.isEmpty) {
      activities = await _activityService.lastActiveActivity(hintLimit);
    } else {
      activities = await _activityService.queryActivity(query, hintLimit);
    }
    if (activities.isNotEmpty) _hintsSubject.add(activities);
  }

  void dispose() {
    _queryController.close();
    _hintsSubject.close();
  }

}

