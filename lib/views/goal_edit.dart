import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/localizations.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/views/goal_action_edit.dart';
import 'package:data_life/views/progress_target_form_field.dart';
import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/unique_check_form_field.dart';
import 'package:data_life/views/common_dialog.dart';
import 'package:data_life/views/date_picker_form_field.dart';
import 'package:data_life/views/type_to_str.dart';

import 'package:data_life/blocs/goal_bloc.dart';

void _showGoalActionEditPage(
    BuildContext context, Goal goal, GoalAction goalAction, bool readOnly) {
  Navigator.push(
      context,
      PageTransition(
        child: GoalActionEdit(
          goal: goal,
          goalAction: goalAction,
          parentReadOnly: readOnly,
        ),
        type: PageTransitionType.rightToLeft,
      ));
}

class _GoalActionItem extends StatelessWidget {
  final Goal goal;
  final GoalAction goalAction;
  final bool parentReadOnly;
  const _GoalActionItem(
      {this.goal, this.goalAction, this.parentReadOnly = true})
      : assert(goal != null),
        assert(goalAction != null);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.subhead;
    final statusStyle =
        Theme.of(context).textTheme.caption.copyWith(fontSize: 16.0);
    return InkWell(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 0, top: 8.0, bottom: 8.0, right: 0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  Text(goalAction.action.name, style: textStyle),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                TypeToStr.goalActionStatusToStr(goalAction.status, context),
                style: statusStyle,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _showGoalActionEditPage(context, goal, goalAction, parentReadOnly);
      },
    );
  }
}

class GoalEdit extends StatefulWidget {
  static const routeName = '/editGoal';

  final Goal goal;

  const GoalEdit({this.goal});

  @override
  _GoalEditState createState() {
    return new _GoalEditState();
  }
}

class _GoalEditState extends State<GoalEdit> {
  bool _isReadOnly = false;
  final Goal _goal = Goal();
  GoalBloc _goalBloc;

  final _formKey = GlobalKey<FormState>();

  final _nameFocusNode = FocusNode();

  String _title;

