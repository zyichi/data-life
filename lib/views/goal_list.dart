import 'package:data_life/utils/time_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:math';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/blocs/goal_bloc.dart';

import 'package:data_life/models/goal.dart';

import 'package:data_life/views/type_to_str.dart';
import 'package:data_life/views/goal_edit.dart';

enum _GoalItemAction {
  pause,
  resume,
  finish,
  delete,
}

class _GoalListItem extends StatefulWidget {
  final Goal goal;
  final GoalBloc goalBloc;

  _GoalListItem({this.goal, this.goalBloc});

  @override
  __GoalListItemState createState() => __GoalListItemState();
}

class __GoalListItemState extends State<_GoalListItem> {
  @override
  Widget build(BuildContext context) {
    if (widget.goal == null) {
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
      return Material(
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                  child: GoalEdit(goal: widget.goal),
                  type: PageTransitionType.rightToLeft,
                ));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 8, right: 0, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.goal.name,
                      style: Theme.of(context).textTheme.title,
                    ),
                    _buildMenu(widget.goal),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 8, right: 16, bottom: 16),
                child: Column(
                  children: _buildGoalFields(),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  List<Widget> _buildGoalFields() {
    var fields = <Widget>[];
    fields.add(_buildStatusField());
    fields.add(Divider(height: 24));
    switch (widget.goal.status) {
      case GoalStatus.none:
        break;
      case GoalStatus.ongoing:
        fields.add(_buildProgressField(context));
        fields.add(Divider(height: 24));
        fields.add(_buildTimeRemainingField(context));
        break;
      case GoalStatus.paused:
        fields.add(_buildProgressField(context));
        fields.add(Divider(height: 24));
        fields.add(_buildTimeRemainingField(context));
        break;
      case GoalStatus.finished:
        fields.add(_buildTargetField());
        fields.add(Divider(height: 24));
        fields.add(_buildTotalTimeTakenField());
        fields.add(Divider(height: 24));
        fields.add(_buildHowLongField(widget.goal.stopDateTime));
        break;
      case GoalStatus.expired:
        fields.add(_buildProgressField(context));
        fields.add(Divider(height: 24));
        fields.add(_buildTotalTimeTakenField());
        fields.add(Divider(height: 24));
        fields.add(_buildHowLongField(widget.goal.stopDateTime));
        break;
    }
    return fields;
  }

  Widget _buildTargetField() {
    return _buildNameValueField(
      '目标值',
      widget.goal.target.toString(),
      null,
      context,
    );
  }

  Widget _buildTotalTimeTakenField() {
    return _buildNameValueField(
      '实际花费时间',
      TimeUtil.formatMillisToDHM(widget.goal.totalTimeTaken, context),
      null,
      context,
    );
  }

  Widget _buildHowLongField(DateTime endTime) {
    var millis = endTime.millisecondsSinceEpoch - widget.goal.startTime;
    millis = max(0, millis);
    return _buildNameValueField(
      '完成目标用时',
      '${Duration(milliseconds: millis).inDays} 天',
      null,
      context,
    );
  }

  Widget _buildStatusField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('目标状态'),
        Text(
          '${TypeToStr.goalStatusToStr(widget.goal.status, context)}',
          style: Theme.of(context).textTheme.subtitle.copyWith(
                color: widget.goal.status == GoalStatus.ongoing ||
                        widget.goal.status == GoalStatus.finished
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).accentColor,
                fontSize: 14,
              ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(String name, IconData iconData) {
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          color: _captionColor(context),
        ),
        SizedBox(width: 16),
        Text(
          name,
          style: TextStyle(
            color: _captionColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPauseMenuItem(Goal goal) {
    return PopupMenuItem<_GoalItemAction>(
      value: _GoalItemAction.pause,
      child: _buildMenuItem('暂停', Icons.pause),
    );
  }

  Widget _buildResumeMenuItem(Goal goal) {
    return PopupMenuItem<_GoalItemAction>(
      value: _GoalItemAction.resume,
      child: _buildMenuItem('继续', Icons.play_arrow),
    );
  }

  Widget _buildFinishMenuItem(Goal goal) {
    return PopupMenuItem<_GoalItemAction>(
      value: _GoalItemAction.finish,
      child: _buildMenuItem('完成', Icons.done),
    );
  }

  Widget _buildDeleteMenuItem(Goal goal) {
    return PopupMenuItem<_GoalItemAction>(
      value: _GoalItemAction.delete,
      child: _buildMenuItem('删除', Icons.delete),
    );
  }

  Widget _buildMenu(Goal goal) {
    var menuItems = <PopupMenuItem<_GoalItemAction>>[];
    switch (goal.status) {
      case GoalStatus.none:
        break;
      case GoalStatus.ongoing:
        menuItems.add(_buildPauseMenuItem(goal));
        menuItems.add(_buildFinishMenuItem(goal));
        break;
      case GoalStatus.finished:
        break;
      case GoalStatus.expired:
        menuItems.add(_buildFinishMenuItem(goal));
        break;
      case GoalStatus.paused:
        menuItems.add(_buildResumeMenuItem(goal));
        menuItems.add(_buildFinishMenuItem(goal));
        break;
    }
    menuItems.add(_buildDeleteMenuItem(goal));
    return PopupMenuButton<_GoalItemAction>(
      icon: Icon(
        Icons.more_vert,
        color: _captionColor(context),
      ),
      onSelected: (value) {
        switch (value) {
          case _GoalItemAction.pause:
            _pauseGoal(goal);
            break;
          case _GoalItemAction.resume:
            _resumeGoal(goal);
            break;
          case _GoalItemAction.finish:
            _finishGoal(goal);
            break;
          case _GoalItemAction.delete:
            _deleteGoal(goal);
            break;
        }
      },
      itemBuilder: (context) {
        return menuItems;
      },
    );
  }

  Widget _buildProgressField(BuildContext context) {
    return _buildNameValueField(
        '当前进度', '${widget.goal.getProgressPercent()}%', null, context);
  }

  Widget _buildTimeRemainingField(BuildContext context) {
    var milliseconds =
        widget.goal.stopTime - DateTime.now().millisecondsSinceEpoch;
    milliseconds = max(0, milliseconds);
    return _buildNameValueField(
      '剩余时间',
      '${Duration(milliseconds: milliseconds).inDays} 天',
      null,
      context,
    );
  }

  Widget _buildNameValueField(
      String name, String value, TextStyle valueStyle, BuildContext context) {
    if (valueStyle == null) {
      valueStyle = Theme.of(context).textTheme.caption.copyWith(
            fontSize: 14,
          );
    }
    var nameStyle = Theme.of(context).textTheme.body1.copyWith(
          fontSize: 14,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          name,
          style: nameStyle,
        ),
        Text(
          value,
          style: valueStyle,
        ),
      ],
    );
  }

  Color _captionColor(BuildContext context) {
    return Theme.of(context).textTheme.caption.color;
  }

  void _pauseGoal(Goal goal) {
    setState(() {
      widget.goal.updateTime = DateTime.now().millisecondsSinceEpoch;
      widget.goal.status = GoalStatus.paused;
    });
    widget.goalBloc.dispatch(PauseGoal(
      goal: widget.goal,
    ));
  }

  void _resumeGoal(Goal goal) {
    setState(() {
      goal.updateTime = DateTime.now().millisecondsSinceEpoch;
      goal.status = GoalStatus.ongoing;
    });
    widget.goalBloc.dispatch(ResumeGoal(
      goal: goal,
    ));
  }

  void _finishGoal(Goal goal) {
    setState(() {
      var now = DateTime.now();
      goal.updateTime = now.millisecondsSinceEpoch;
      goal.doneDateTime = now;
      goal.status = GoalStatus.finished;
    });
    widget.goalBloc.dispatch(FinishGoal(
      goal: goal,
    ));
  }

  void _deleteGoal(Goal goal) {
    widget.goalBloc.dispatch(DeleteGoal(
      goal: goal,
    ));
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
  GoalBloc _goalBloc;

  @override
  void initState() {
    super.initState();

    _goalListBloc = BlocProvider.of<PageBloc<Goal>>(context);
    _goalListBloc.dispatch(RefreshPage());

    _goalBloc = BlocProvider.of<GoalBloc>(context);
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
    return Material(
      color: Colors.grey[200],
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
              separatorBuilder: (BuildContext context, int i) {
                return Container(
                  height: 16,
                  color: Colors.grey[200],
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
                  goalBloc: _goalBloc,
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
