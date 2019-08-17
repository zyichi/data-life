import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/blocs/goal_bloc.dart';

import 'package:data_life/models/goal.dart';

import 'package:data_life/views/type_to_str.dart';
import 'package:data_life/views/goal_edit.dart';

import 'package:data_life/utils/time_util.dart';

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
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
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
                      widget.goal.status == GoalStatus.finished
                          ? IconButton(
                              icon: Icon(Icons.more_vert,
                                color: Colors.transparent,
                              ),
                              onPressed: null,
                            )
                          : PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: _captionColor(context),
                              ),
                              onSelected: (value) {
                                if (value == 'pause') {
                                  _pauseGoal();
                                }
                                if (value == 'resume') {
                                  _resumeGoal();
                                }
                                if (value == 'finish') {
                                  _finishGoal();
                                }
                              },
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem<String>(
                                    value:
                                        widget.goal.status == GoalStatus.paused
                                            ? 'resume'
                                            : 'pause',
                                    child: _createPauseResumeMenuItem(context),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'finish',
                                    child: _createFinishMenuItem(context),
                                  ),
                                ];
                              },
                            ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, top: 8, right: 16, bottom: 16),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('状态'),
                          Text(
                            '${TypeToStr.goalStatusToStr(widget.goal.status, context)}',
                            style:
                                Theme.of(context).textTheme.subtitle.copyWith(
                                      color: widget.goal.status ==
                                                  GoalStatus.ongoing ||
                                              widget.goal.status ==
                                                  GoalStatus.finished
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).accentColor,
                                      fontSize: 14,
                                    ),
                          ),
                        ],
                      ),
                      Divider(),
                      _createLastActiveTimeWidget(context),
                      Divider(),
                      _createTotalTimeTakenWidget(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _createLastActiveTimeWidget(BuildContext context) {
    String s;
    // TODO: Add Goal.doneTime for GoalStatus.finished
    int t = widget.goal.status == GoalStatus.finished
        ? widget.goal.updateTime
        : widget.goal.lastActiveTime;
    if (t == 0 || t == null) {
      s = '无';
    } else {
      s = TimeUtil.dateStringFromMillis(t) +
          ' ' +
          TimeUtil.timeStringFromMillis(t, context);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          widget.goal.status == GoalStatus.finished ? '完成时间' : '最后活跃',
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
          TimeUtil.formatMillisToDHM(widget.goal.totalTimeTaken, context),
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _createFinishMenuItem(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.done,
          color: _captionColor(context),
        ),
        SizedBox(width: 16),
        Text(
          '完成目标',
          style: TextStyle(
            color: _captionColor(context),
          ),
        ),
      ],
    );
  }

  Widget _createPauseResumeMenuItem(BuildContext context) {
    if (widget.goal.status == GoalStatus.paused) {
      return Row(
        children: <Widget>[
          Icon(
            Icons.play_arrow,
            color: _captionColor(context),
          ),
          SizedBox(width: 16),
          Text(
            '继续目标',
            style: TextStyle(
              color: _captionColor(context),
            ),
          ),
        ],
      );
    } else if (widget.goal.status == GoalStatus.ongoing) {
      return Row(
        children: <Widget>[
          Icon(
            Icons.pause,
            color: _captionColor(context),
          ),
          SizedBox(width: 16),
          Text(
            '暂停目标',
            style: TextStyle(
              color: _captionColor(context),
            ),
          ),
        ],
      );
    }
    return null;
  }

  Color _captionColor(BuildContext context) {
    return Theme.of(context).textTheme.caption.color;
  }

  void _pauseGoal() {
    setState(() {
      widget.goal.updateTime = DateTime.now().millisecondsSinceEpoch;
      widget.goal.status = GoalStatus.paused;
    });
    widget.goalBloc.dispatch(PauseGoal(
      goal: widget.goal,
    ));
  }

  void _resumeGoal() {
    setState(() {
      widget.goal.updateTime = DateTime.now().millisecondsSinceEpoch;
      widget.goal.status = GoalStatus.ongoing;
    });
    widget.goalBloc.dispatch(ResumeGoal(
      goal: widget.goal,
    ));
  }

  void _finishGoal() {
    setState(() {
      widget.goal.updateTime = DateTime.now().millisecondsSinceEpoch;
      widget.goal.status = GoalStatus.finished;
    });
    widget.goalBloc.dispatch(FinishGoal(
      goal: widget.goal,
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
    return Container(
      color: Colors.grey[200],
      child: Padding(
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
              return ListView.builder(
                key: PageStorageKey<String>(widget.name),
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