  @override
  void initState() {
    super.initState();

    if (widget.goal != null) {
      _isReadOnly = true;
      _goal.copy(widget.goal);
      _goal.goalActions = <GoalAction>[];
      for (var goalAction in widget.goal.goalActions) {
        _goal.goalActions.add(GoalAction.copeCreate(goalAction));
      }
      _title = 'Goal';
    } else {
      _title = 'New Goal';

      var now = DateTime.now();
      _goal.startTime =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      _goal.stopTime = _goal.startTime + Duration(days: 7).inMilliseconds;

      _goal.progress = 0.0;
      _goal.target = 100.0;
    }

    _goalBloc = BlocProvider.of<GoalBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        actions: <Widget>[
          _createEditAction(),
          _createActionMenu(),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AbsorbPointer(
          absorbing: _isReadOnly,
          child: BlocListener<GoalBloc, GoalState>(
            bloc: _goalBloc,
            listener: (context, state) {
              if (state is GoalActionAdded ||
                  state is GoalActionDeleted ||
                  state is GoalActionUpdated) {
                print('Goal action added/deleted/updated');
                setState(() {});
              }
            },
            child: Form(
              key: _formKey,
              onWillPop: _onWillPop,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ListView(
                  children: <Widget>[
                    _getGoalStatus(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: UniqueCheckFormField(
                        initialValue: _goal.name,
                        focusNode: _nameFocusNode,
                        textStyle: Theme.of(context)
                            .textTheme
                            .subhead
                            .copyWith(fontSize: 24),
                        validator: (String text, bool isUnique) {
                          if (text.isEmpty) {
                            return 'Goal name can not empty';
                          }
                          if (!isUnique && text != widget.goal?.name) {
                            return 'Goal name already exist';
                          }
                          return null;
                        },
                        textChanged: _nameChanged,
                        hintText: 'Enter goal name',
                        uniqueCheckCallback: (String text) {
                          return _goalBloc.goalNameUniqueCheck(text);
                        },
                        autofocus: _isNewGoal,
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ProgressTarget(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        progressChanged: _progressChanged,
                        targetChanged: _targetChanged,
                        initialProgress: _goal.progress,
                        initialTarget: _goal.target,
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FormField(
                        builder: (FormFieldState fieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              DatePickerFormField(
                                labelText: 'From',
                                initialDateTime:
                                    DateTime.fromMillisecondsSinceEpoch(
                                        _goal.startTime),
                                selectDate: (date) {
                                  fieldState.didChange(null);
                                  print('Selected goal from date: $date');
                                  _goal.startTime = date.millisecondsSinceEpoch;
                                },
                              ),
                              DatePickerFormField(
                                labelText: 'To',
                                initialDateTime:
                                    DateTime.fromMillisecondsSinceEpoch(
                                        _goal.stopTime),
                                selectDate: (date) {
                                  fieldState.didChange(null);
                                  print('Selected goal to date: $date');
                                  _goal.stopTime = date.millisecondsSinceEpoch;
                                },
                              ),
                              FormFieldError(
                                errorText: fieldState.errorText,
                              )
                            ],
                          );
                        },
                        autovalidate: true,
                        validator: (value) {
                          if (_isReadOnly) {
                            return null;
                          }
                          var now = DateTime.now();
                          var nowDate = DateTime(now.year, now.month, now.day);
                          if (_isNewGoal) {
                            if (_goal.startTime <
                                nowDate.millisecondsSinceEpoch) {
                              return '开始时间必须在当前时间之后';
                            }
                          }
                          if (_goal.stopTime - _goal.startTime <
                              Duration(days: 3).inMilliseconds) {
                            return '时长必须大于三天';
                          }
                          if (_goal.startTime > _goal.stopTime) {
                            return '开始时间必须早于结束时间';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _createGoalActionWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _captionColor() {
    return Theme.of(context).textTheme.caption.color;
  }

  Widget _createFinishMenuItem() {
    return Row(
      children: <Widget>[
        Icon(
          Icons.done,
          color: _captionColor(),
        ),
        SizedBox(width: 16),
        Text(
          'Finish goal',
          style: TextStyle(
            color: _captionColor(),
          ),
        ),
      ],
    );
  }

  Widget _createPauseResumeMenuItem() {
    if (_goal.status == GoalStatus.paused) {
      return Row(
        children: <Widget>[
          Icon(
            Icons.play_arrow,
            color: _captionColor(),
          ),
          SizedBox(width: 16),
          Text(
            'Resume goal',
            style: TextStyle(
              color: _captionColor(),
            ),
          ),
        ],
      );
    } else if (_goal.status == GoalStatus.ongoing) {
      return Row(
        children: <Widget>[
          Icon(
            Icons.pause,
            color: _captionColor(),
          ),
          SizedBox(width: 16),
          Text(
            'Pause goal',
            style: TextStyle(
              color: _captionColor(),
            ),
          ),
        ],
      );
    }
    return null;
  }

  bool get _isNewGoal => widget.goal == null;

  bool _isNeedExitConfirm() {
    _updateGoalFromForm();
    if (_isNewGoal) {
      if (_goal.name.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      if (_isReadOnly) {
        return false;
      }
      if (_goal.isContentSameWith(widget.goal)) {
        return false;
      } else {
        return true;
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isNeedExitConfirm()) {
      return true;
    }
    return await CommonDialog.showEditExitConfirmDialog(
        context, 'Are you sure you want to discard your changes to the goal?');
  }

  void _nameChanged(String text) {
    _goal.name = text;
  }

  void _targetChanged(num value) {
    _goal.target = value;
  }

  void _progressChanged(num value) {
    _goal.progress = value;
  }

  Widget _createAddGoalActionButton() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(left: 0, top: 8.0, right: 0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.add, size: 24.0),
            SizedBox(width: 8.0),
            Text(
              AppLocalizations.of(context).addAction,
              style: Theme.of(context).textTheme.subhead,
            ),
          ],
        ),
      ),
      onTap: () {
              _showGoalActionEditPage(context, _goal, null, false);
            },
    );
  }

  Widget _createGoalActionWidget() {
    final toDoItems = <Widget>[];
    for (GoalAction goalAction in _goal.goalActions) {
      toDoItems.add(_GoalActionItem(
        goal: _goal,
        goalAction: goalAction,
        parentReadOnly: _isReadOnly,
      ));
    }
    toDoItems.add(_createAddGoalActionButton());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelFormField(
          label: AppLocalizations.of(context).actions,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: toDoItems,
        ),
      ],
    );
  }

  void _updateGoalFromForm() {}

  void _editGoal() {
    _updateGoalFromForm();
    if (_isNewGoal) {
      _goalBloc.dispatch(
        AddGoal(goal: _goal),
      );
    } else {
      if (_goal.isContentSameWith(widget.goal)) {
        print('Same goal content, not need to update');
        return;
      }
      _goalBloc.dispatch(UpdateGoal(
        oldGoal: widget.goal,
        newGoal: _goal,
      ));
    }
  }

  void _pauseGoal() {
    setState(() {
      _goal.status = GoalStatus.paused;
    });
    _goalBloc.dispatch(PauseGoal(
      oldGoal: widget.goal,
      newGoal: _goal,
    ));
  }

  void _resumeGoal() {
    setState(() {
      _goal.status = GoalStatus.ongoing;
    });
    _goalBloc.dispatch(ResumeGoal(
      oldGoal: widget.goal,
      newGoal: _goal,
    ));
  }

  void _finishGoal() {
    setState(() {
      _goal.status = GoalStatus.finished;
    });
    _goalBloc.dispatch(FinishGoal(
      oldGoal: widget.goal,
      newGoal: _goal,
    ));
  }

  Widget _getGoalStatus() {
    if (_goal.status == GoalStatus.ongoing) return Container();
    return Center(
      child: Text(
        '${TypeToStr.goalStatusToStr(_goal.status, context)}',
        style: TextStyle(
          color: _goal.status == GoalStatus.finished
              ? Theme.of(context).primaryColor
              : Theme.of(context).accentColor,
        ),
      ),
    );
  }

  Widget _createActionMenu() {
    if (_isNewGoal ||
        _goal.status == GoalStatus.finished ||
        _goal.status == GoalStatus.expired) {
      return Container();
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert),
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
            value: _goal.status == GoalStatus.paused ? 'resume' : 'pause',
            child: _createPauseResumeMenuItem(),
          ),
          PopupMenuItem<String>(
            value: 'finish',
            child: _createFinishMenuItem(),
          ),
        ];
      },
    );
  }

  Widget _createCheckAction() {
    return IconButton(
      icon: Icon(Icons.check),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          _editGoal();
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _createEditAction() {
    if (_isNewGoal) {
      return _createCheckAction();
    }
    if (_goal.status == GoalStatus.finished || _goal.status == GoalStatus.expired) {
      return Container();
    }
    if (_isReadOnly) {
      return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _isReadOnly = false;
            _title = 'Edit Goal';
          });
          FocusScope.of(context).requestFocus(_nameFocusNode);
        },
      );
    } else {
      return _createCheckAction();
    }
  }
}
