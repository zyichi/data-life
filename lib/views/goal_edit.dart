import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/localizations.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/views/goal_action_edit.dart';
import 'package:data_life/views/progress_target_form_field.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/unique_check_form_field.dart';

import 'package:data_life/blocs/goal_edit_bloc.dart';


void _showGoalActionEditPage(
    BuildContext context, Goal goal, GoalAction goalAction) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => GoalActionEdit(
                goal: goal,
                goalAction: goalAction,
              ),
          fullscreenDialog: true,
          settings: RouteSettings(
            name: GoalActionEdit.routeName,
          )));
}

class _GoalActionItem extends StatelessWidget {
  final Goal goal;
  final GoalAction goalAction;
  const _GoalActionItem({this.goal, this.goalAction})
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
              child: Text('ongoing', style: statusStyle),
            ),
          ],
        ),
      ),
      onTap: () {
        _showGoalActionEditPage(context, goal, goalAction);
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
  GoalEditBloc _goalEditBloc;

  final _formKey = GlobalKey<FormState>();

  final _nameFocusNode = FocusNode();

  String _title;

  @override
  void initState() {
    super.initState();

    if (widget.goal != null) {
      _isReadOnly = true;
      _goal.copy(widget.goal);
      _title = _goal.name;
    } else {
      _title = 'Goal';
      final now = DateTime.now();
      _goal.startTime = now.millisecondsSinceEpoch;
      _goal.progress = 0.0;
      _goal.target = 100.0;
    }

    _goalEditBloc = BlocProvider.of<GoalEditBloc>(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _isNewGoal => widget.goal == null;

  Future<bool> _onWillPop() async {
    return true;
  }

  void _titleChanged(String text) {
    _goal.name = text;
    if (_goal.name.isNotEmpty) {
      setState(() {
        _title = _goal.name;
      });
    } else {
      setState(() {
        _title = widget.goal?.name ?? 'Goal';
      });
    }
  }

  void _targetChanged(num value) {
    _goal.target = value;
  }

  void _progressChanged(num value) {
    _goal.progress = value;
  }
  
  Widget _createStartTimeWidget() {
    return DateTimePicker(
      labelText: AppLocalizations.of(context).startTime,
      initialDateTime: DateTime.fromMillisecondsSinceEpoch(_goal.startTime),
      selectDateTime: (value) {
        _goal.startTime = value.millisecondsSinceEpoch;
      },
      enabled: !_isReadOnly,
    );
  }

  Widget _createStopTimeWidget() {
    return DateTimePicker(
      labelText: 'Stop time',
      initialDateTime: DateTime.fromMillisecondsSinceEpoch(
          _goal.stopTime ?? _goal.startTime + Duration(days: 1).inMilliseconds),
      selectDateTime: (value) {
        _goal.stopTime = value.millisecondsSinceEpoch;
      },
      enabled: !_isReadOnly,
    );
  }

  Widget _createAddToDoButton() {
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
      onTap: _isReadOnly
          ? () {}
          : () {
              _showGoalActionEditPage(context, _goal, null);
            },
    );
  }

  Widget _createGoalActionWidget() {
    final toDoItems = <Widget>[];
    for (GoalAction goalAction in _goal.goalActions) {
      toDoItems.add(_GoalActionItem(goal: _goal, goalAction: goalAction));
    }
    toDoItems.add(_createAddToDoButton());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          _isReadOnly
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isReadOnly = false;
                    });
                    FocusScope.of(context).requestFocus(_nameFocusNode);
                  },
                )
              : IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _editGoal();
                      Navigator.of(context).pop();
                    }
                  },
                ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocListener<GoalEditEvent, GoalEditState>(
          bloc: _goalEditBloc,
          listener: (context, state) {
            if (state is GoalActionAdded || state is GoalActionDeleted || state is GoalActionUpdated) {
              print('Goal action added/deleted/updated');
              setState(() {});
            }
          },
          child: Form(
            key: _formKey,
            onWillPop: _onWillPop,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 16),
              child: ListView(
                children: <Widget>[
                  UniqueCheckFormField(
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
                      if (!isUnique && text != widget.goal.name) {
                        return 'Goal name already exist';
                      }
                      return null;
                    },
                    textChanged: _titleChanged,
                    hintText: 'Enter goal name',
                    uniqueCheckCallback: (String text) {
                      return _goalEditBloc.goalNameUniqueCheck(text);
                    },
                    enabled: !_isReadOnly,
                    autofocus: _isNewGoal,
                  ),
                  Divider(),
                  ProgressTarget(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    progressChanged: _progressChanged,
                    targetChanged: _targetChanged,
                    initialProgress: _goal.progress,
                    initialTarget: _goal.target,
                    enabled: !_isReadOnly,
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  _createStartTimeWidget(),
                  _createStopTimeWidget(),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  _createGoalActionWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateGoalFromForm() {}

  void _editGoal() {
    _updateGoalFromForm();
    print('${_goal.name}');
    if (_isNewGoal) {
      _goalEditBloc.dispatch(
        AddGoal(goal: _goal),
      );
    } else {
      _goalEditBloc.dispatch(UpdateGoal(
        oldGoal: widget.goal,
        newGoal: _goal,
      ));
    }
  }
}
