import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:data_life/localizations.dart';
import 'package:data_life/constants.dart';

import 'package:data_life/views/progress_target_form_field.dart';
import 'package:data_life/views/item_picker_form_field.dart';
import 'package:data_life/views/duration_form_field.dart';
import 'package:data_life/views/type_to_str.dart';
import 'package:data_life/views/common_dialog.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/time_types.dart';

import 'package:data_life/blocs/goal_edit_bloc.dart';

final howOftenOptions = [
  HowOften.notRepeat,
  HowOften.onceMonth,
  HowOften.twiceMonth,
  HowOften.onceWeek,
  HowOften.twiceWeek,
  HowOften.threeTimesWeek,
  HowOften.fourTimesWeek,
  HowOften.fiveTimesWeek,
  HowOften.sixTimesWeek,
  HowOften.everyday,
];

final howLongOptions = [
  HowLong.fifteenMinutes,
  HowLong.thirtyMinutes,
  HowLong.fortyFiveMinutes,
  HowLong.oneHour,
  HowLong.oneHourThirtyMinutes,
  HowLong.twoHours,
  HowLong.halfDay,
  HowLong.wholeDay
];

final bestTimeOptions = [
  BestTime.morning,
  BestTime.afternoon,
  BestTime.evening,
  BestTime.anyTime,
];

String getHowOftenLiteral(BuildContext context, HowOften howOften) {
  switch (howOften) {
    case HowOften.notRepeat:
      return 'Does not repeat';
    case HowOften.onceMonth:
      return AppLocalizations.of(context).onceMonth;
    case HowOften.twiceMonth:
      return AppLocalizations.of(context).twiceMonth;
    case HowOften.onceWeek:
      return AppLocalizations.of(context).onceWeek;
    case HowOften.twiceWeek:
      return AppLocalizations.of(context).twiceWeek;
    case HowOften.threeTimesWeek:
      return AppLocalizations.of(context).threeTimesWeek;
    case HowOften.fourTimesWeek:
      return AppLocalizations.of(context).fourTimesWeek;
    case HowOften.fiveTimesWeek:
      return AppLocalizations.of(context).fiveTimesWeek;
    case HowOften.sixTimesWeek:
      return AppLocalizations.of(context).sixTimesWeek;
    case HowOften.everyday:
      return AppLocalizations.of(context).everyday;
    default:
      return null;
  }
}

String getHowLongLiteral(BuildContext context, HowLong howLong) {
  switch (howLong) {
    case HowLong.fifteenMinutes:
      return AppLocalizations.of(context).fifteenMinutes;
    case HowLong.thirtyMinutes:
      return AppLocalizations.of(context).thirtyMinutes;
    case HowLong.fortyFiveMinutes:
      return '45 minutes';
    case HowLong.oneHour:
      return AppLocalizations.of(context).oneHour;
    case HowLong.oneHourThirtyMinutes:
      return '1 hour 30 minutes';
    case HowLong.twoHours:
      return AppLocalizations.of(context).twoHours;
    case HowLong.halfDay:
      return AppLocalizations.of(context).halfDay;
    case HowLong.wholeDay:
      return AppLocalizations.of(context).wholeDay;
    default:
      return null;
  }
}

String getBestTimeLiteral(BuildContext context, BestTime bestTime) {
  switch (bestTime) {
    case BestTime.morning:
      return AppLocalizations.of(context).morning;
    case BestTime.afternoon:
      return AppLocalizations.of(context).afternoon;
    case BestTime.evening:
      return AppLocalizations.of(context).evening;
    case BestTime.anyTime:
      return AppLocalizations.of(context).anyTime;
    default:
      return null;
  }
}


class _RepeatPickItem {
  final HowOften howOften;
  final String caption;

  _RepeatPickItem(this.howOften, this.caption);

  @override
  String toString() {
    return caption;
  }
}
class _HowLongPickItem {
  final HowLong howLong;
  final String caption;

  _HowLongPickItem(this.howLong, this.caption);

  @override
  String toString() {
    return caption;
  }
}
class _BestTimePickItem {
  final BestTime bestTime;
  final String caption;

  _BestTimePickItem(this.bestTime, this.caption);

  @override
  String toString() {
    return caption;
  }
}

class GoalActionEdit extends StatefulWidget {
  static const routeName = '/goalActionEdit';
  final Goal goal;
  final GoalAction goalAction;

