import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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
import 'package:data_life/views/my_form_text_field.dart';
import 'package:data_life/views/list_dialog.dart';

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

  TextEditingController _targetController = TextEditingController();
  TextEditingController _progressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final _nameFocusNode = FocusNode();

  String _title;
  String _progressPercent;
  String _howLong;
  String _customHowLong;

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
      _title = '目标';
    } else {
      _title = '设立新目标';

      var now = DateTime.now();
      _goal.startTime =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      _goal.stopTime = _goal.startTime + Duration(days: 7).inMilliseconds;
    }

    _progressPercent = _getProgressPercent();

    _targetController.text = _getNumDisplayStr(_goal.target);
    _targetController.addListener(() {
      setState(() {
        // _goal.target = num.tryParse(_targetController.text);
      });
    });

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
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {},
        child: Icon(
          Icons.edit,
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
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
          child: Material(
            // color: Colors.grey[200],
            color: Colors.white,
            child: Form(
              key: _formKey,
              onWillPop: _onWillPop,
              child: ListView(
                children: <Widget>[
                  // _getGoalStatus(),
                  AbsorbPointer(
                    absorbing: _isReadOnly,
                    child: Column(
                      children: <Widget>[
                        _createGoalNameField(),
                        Divider(),
                        // _createSeparator(),
                        _createTargetProgressField(),
                        _createSeparator(),
                        _createGoalTimeField(),
                      ],
                    ),
                  ),
                  _createSeparator(),
                  _createGoalTaskField(),
                  /*
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ProgressTarget(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      progressChanged: _progressChanged,
                      targetChanged: _targetChanged,
                      initialProgress: _goal.progress,
                      initialTarget: _goal.target,
                      enabled: !_isReadOnly,
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
                              enabled: !_isReadOnly,
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
                              enabled: !_isReadOnly,
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
                  */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _isNewGoal => widget.goal == null;

  String _formatDateFromMillis(int t) {
    return DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY)
        .format(DateTime.fromMillisecondsSinceEpoch(t));
  }

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
      onTap: _isReadOnly
          ? null
          : () {
              _showGoalActionEditPage(context, _goal, null, false);
            },
    );
  }

  Widget _createGoalActionItem(Goal goal, GoalAction goalAction) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              goalAction.action.name,
              style: _fieldNameTextStyle(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  TypeToStr.goalActionStatusToStr(goalAction.status, context),
                  style: TextStyle(color: _captionColor(context)),
                ),
                SizedBox(width: 0),
                Icon(
                  Icons.chevron_right,
                  color: _captionColor(context),
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        _showGoalActionEditPage(context, _goal, goalAction, _isReadOnly);
      },
    );
  }

  Widget _createAddGoalActionItem() {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '添加新任务',
              style: _fieldNameTextStyle().copyWith(
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context).primaryColorDark),
          ],
        ),
      ),
      onTap: () {
        _showGoalActionEditPage(context, _goal, null, false);
      },
    );
  }

  Widget _emptyGoalActionItem() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      child: Text(
        '无任务',
        style: _fieldNameTextStyle().copyWith(color: _captionColor(context)),
      ),
    );
  }

  Widget _createGoalActionWidget() {
    final toDoItems = <Widget>[];
    for (GoalAction goalAction in _goal.goalActions) {
      toDoItems.add(_createGoalActionItem(_goal, goalAction));
      toDoItems.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Divider(),
      ));
    }
    // Remove last divider
    if (_isReadOnly) {
      if (toDoItems.isNotEmpty) {
        toDoItems.removeLast();
      } else {
        toDoItems.add(_emptyGoalActionItem());
      }
      toDoItems.add(SizedBox(
        height: 8,
      ));
    } else {
      if (toDoItems.isEmpty) {
        toDoItems.add(_emptyGoalActionItem());
        toDoItems.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(),
        ));
      }
      toDoItems.add(_createAddGoalActionItem());
      toDoItems.add(SizedBox(height: 8));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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

  Widget _getGoalStatus() {
    if (_goal.status == GoalStatus.ongoing) return Container();
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 8),
      child: Center(
        child: Text(
          '${TypeToStr.goalStatusToStr(_goal.status, context)}',
          style: TextStyle(
            color: _goal.status == GoalStatus.finished
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).accentColor,
          ),
        ),
      ),
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
    if (_goal.status == GoalStatus.finished ||
        _goal.status == GoalStatus.expired) {
      return Container();
    }
    if (_isReadOnly) {
      return IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _isReadOnly = false;
            _title = '修改目标';
          });
          FocusScope.of(context).requestFocus(_nameFocusNode);
        },
      );
    } else {
      return _createCheckAction();
    }
  }

  Color _captionColor(BuildContext context) {
    return Theme.of(context).textTheme.caption.color;
  }

  Widget _createSeparator() {
    return Container(
      width: double.infinity,
      height: 8,
    );
  }

  String _getProgressPercent() {
    if (_goal.progress == null || _goal.target == null || _goal.target == 0) {
      return '0%';
    }
    double percent = _goal.progress / _goal.target * 100;
    return '${percent.toInt()}%';
  }

  String _getNumDisplayStr(num num) {
    if (num == null) {
      return null;
    }
    int n = num.toInt();
    if ((num - n) == 0) {
      return n.toString();
    } else {
      return num.toString();
    }
  }

  Widget _createGoalNameField() {
    return Material(
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
        child: UniqueCheckFormField(
          initialValue: _goal.name,
          focusNode: _nameFocusNode,
          textStyle: Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
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
          hintText: '输入目标名称',
          uniqueCheckCallback: (String text) {
            return _goalBloc.goalNameUniqueCheck(text);
          },
          autofocus: _isNewGoal,
        ),
      ),
    );
  }

  Widget _createTargetProgressField() {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
        child: Column(
          children: <Widget>[
            MyFormTextField(
              name: '目标值',
              inputHint: '输入目标值',
              initialValue: _getNumDisplayStr(_goal.target),
              valueMutable: !_isReadOnly,
              valueChanged: (String text) {
                num value = num.tryParse(text);
                setState(() {
                  _goal.target = value ?? 0;
                  _progressPercent = _getProgressPercent();
                });
              },
              validator: (String text) {
                if (text == null || text.isEmpty) {
                  return '目标值不能为空';
                }
                var val = num.tryParse(text);
                if (val == null) {
                  return '目标值必须是数字';
                }
                if (val <= 0) {
                  return '目标值必须大于 0';
                }
                return null;
              },
            ),
            Divider(),
            MyFormTextField(
              name: '当前进度值',
              inputHint: '输入当前进度值',
              initialValue: _getNumDisplayStr(_goal.progress),
              valueMutable: !_isReadOnly,
              valueChanged: (String text) {
                num value = num.tryParse(text);
                setState(() {
                  _goal.progress = value ?? 0;
                  _progressPercent = _getProgressPercent();
                });
              },
              validator: (String text) {
                if (text == null || text.isEmpty) {
                  return '当前进度值不能为空';
                }
                var val = num.tryParse(text);
                if (val == null) {
                  return '当前进度值必须是数字';
                }
                if (val < 0) {
                  return '当前进度值必须是正数';
                }
                return null;
              },
            ),
            Divider(),
            MyImmutableFormTextField(
              name: '完成百分比',
              value: _progressPercent,
            ),
          ],
        ),
      ),
    );
  }

  bool get _modifiable => !_isReadOnly;

  Widget _createGoalTimeField() {
    final String custom = '自定义...';
    _customHowLong = custom;
    var howLongValues = <String>[
      '1 周',
      '半个月',
      '1 个月',
      '3 个月',
      '半年',
      '1 年',
      custom,
    ];
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Column(
          children: <Widget>[
            FlatButton(
              child: Text('Current $_howLong'),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return ListDialog<String>(
                        items: howLongValues.map((howLong) {
                          String howLongText = howLong;
                          if (howLong == custom) {
                            howLongText = _customHowLong;
                          }
                          return ListDialogItem<String>(
                            value: howLong,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(howLongText),
                                howLong == _howLong ? Icon(Icons.check,
                                  color: Colors.blue,
                                ) : Container(),
                              ],
                            ),
                          );
                        }).toList(),
                        value: _howLong,
                        onChanged: (String newValue) {
                          setState(() {
                            _howLong = newValue;
                          });
                          if (newValue == custom) {
                            showModalBottomSheet(context:
                              context,
                              builder: (context) {
                                return _createCustomHowLongWidget();
                              },
                            );
                          }
                        },
                        contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                        itemPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                      );
                    });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 1,
                    child: Text(
                      '开始时间',
                      style: _fieldNameTextStyle(),
                    )),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            _formatDateFromMillis(_goal.startTime),
                            textAlign: TextAlign.end,
                            style: _fieldValueTextStyle(_modifiable),
                          ),
                          _isReadOnly
                              ? Container()
                              : Icon(
                                  Icons.chevron_right,
                                  color: _captionColor(context),
                                ),
                        ],
                      ),
                    ),
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        currentTime: DateTime.fromMillisecondsSinceEpoch(
                            _goal.startTime),
                        showTitleActions: true,
                        onConfirm: (value) {
                          setState(() {
                            _goal.startTime = value.millisecondsSinceEpoch;
                          });
                        },
                        minTime: DateTime(1898, 8),
                        maxTime: DateTime(2998, 8),
                      );
                    },
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                    flex: 1,
                    child: Text(
                      '结束时间',
                      style: _fieldNameTextStyle(),
                    )),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            _formatDateFromMillis(_goal.stopTime),
                            textAlign: TextAlign.end,
                            style: _fieldValueTextStyle(_modifiable),
                          ),
                          _isReadOnly
                              ? Container()
                              : Icon(
                                  Icons.chevron_right,
                                  color: _captionColor(context),
                                ),
                        ],
                      ),
                    ),
                    onTap: () {
                      DatePicker.showDatePicker(
                        context,
                        currentTime:
                            DateTime.fromMillisecondsSinceEpoch(_goal.stopTime),
                        showTitleActions: true,
                        onConfirm: (value) {
                          setState(() {
                            _goal.stopTime = value.millisecondsSinceEpoch;
                          });
                        },
                        minTime: DateTime(1898, 8),
                        maxTime: DateTime(2998, 8),
                      );
                    },
                  ),
                )
              ],
            ),
            Divider(),
            MyImmutableFormTextField(
              name: '持续时间',
              value:
                  '${Duration(milliseconds: (_goal.stopTime - _goal.startTime)).inDays} 天',
            ),
          ],
        ),
      ),
    );
  }

  Widget _createGoalTaskField() {
    return Material(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
            child: Text(
              '任务',
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          Divider(),
          _createGoalActionWidget(),
        ],
      ),
    );
  }

  Color _modifiableFieldColor(bool modifiable) {
    if (modifiable) {
      return Colors.black;
    } else {
      return _captionColor(context);
    }
  }

  TextStyle _fieldNameTextStyle() {
    return TextStyle(
      fontSize: 16,
    );
  }

  TextStyle _fieldValueTextStyle(bool modifiable) {
    return TextStyle(
      fontSize: 16,
      color: _modifiableFieldColor(modifiable),
    );
  }

  Widget _createCustomHowLongWidget() {
    return Container(
      child: Column(
        children: <Widget>[
          Text('2 年 1 个月 15 天'),
          Row(
            children: <Widget>[
              Container(
                width: 60,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType:
                  TextInputType.numberWithOptions(signed: true),
                  decoration: InputDecoration(),
                  style: Theme.of(context).textTheme.subhead,
                  controller: TextEditingController(text: '1'),
                ),
              ),
              SizedBox(width: 16),
              Text('年'),
              SizedBox(width: 16),
              Container(
                width: 40,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType:
                  TextInputType.numberWithOptions(signed: true),
                  decoration: InputDecoration(),
                  style: Theme.of(context).textTheme.subhead,
                  controller: TextEditingController(text: '6'),
                ),
              ),
              SizedBox(width: 16),
              Text('个月'),
              SizedBox(width: 16),
              Container(
                width: 60,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType:
                  TextInputType.numberWithOptions(signed: true),
                  decoration: InputDecoration(),
                  style: Theme.of(context).textTheme.subhead,
                  controller: TextEditingController(text: '12'),
                ),
              ),
              SizedBox(width: 16),
              Text('天'),
            ],
          )
        ],
      ),
    );
  }
}
