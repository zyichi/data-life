import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/common_dialog.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/repeat_page.dart';
import 'package:data_life/views/type_to_str.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/time_types.dart';
import 'package:data_life/models/repeat_types.dart';

import 'package:data_life/blocs/goal_edit_bloc.dart';

import 'package:data_life/localizations.dart';
import 'package:data_life/utils/time_util.dart';

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
  HowLong.oneHour,
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

class GoalActionEdit extends StatefulWidget {
  static const routeName = '/goalActionEdit';
  final Goal goal;
  final GoalAction goalAction;
  final bool parentReadOnly;

  const GoalActionEdit(
      {this.goal, this.goalAction, this.parentReadOnly = false})
      : assert(goal != null);

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
  String _repeatText;
  Repeat _customRepeat;

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

      _actionNameController.text = _goalAction.action.name;
    } else {
      DateTime now = DateTime.now();
      _goalAction.goalId = widget.goal.id;
      _goalAction.startTime = now.millisecondsSinceEpoch;
      _goalAction.stopTime =
          _goalAction.startTime + Duration(hours: 1).inMilliseconds;
      _goalAction.setRepeat(Repeat.oneTime(now));
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

  Widget _createEditAction() {
    if (widget.parentReadOnly) return Container();
    if (_isReadOnly) {
      return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _isReadOnly = false;
          });
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

  Widget _createMoreActionMenu() {
    if (widget.parentReadOnly || _isNewGoalAction) return Container();
    return PopupMenuButton<String>(
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
    );
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
        // autofocus: !_isReadOnly,
        enabled: _isNewGoalAction,
      ),
      onSuggestionSelected: (MyAction action) {
        _actionNameController.text = action.name;
        _goalAction.action = action;
      },
      itemBuilder: (context, suggestion) {
        final action = suggestion as MyAction;
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
          print('here 1');
          return 'Please enter action';
        }
        for (var goalAction in widget.goal.goalActions) {
          if (goalAction.action.name == value) {
            print('here 2 ${goalAction.action.name}:$value');
            return 'Action already exist in goal';
          }
        }
        return null;
      },
      autovalidate: _autoValidateActionName,
    );
  }

  void _updateGoalActionFromForm() {
    if (_goalAction.action == null) {
      if (_actionNameController.text.isNotEmpty) {
        var a = MyAction();
        a.name = _actionNameController.text;
        _goalAction.action = a;
      }
    }
  }

  void _editGoalAction() {
    _updateGoalActionFromForm();
    if (_isNewGoalAction) {
      setState(() {
        _autoValidateActionName = false;
      });
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
    _repeatText =
        TypeToStr.repeatToReadableText(_goalAction.getRepeat(), context);
    if (_goalAction.repeatType == RepeatType.custom) {
      _repeatText = 'Custom ($_repeatText)';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_goalAction.action?.name ?? 'Action'),
        centerTitle: true,
        actions: <Widget>[
          _createEditAction(),
          _createMoreActionMenu(),
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
              FormField(
                builder: (fieldState) {
                  return Column(
                    children: <Widget>[
                      DateTimePickerFormField(
                        labelText: 'From',
                        initialDateTime:
                        DateTime.fromMillisecondsSinceEpoch(_goalAction.startTime),
                        selectDateTime: (time) {
                          _goalAction.startTime = time.millisecondsSinceEpoch;
                          fieldState.didChange(null);
                        },
                        enabled: !_isReadOnly,
                      ),
                      DateTimePickerFormField(
                        labelText: 'To',
                        initialDateTime:
                        DateTime.fromMillisecondsSinceEpoch(_goalAction.stopTime),
                        selectDateTime: (time) {
                          _goalAction.stopTime = time.millisecondsSinceEpoch;
                          fieldState.didChange(null);
                        },
                        enabled: !_isReadOnly,
                      ),
                    ],
                  );
                },
                autovalidate: true,
                validator: (value) {
                  var now = DateTime.now();
                  var nowDate = DateTime(now.year, now.month, now.day);
                  if (_goalAction.startTime < nowDate.millisecondsSinceEpoch) {
                    return '开始时间必须在当前时间之后';
                  }
                  if (_goalAction.startTime > _goalAction.stopTime) {
                    return '开始时间必须早于结束时间';
                  }
                  return null;
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  LabelFormField(
                    label: 'Repeat',
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _repeatText,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                    ),
                    onTap: _isReadOnly
                        ? null
                        : () async {
                            _customRepeat = await Navigator.push(
                                context,
                                PageTransition(
                                  child: RepeatPage(
                                    goalAction: _goalAction,
                                    customRepeat: _customRepeat,
                                  ),
                                  type: PageTransitionType.rightToLeft,
                                ));
                            setState(() {
                              _repeatText = TypeToStr.repeatToReadableText(
                                  _goalAction.getRepeat(), context);
                            });
                          },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
