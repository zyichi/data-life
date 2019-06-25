import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/localizations.dart';
import 'package:data_life/constants.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/time_types.dart';

import 'package:data_life/views/action_edit.dart';
import 'package:data_life/views/progress_target_form_field.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/item_picker_form_field.dart';
import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/unique_check_form_field.dart';
import 'package:data_life/views/type_to_str.dart';

import 'package:data_life/blocs/goal_edit_bloc.dart';

class _DurationPickItem {
  final DurationType durationType;
  final String caption;
  _DurationPickItem({this.durationType, this.caption});

  @override
  String toString() {
    return caption;
  }
}

class _ToDoItem extends StatelessWidget {
  final String name;
  const _ToDoItem(this.name);

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
                  Text(name, style: textStyle),
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
      onTap: () {},
    );
  }
}

class GoalEdit extends StatefulWidget {
  static const routeName = '/editGoal';

  final Goal goal;

  const GoalEdit({this.goal});

  @override
  GoalEditState createState() {
    return new GoalEditState();
  }
}

class GoalEditState extends State<GoalEdit> {
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

  void _addToDo() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                ActionEdit(AppLocalizations.of(context).action),
            fullscreenDialog: true,
            settings: RouteSettings(
              name: ActionEdit.routeName,
            )));
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

  Widget _createDurationWidget() {
    final itemList = defaultDurationList.map((t) {
      _DurationPickItem item = _DurationPickItem(
        caption: TypeToStr.myDurationStr(t, context),
        durationType: t,
      );
      return item;
    }).toList();
    int defaultPicked = 0;
    itemList.indexWhere((item) => item.durationType == _goal.durationType);
    return ItemPicker<_DurationPickItem>(
      labelText: 'Duration',
      items: itemList,
      defaultPicked: defaultPicked,
      onItemPicked: (value, index) {
        DurationType t = defaultDurationList[index];
        _goal.durationType = t;
        if (_goal.durationType == DurationType.userSelectTime) {
          // Show stop time picker.
        }
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
              _addToDo();
            },
    );
  }

  Widget _createToDoWidget() {
    final toDoItems = <Widget>[];
    for (GoalAction goalAction in _goal.goalActions) {
      toDoItems.add(_ToDoItem(goalAction.action.name));
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
                  validator: (String text, bool isUnique, bool isEdited) {
                    if (isEdited && text.isEmpty) {
                      return 'Goal name can not empty';
                    }
                    if (!isUnique) {
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
                // _createDurationWidget(),
                SizedBox(height: 8),
                Divider(),
                SizedBox(height: 8),
                _createToDoWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateGoalFromForm() {}

  void _editGoal() {
    _updateGoalFromForm();
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
