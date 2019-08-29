import 'package:data_life/views/my_date_picker_form_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/cupertino.dart';

import 'package:percent_indicator/percent_indicator.dart';

import 'package:data_life/models/goal.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/views/goal_action_edit.dart';
import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/unique_check_form_field.dart';
import 'package:data_life/views/common_dialog.dart';
import 'package:data_life/views/type_to_str.dart';
import 'package:data_life/views/my_form_text_field.dart';

import 'package:data_life/blocs/goal_bloc.dart';



void _showGoalActionEditPage(
    BuildContext context, Goal goal, GoalAction goalAction) {
  Navigator.push(
      context,
      PageTransition(
        child: GoalActionEdit(
          goal: goal,
          goalAction: goalAction,
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
  GoalBloc _goalBloc;

  final _formKey = GlobalKey<FormState>();


  String _title;
  double _progressPercent;

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
          _buildSaveAction(),
        ],
      ),
      floatingActionButton: _createFloatingActionButton(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocListener<GoalBloc, GoalState>(
          bloc: _goalBloc,
          listener: (context, state) {
            if (state is GoalActionAdded ||
                state is GoalActionUpdated) {
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildGoalNameField(),
                        SizedBox(height: 8),
                        Divider(),
                        SizedBox(height: 8),
                        _buildTargetProgressField(),
                        SizedBox(height: 16),
                        Divider(),
                        _buildTimeField(),
                      ],
                    ),
                  ),
                  Divider(),
                  _buildGoalTaskField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createFloatingActionButton() {
    if (_isNewGoal) {
      return Container();
    }
    if (!_isReadOnly) {
      return Container();
    }
    if (_goal.status == GoalStatus.finished ||
        _goal.status == GoalStatus.expired) {
      return Container();
    }
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        setState(() {
          _isReadOnly = false;
          _title = '修改目标';
        });
      },
      child: Icon(
        Icons.edit,
      ),
    );
  }

  bool get _isNewGoal => widget.goal == null;

  bool _isNeedExitConfirm() {
    _updateGoalFromForm();
    if (_isNewGoal) {
      if (_goal.name != null && _goal.name.isNotEmpty) {
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

  Widget _buildGoalActionDeleteView(Goal goal, GoalAction goalAction) {
    if (_isReadOnly) {
      return Container(width: 8);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 32,
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Icon(
          Icons.remove_circle,
          color: Colors.red,
        ),
      ),
      onTap: () {
        setState(() {
          goal.goalActions.remove(goalAction);
        });
      },
    );
  }

  Widget _buildGoalActionItem(Goal goal, GoalAction goalAction) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: <Widget>[
          _buildGoalActionDeleteView(goal, goalAction),
          Expanded(
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.only(left: 0, top: 8, right: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      goalAction.action.name,
                      style: _fieldNameTextStyle(),
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          TypeToStr.goalActionStatusToStr(goalAction.status, context),
                          style: TextStyle(color: _captionColor(context)),
                        ),
                        SizedBox(width: 8),
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
                _showGoalActionEditPage(context, _goal, goalAction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGoalActionButton() {
    Color actionColor = Theme.of(context).primaryColorDark;
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.add_circle,
              color: actionColor,
            ),
            SizedBox(width: 8),
            Text(
              '添加新任务',
              style: _fieldNameTextStyle().copyWith(
                color: actionColor,
              ),
            ),
            /*
            Spacer(),
            Icon(Icons.chevron_right,
                color: actionColor,
            ),
             */
          ],
        ),
      ),
      onTap: () {
        _showGoalActionEditPage(context, _goal, null);
      },
    );
  }

  Widget _buildEmptyGoalActionItem() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      child: Text(
        '无任务',
        style: _fieldNameTextStyle().copyWith(color: _captionColor(context)),
      ),
    );
  }

  Widget _buildGoalAction() {
    final toDoItems = <Widget>[];
    for (GoalAction goalAction in _goal.goalActions) {
      toDoItems.add(_buildGoalActionItem(_goal, goalAction));
    }
    if (toDoItems.isEmpty) {
      toDoItems.add(_buildEmptyGoalActionItem());
    }
    if (!_isReadOnly) {
      toDoItems.add(_buildAddGoalActionButton());
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

  void _updateGoalFromForm() {
  }

  void _editGoal() {
    _updateGoalFromForm();
    if (_isNewGoal) {
      _goalBloc.dispatch(
        AddGoal(goal: _goal),
      );
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isReadOnly = true;
      });
      if (_goal.isContentSameWith(widget.goal)) {
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

  Widget _buildCheckAction() {
    return IconButton(
      icon: Icon(Icons.check),
      onPressed: () {
        if (_formKey.currentState.validate()) {
          _editGoal();
        }
      },
    );
  }

  Widget _buildSaveAction() {
    if (_isNewGoal) {
      return _buildCheckAction();
    }
    if (_goal.status == GoalStatus.finished ||
        _goal.status == GoalStatus.expired) {
      return Container();
    }
    if (_isReadOnly) {
      return Container();
    }
    return _buildCheckAction();
  }

  Color _captionColor(BuildContext context) {
    return Theme.of(context).textTheme.caption.color;
  }

  double _getProgressPercent() {
    if (_goal.progress == null || _goal.target == null || _goal.target == 0) {
      return 0.0;
    }
    double percent = _goal.progress / _goal.target;
    return percent;
  }

  String _getGoalProgressPercentStr(double percent) {
    return '${(percent * 100).toStringAsFixed(1)}%';
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

  Widget _buildGoalNameField() {
    return Material(
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
        child: UniqueCheckFormField(
          initialValue: _goal.name ?? '',
          textStyle: Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
          validator: (String text, bool isUnique) {
            if (text.isEmpty) {
              return '目标名称不能为空';
            }
            if (!isUnique && text != widget.goal?.name) {
              return '目标名称已经存在';
            }
            return null;
          },
          textChanged: _nameChanged,
          hintText: '输入目标名称',
          uniqueCheckCallback: (String text) {
            return _goalBloc.goalNameUniqueCheck(text);
          },
          autofocus: _isNewGoal,
          mutable: !_isReadOnly,
        ),
      ),
    );
  }

  Widget _buildTargetProgressField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
      child: Column(
        children: <Widget>[
          MyFormTextField(
            name: '目标值',
            inputHint: '输入目标值',
            value: _getNumDisplayStr(_goal.target),
            valueEditable: !_isReadOnly,
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
          SizedBox(height: 8),
          MyFormTextField(
            name: '当前进度值',
            inputHint: '输入当前进度值',
            value: _getNumDisplayStr(_goal.progress),
            valueEditable: !_isReadOnly,
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
          SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '完成百分比 ${_getGoalProgressPercentStr(_progressPercent)}',
                style: Theme.of(context).textTheme.caption,
              ),
              SizedBox(height: 16),
              LinearPercentIndicator(
                percent: _progressPercent > 1 ? 1 : _progressPercent,
                lineHeight: 10,
                backgroundColor: Colors.grey[300],
                linearStrokeCap: LinearStrokeCap.butt,
                padding: EdgeInsets.symmetric(horizontal: 0),
                progressColor: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
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
                  _goal.startDateTime = newDateTime;
                });
              },
              mutable: !_isReadOnly,
              initialDateTime: _goal.startDateTime,
              mode: CupertinoDatePickerMode.date,
              labelPadding: EdgeInsets.symmetric(horizontal: 16),
              valuePadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            SizedBox(height: 8),
            MyDatePickerFormField(
              labelName: '结束时间',
              onChanged: (DateTime newDateTime) {
                fieldState.didChange(null);
                setState(() {
                  _goal.stopDateTime = newDateTime;
                });
              },
              mutable: !_isReadOnly,
              initialDateTime: _goal.stopDateTime,
              mode: CupertinoDatePickerMode.date,
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
                name: '目标时长',
                value: '${_goal.duration.inDays} 天',
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
        if (_isNewGoal) {
          if (_goal.startTime <
              nowDate.millisecondsSinceEpoch) {
            return '开始时间必须在当前时间之后';
          }
        }
        if (_goal.startTime > _goal.stopTime) {
          return '开始时间必须早于结束时间';
        }
        if (_goal.stopTime - _goal.startTime <
            Duration(days: 3).inMilliseconds) {
          return '时长必须大于三天';
        }
        return null;
      },
    );
  }

  Widget _buildGoalTaskField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 0),
          child: Text(
            '任务列表',
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        _buildGoalAction(),
      ],
    );
  }

  TextStyle _fieldNameTextStyle() {
    return TextStyle(
      fontSize: 16,
    );
  }

}
