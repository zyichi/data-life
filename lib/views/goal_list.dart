import 'package:flutter/material.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/blocs/goal_bloc.dart';
import 'package:data_life/utils/time_format.dart';
import 'package:data_life/localizations.dart';

abstract class _ListItem {}

/*
class _HeadingItem implements _ListItem {
  final GoalType goalType;
  final String goalTypeLiteral;

  _HeadingItem(this.goalType, this.goalTypeLiteral);
}

class _GoalItem implements _ListItem {
  final OldGoal goal;

  _GoalItem(this.goal);
}

List<_ListItem> _createGoalItems(context) {
  final goalsMap = Map<GoalType, List<OldGoal>>();
  final items = <_ListItem>[];
  for (var key in goalsMap.keys) {
    items.add(_HeadingItem(key, getGoalTypeLiteral(context, key)));
    var goals = goalsMap[key];
    if (goals != null && goals.isNotEmpty)
      goals.sort((goalA, goalB) {
        // Reverse sort
        return goalB.createTime.compareTo(goalA.createTime);
      });
    for (var goal in goalsMap[key]) {
      items.add(_GoalItem(goal));
    }
  }
  return items;
}
*/

class GoalList extends StatefulWidget {
  const GoalList();

  @override
  _GoalListState createState() {
    return new _GoalListState();
  }
}

class _GoalListState extends State<GoalList> {
  @override
  void initState() {
    super.initState();
  }

  String _formatTimeSpent(int seconds) {
    final List<int> hms = secondsToHms(seconds);
    return '${hms[0]} hours ${hms[1]} minutes';
  }

  @override
  Widget build(BuildContext context) {
    final goalBloc = GoalProvider.of(context);

    return Scrollbar(
        child: Container(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: StreamBuilder(
          stream: goalBloc.goalsStream,
          initialData: goalBloc.goalsStream.value,
          builder: (context, snapshot) => ListView.builder(
            key: PageStorageKey('tabGoals'),
            itemCount: (snapshot.data as List).length,
                itemBuilder: (context, index) {
                  List<Goal> goals = snapshot.data;
                  final goal = goals[index];
                  return _createGoalWidget(goal);
                },
              ),
        ),
      ),
    ));
  }

  Widget _createGoalWidget(Goal goal) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(left: 8.0, right: 8.0),
      shape: Border(
        top: BorderSide(color: Colors.grey[300]),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              goal.name,
              style: Theme.of(context).textTheme.body1.copyWith(fontSize: 16.0),
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              goal.lastActiveTime.toString(),
              style:
                  Theme.of(context).textTheme.caption.copyWith(fontSize: 14.0),
            )
          ],
        ),
      ),
    );
  }

  /*
  Widget __createGoalWidget(int index, goalItem) {
    var item;

    if (item is _HeadingItem) {
      return Card(
        elevation: 2.0,
        margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        shape: Border(
          bottom: BorderSide.none,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.goalTypeLiteral,
                style: Theme.of(context).textTheme.title.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    } else if (item is _GoalItem) {
      return Card(
        elevation: 2.0,
        margin: const EdgeInsets.only(left: 8.0, right: 8.0),
        shape: Border(
          top: BorderSide(color: Colors.grey[300]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.goal.activityName,
                style:
                    Theme.of(context).textTheme.body1.copyWith(fontSize: 16.0),
              ),
              SizedBox(
                height: 4.0,
              ),
              Text(
                '${AppLocalizations.of(context).totalTime}: ${_formatTimeSpent(item.goal.timeSpent)}',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontSize: 14.0),
              )
            ],
          ),
        ),
      );
    }

    return null;
  }
  */
}