  const GoalActionEdit({this.goal, this.goalAction}) : assert(goal != null);

  @override
  _GoalActionEditState createState() {
    return new _GoalActionEditState();
  }
}

class _GoalActionEditState extends State<GoalActionEdit> {
  final _formKey = GlobalKey<FormState>();
  final GoalAction _goalAction = GoalAction();
  bool _isReadOnly = false;
  final FocusNode _actionNameFocusNode = FocusNode();
  final FocusNode _progressFocusNode = FocusNode();
  final TextEditingController _actionNameController = TextEditingController();
  GoalEditBloc _goalEditBloc;
  bool _autoValidateActionName = false;
  DurationValue _initialDurationValue;

  bool _isNeedExitConfirm() {
    _updateGoalActionFromForm();
    if (_isNewGoalAction) {
      if (_goalAction.action != null) {
        return true;
      } else {
        return false;
      }
    } else {
      if (_isReadOnly) {
        return false;
      }
      if (_goalAction.isContentSameWith(widget.goalAction)) {
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
    return await CommonDialog.showEditExitConfirmDialog(context,
        'Are you sure you want to discard your changes to the goal action?');
  }

  @override
  void initState() {
    super.initState();

    _goalEditBloc = BlocProvider.of<GoalEditBloc>(context);

    if (widget.goalAction != null) {
      _isReadOnly = true;

      _goalAction.copy(widget.goalAction);

      _initialDurationValue = DurationValue(_goalAction.durationType);
      print('Initial duration type: ${TypeToStr.myDurationStr(_initialDurationValue.durationType, context)}');
      _initialDurationValue.startDate = DateTime.fromMillisecondsSinceEpoch(_goalAction.startTime);
      _initialDurationValue.stopDate = DateTime.fromMillisecondsSinceEpoch(_goalAction.stopTime);

      _actionNameController.text = _goalAction.action.name;
    } else {
      final now = DateTime.now();
      _initialDurationValue = DurationValue(widget.goal.durationType);
      _initialDurationValue.startDate = now;

      _goalAction.goalId = widget.goal.id;
      _goalAction.startTime = _initialDurationValue.startDate.millisecondsSinceEpoch;
      _goalAction.durationType = _initialDurationValue.durationType;
      _goalAction.stopTime = _initialDurationValue.stopDate.millisecondsSinceEpoch;

      _goalAction.howOften = HowOften.notRepeat;
      _goalAction.howLong = HowLong.thirtyMinutes;
      _goalAction.bestTime = BestTime.anyTime;
      _goalAction.progress = 0.0;
      _goalAction.target = 100.0;
    }

    _actionNameController.addListener(() {
      if (!_autoValidateActionName && _actionNameController.text.isNotEmpty) {
        setState(() {
          _autoValidateActionName = true;
        });
      }
    });

  }

  bool get _isNewGoalAction => widget.goalAction == null;

  void _targetChanged(num value) {
    _goalAction.target = value;
  }

  void _progressChanged(num value) {
    _goalAction.progress = value;
  }

  Widget _createRepeatWidget() {
    List<_RepeatPickItem> repeatList = howOftenOptions.map((e) {
      String s = getHowOftenLiteral(context, e);
      return _RepeatPickItem(e, s);
    }).toList();
    int pickedIndex = howOftenOptions.indexOf(_goalAction.howOften);
    return ItemPicker(
      labelText: 'Repeat',
      items: repeatList,
      defaultPicked: pickedIndex,
      onItemPicked: (value, index) async {
        _goalAction.howOften = (value as _RepeatPickItem).howOften;
      },
      enabled: !_isReadOnly,
    );
  }

  Widget _createHowLongWidget() {
    List<_HowLongPickItem> howLongList = howLongOptions.map((e) {
      String s = getHowLongLiteral(context, e);
      return _HowLongPickItem(e, s);
    }).toList();
    int pickedIndex = howLongOptions.indexOf(_goalAction.howLong);
    return ItemPicker(
      labelText: 'How long',
      items: howLongList,
      defaultPicked: pickedIndex,
      onItemPicked: (value, index) async {
        _goalAction.howLong = (value as _HowLongPickItem).howLong;
      },
      enabled: !_isReadOnly,
    );
  }

  Widget _createBestTimeWidget() {
    List<_BestTimePickItem> bestTimeList = bestTimeOptions.map((e) {
      String s = getBestTimeLiteral(context, e);
      return _BestTimePickItem(e, s);
    }).toList();
    int pickedIndex = bestTimeOptions.indexOf(_goalAction.bestTime);
    return ItemPicker(
      labelText: 'Best time',
      items: bestTimeList,
      defaultPicked: pickedIndex,
      onItemPicked: (value, index) async {
        _goalAction.bestTime = (value as _BestTimePickItem).bestTime;
      },
      enabled: !_isReadOnly,
    );
  }

  Widget _createEditAction() {
    if (_isReadOnly) {
      return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _isReadOnly = false;
          });
          // FocusScope.of(context).requestFocus(_actionNameFocusNode);
          FocusScope.of(context).requestFocus(_progressFocusNode);
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.check),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _editGoalAction();
            Navigator.of(context).pop(true);
          }
        },
      );
    }
  }

  Widget _createActionNameFormField() {
    return TypeAheadFormField(
      hideOnEmpty: true,
      hideOnLoading: true,
      getImmediateSuggestions: true,
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
          hintText: 'Enter action',
          border: InputBorder.none,
        ),
        controller: _actionNameController,
        focusNode: _actionNameFocusNode,
        style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
        autofocus: !_isReadOnly,
        enabled: _isNewGoalAction,
      ),
      onSuggestionSelected: (Action action) {
        _actionNameController.text = action.name;
        _goalAction.action = action;
      },
      itemBuilder: (context, suggestion) {
        final action = suggestion as Action;
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
          child: Text(
            action.name,
          ),
        );
      },
      suggestionsCallback: (pattern) {
        return _goalEditBloc.getActionSuggestions(pattern);
      },
      validator: (value) {
        if (!_isNewGoalAction) {
          return null;
        }
        if (value.isEmpty) {
          return 'Please enter action';
        }
        for (var goalAction in widget.goal.goalActions) {
          if (goalAction.action.name == value) {
            return 'Action already exist in goal';
          }
        }
      },
      autovalidate: _autoValidateActionName,
    );
  }

  void _updateGoalActionFromForm() {
    if (_goalAction.action == null) {
      if (_actionNameController.text.isNotEmpty) {
        var a = Action();
        a.name = _actionNameController.text;
        _goalAction.action = a;
      }
    }
  }

  void _editGoalAction() {
    _updateGoalActionFromForm();
    if (_isNewGoalAction) {
      widget.goal.goalActions.add(_goalAction);
      _goalEditBloc.dispatch(AddGoalAction(goalAction: _goalAction));
    } else {
      widget.goalAction.copy(_goalAction);
      _goalEditBloc.dispatch(UpdateGoalAction(
          oldGoalAction: widget.goalAction, newGoalAction: _goalAction));
    }
  }

  void _deleteGoalAction() {
    widget.goal.goalActions.remove(widget.goalAction);
    _goalEditBloc.dispatch(DeleteGoalAction(goalAction: widget.goalAction));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_goalAction.action?.name ?? 'Action'),
        actions: <Widget>[
          _createEditAction(),
          _isNewGoalAction
              ? Container()
              : PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteGoalAction();
                      Navigator.of(context).pop(true);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
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
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              _createActionNameFormField(),
              Divider(),
              SizedBox(height: 16),
              ProgressTarget(
                progressChanged: _progressChanged,
                targetChanged: _targetChanged,
                progressFocusNode: _progressFocusNode,
                initialProgress: _goalAction.progress,
                initialTarget: _goalAction.target,
                enabled: !_isReadOnly,
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              DurationFormField(
                enabled: !_isReadOnly,
                durationTypeList: goalActionDurationList,
                durationValidator: (durationValue) {
                  if (durationValue.inDays() < 1) {
                    return 'Goal duration must bigger than 1 day';
                  }
                },
                durationChanged: (durationValue) {
                  print('Duration changed: ${TypeToStr.myDurationStr(durationValue.durationType, context)}');
                  _goalAction.durationType = durationValue.durationType;
                  _goalAction.startTime = durationValue.startDate.millisecondsSinceEpoch;
                  _goalAction.stopTime = durationValue.stopDate.millisecondsSinceEpoch;
                },
                initialDurationValue: _initialDurationValue,
              ),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 16),
              _createRepeatWidget(),
              _createHowLongWidget(),
              _createBestTimeWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
