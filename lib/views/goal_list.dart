import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/models/goal.dart';

import 'package:data_life/views/type_to_str.dart';
import 'package:data_life/views/goal_edit.dart';

import 'package:data_life/utils/time_util.dart';

class _GoalListItem extends StatelessWidget {
  final Goal goal;

  _GoalListItem({this.goal});

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 48.0,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 8.0, right: 16, bottom: 8.0),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                child: GoalEdit(goal: goal),
                type: PageTransitionType.rightToLeft,
              ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
              child: Text(
                goal.name,
                style: Theme.of(context).textTheme.title,
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 16),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('状态'),
                      Text(
                        '${TypeToStr.goalStatusToStr(goal.status, context)}',
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                          color: goal.status == GoalStatus.ongoing ||
                              goal.status == GoalStatus.finished
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).accentColor,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  _createLastActiveTimeWidget(context),
                  Divider(),
                  _createTotalTimeTakenWidget(context),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _createLastActiveTimeWidget(BuildContext context) {
    String s;
    if (goal.lastActiveTime == 0 || goal.lastActiveTime == null) {
      s = '无';
    } else {
      s = TimeUtil.dateStringFromMillis(goal.lastActiveTime) +
          ' ' +
          TimeUtil.timeStringFromMillis(goal.lastActiveTime, context);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          '最后活跃',
        ),
        Text(
          s,
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _createTotalTimeTakenWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "总共用时",
        ),
        Text(
          TimeUtil.formatMillisToDHM(goal.totalTimeTaken, context),
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }
}

class GoalList extends StatefulWidget {
  final String name;

  GoalList({@required this.name}) : assert(name != null);

  @override
  _GoalListState createState() => _GoalListState();
}

class _GoalListState extends State<GoalList>
    with AutomaticKeepAliveClientMixin {
  PageBloc<Goal> _goalListBloc;

  @override
  void initState() {
    super.initState();

    _goalListBloc = BlocProvider.of<PageBloc<Goal>>(context);
    _goalListBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: BlocBuilder(
        bloc: _goalListBloc,
        builder: (context, state) {
          if (state is PageUninitialized) {
            return _createEmptyResults();
          }
          if (state is PageLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is PageLoaded<Goal>) {
            PageList pagedList = state.pageList;
            if (pagedList.total == 0) {
              return _createEmptyResults();
            }
            return ListView.separated(
              key: PageStorageKey<String>(widget.name),
              separatorBuilder: (context, index) {
                return Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.grey[300],
                );
              },
              itemCount: pagedList.total,
              itemBuilder: (context, index) {
                Goal goal = pagedList.itemAt(index);
                if (goal == null) {
                  _goalListBloc.getItem(index);
                }
                return _GoalListItem(
                  goal: goal,
                );
              },
            );
          }
          if (state is PageError) {
            return Center(
              child: Text('Load goal failed'),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _createEmptyResults() {
    return Center(
      child: Text(
        'No goals',
        style: Theme.of(context).textTheme.display2,
      ),
    );
  }
}
