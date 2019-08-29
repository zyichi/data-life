import 'package:data_life/views/my_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/cupertino.dart';

import 'package:data_life/views/common_dialog.dart';
import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/repeat_page.dart';
import 'package:data_life/views/type_to_str.dart';
import 'package:data_life/views/my_date_picker_form_field.dart';
import 'package:data_life/views/my_form_text_field.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/time_types.dart';
import 'package:data_life/models/repeat_types.dart';

import 'package:data_life/blocs/goal_bloc.dart';

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
  final TextEditingController _actionNameController = TextEditingController();
  final FocusNode _actionNameFocusNode = FocusNode();
  GoalBloc _goalEditBloc;
  bool _autoValidateActionName = false;
  String _repeatText;
  Repeat _customRepeat;
  String _title;
  String _durationStr;

  @override
  void initState() {
    super.initState();

    _goalEditBloc = BlocProvider.of<GoalBloc>(context);

    if (widget.goalAction != null) {
      _isReadOnly = true;

      _goalAction.copy(widget.goalAction);

      _actionNameController.text = _goalAction.action.name;

      _title = '任务';
    } else {
      DateTime now = DateTime.now();
      _goalAction.goalUuid = widget.goal.uuid;
      _goalAction.startDateTime = now;
      _goalAction.stopDateTime =
          _goalAction.startDateTime.add(Duration(hours: 1));
      _goalAction.setRepeat(Repeat.oneTime(now));

      _title = '添加新任务';
    }

    _durationStr = _getDurationStr();

    _actionNameController.addListener(() {
      if (!_autoValidateActionName && _actionNameController.text.isNotEmpty) {
        setState(() {
          _autoValidateActionName = true;
        });
      }
    });
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
        title: Text(_title),
        centerTitle: true,
        actions: <Widget>[
          _buildSaveAction(),
        ],
      ),
      floatingActionButton: _createFloatingActionButton(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AbsorbPointer(
          absorbing: _isReadOnly,
          child: Form(
            key: _formKey,
            onWillPop: _onWillPop,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildActionNameField(),
                ),
                Divider(),
                _buildTimeField(),
                Divider(),
                SizedBox(height: 16),
                _buildRepeatField(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDurationStr() {
    return TimeUtil.formatDurationToDHM(_goalAction.duration, context);
  }

  Widget _createFloatingActionButton() {
    if (!_isReadOnly) {
      return Container();
    }
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        setState(() {
          _isReadOnly = false;
          _title = '修改任务';
        });
      },
      child: Icon(
        Icons.edit,
      ),
    );
  }

  bool get _isNewGoalAction => widget.goalAction == null;

  Widget _buildSaveAction() {
    if (_isReadOnly) {
      return Container();
    } else {
      return IconButton(
        icon: Icon(Icons.check),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _editGoalAction();
          }
        },
      );
    }
  }

  bool _isNeedExitConfirm() {
    if (_isReadOnly) {
      return false;
    }
    _updateGoalActionFromForm();
    if (_isNewGoalAction) {
      if (_goalAction.action != null) {
        return true;
      } else {
        return false;
      }
    } else {
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

  Widget _buildActionNameField() {
    return Stack(
      children: <Widget>[
        AbsorbPointer(
          absorbing: !_isNewGoalAction,
          child: TypeAheadFormField(
            hideOnEmpty: true,
            hideOnLoading: true,
            getImmediateSuggestions: true,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                hintText: 'Enter action',
                border: InputBorder.none,
              ),
              controller: _actionNameController,
              style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
              autofocus: _isNewGoalAction,
              focusNode: _actionNameFocusNode,
            ),
            onSuggestionSelected: (MyAction action) {
              setState(() {
                _actionNameController.text = action.name;
              });
              _goalAction.action = action;
            },
            itemBuilder: (context, suggestion) {
              final action = suggestion as MyAction;
              return Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
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
              return null;
            },
            autovalidate: _autoValidateActionName,
          ),
        ),
        _isNewGoalAction && _actionNameController.text.isNotEmpty
            ? Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: MyFormTextField.buildFieldRemoveButton(() {
                  _actionNameController.clear();
                  FocusScope.of(context).requestFocus(_actionNameFocusNode);
                  _goalAction.action = null;
                }),
              )
            : Container(),
      ],
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
      Navigator.of(context).pop();
    } else {
      widget.goalAction.copy(_goalAction);
      _goalEditBloc.dispatch(UpdateGoalAction(
          goal: widget.goal,
          oldGoalAction: widget.goalAction,
          newGoalAction: _goalAction));
      setState(() {
        _isReadOnly = true;
      });
    }
  }

  Widget _buildTimeField() {
    return FormField(
      builder: (FormFieldState fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 16),
            MyDatePickerFormField(
              labelName: '开始时间',
              onChanged: (DateTime newDateTime) {
                fieldState.didChange(null);
                setState(() {
                  _goalAction.startDateTime = newDateTime;
                  _durationStr = _getDurationStr();
                });
              },
              mutable: !_isReadOnly,
              initialDateTime: _goalAction.startDateTime,
              mode: CupertinoDatePickerMode.dateAndTime,
              labelPadding: EdgeInsets.symmetric(horizontal: 16),
              valuePadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            SizedBox(height: 8),
            MyDatePickerFormField(
              labelName: '结束时间',
              onChanged: (DateTime newDateTime) {
                fieldState.didChange(null);
                setState(() {
                  _goalAction.stopDateTime = newDateTime;
                  _durationStr = _getDurationStr();
                });
              },
              mutable: !_isReadOnly,
              initialDateTime: _goalAction.stopDateTime,
              mode: CupertinoDatePickerMode.dateAndTime,
              labelPadding: EdgeInsets.symmetric(horizontal: 16),
              valuePadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FormFieldError(
                errorText: fieldState.errorText,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: MyReadOnlyTextField(
                name: '持续时间',
                value: _durationStr,
              ),
            ),
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
        if (_isNewGoalAction) {
          if (_goalAction.startTime < nowDate.millisecondsSinceEpoch) {
            return '开始时间必须在当前时间之后';
          }
        }
        if (_goalAction.startTime > _goalAction.stopTime) {
          return '开始时间必须早于结束时间';
        }
        return null;
      },
    );
  }

  Widget _buildRepeatField() {
    return MyFormField(
      label: '重复',
      labelPadding: EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _repeatText,
              ),
              !_isReadOnly
                  ? Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    )
                  : Container(),
            ],
          ),
        ),
        onTap: () async {
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
      ),
    );
  }
}
