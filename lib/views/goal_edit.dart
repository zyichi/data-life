import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/views/action_edit.dart';
import 'package:data_life/views/title_form_field.dart';
import 'package:data_life/views/target_progress_form_field.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/item_picker_form_field.dart';
import 'package:data_life/views/common_form_field.dart';

class _ToDoItem extends StatelessWidget {
  final String name;
  const _ToDoItem(this.name);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.subhead;
    final statusStyle = Theme.of(context).textTheme.caption.copyWith(fontSize: 16.0);
    return InkWell(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0, right: 16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  /*
                  Icon(
                    Icons.outlined_flag,
                    size: 24.0,
                  ),
                  SizedBox(width: 8.0,),
                  */
                  Text(
                    name,
                    style: textStyle,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'ongoing',
                style: statusStyle,
              ),
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

  final String title;

  const GoalEdit(this.title);

  @override
  GoalEditState createState() {
    return new GoalEditState();
  }
}

class GoalEditState extends State<GoalEdit> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _completedController = TextEditingController();
  final _goal = Goal();
  String _title;
  DateTime _startDate;
  TimeOfDay _startTime;

  @override
  void initState() {
    super.initState();

    _title = widget.title;
    final now = DateTime.now();
    _startDate = now;
    _startTime = TimeOfDay(hour: now.hour, minute: now.minute);

    _nameController.addListener(() {
      _goal.name = _nameController.text;
      if (_goal.name.isNotEmpty) {
        setState(() {
          _title = _goal.name;
        });
      } else {
        setState(() {
          _title = widget.title;
        });
      }
    });
    _targetController.addListener(() {
      _goal.target = num.tryParse(_targetController.text);
      if (_goal.target != null && _goal.target != 0) {
        setState(() {});
      }
    });
    _completedController.addListener(() {
      _goal.alreadyDone = num.tryParse(_completedController.text);
      if (_goal.alreadyDone != null) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _completedController.dispose();
    super.dispose();
  }

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
        _title = widget.title;
      });
    }
  }

  void _targetChanged(num value) {}

  void _alreadyDoneChanged(num value) {}

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
      lableText: AppLocalizations.of(context).startTime,
      selectedDate: _startDate,
      selectedTime: _startTime,
      selectDate: (value) {
        setState(() {
          _startDate = value;
        });
      },
      selectTime: (value) {
        setState(() {
          _startTime = value;
        });
      },
    );
  }

  Widget _createDurationWidget() {
    final durationList = [
      '15 minutes',
      'one hour',
      'one day',
      'half month',
      'one month',
      'three month',
      'half year',
      'one year'
    ];

    return ItemPicker(
      labelText: 'Duration',
      items: durationList,
      defaultPicked: 0,
      onItemPicked: (value, index) {
      },
    );
  }

  Widget _createAddToDoButton() {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.add,
              size: 24.0,
            ),
            SizedBox(width: 8.0,),
            Text(
              AppLocalizations.of(context).addAction,
              style: Theme.of(context).textTheme.subhead,
            ),
          ],
        ),
      ),
      onTap: () {
        _addToDo();
      },
    );
  }

  Widget _createToDoWidget() {
    final toDoList = ['Run', 'Work out', 'Bike'];
    // final toDoList = [];
    final toDoItems = <Widget>[];
    for (var name in toDoList) {
      toDoItems.add(_ToDoItem(name));
    }
    toDoItems.add(_createAddToDoButton());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelFormField(label: AppLocalizations.of(context).actions,),
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
          FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {}
            },
            child: Text(
              AppLocalizations.of(context).save,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            children: <Widget>[
              TitleFormField(_titleChanged),
              Divider(),
              TargetProgress(_targetChanged, _alreadyDoneChanged),
              Divider(),
              _createStartTimeWidget(),
              _createDurationWidget(),
              Divider(),
              _createToDoWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
