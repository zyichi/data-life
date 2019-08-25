import 'package:flutter/material.dart';

import 'package:data_life/models/repeat_types.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/utils/time_util.dart';
import 'package:data_life/views/type_to_str.dart';


List<RepeatEvery> defaultRepeatEveryList = [
  RepeatEvery.day,
  RepeatEvery.week,
  RepeatEvery.month,
  RepeatEvery.year,
];
List<WeekdaySeqOfMonth> weekdaySeqOfMonthList = [
  WeekdaySeqOfMonth.first,
  WeekdaySeqOfMonth.second,
  WeekdaySeqOfMonth.third,
  WeekdaySeqOfMonth.fourth,
  WeekdaySeqOfMonth.last,
];


typedef PickConfirm = bool Function(bool pick);
class MultiPickItem<T> extends StatefulWidget {
  final T value;
  final double maxWidth;
  final double maxHeight;
  final bool selected;
  final PickConfirm pickConfirm;

  MultiPickItem(
      {this.value,
      this.maxWidth,
      this.maxHeight,
      this.selected = false,
      this.pickConfirm});

  @override
  _MultiPickItemState createState() => _MultiPickItemState();
}

class _MultiPickItemState extends State<MultiPickItem> {
  bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: widget.maxWidth,
        height: widget.maxHeight,
        color: _selected ? Colors.green : Colors.grey[300],
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
            child: Text(
              widget.value.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.body1.copyWith(
                    color: _selected ? Colors.white : Colors.black,
                  ),
            ),
          ),
        ),
      ),
      onTap: () {
        bool confirmed = widget.pickConfirm(!_selected);
        setState(() {
          _selected = confirmed;
        });
      },
    );
  }
}

class MultiPick<T> extends StatelessWidget {
  final List<T> values;
  final List<T> pickedValues;
  final ValueChanged<List<T>> onChanged;
  final double itemMaxWidth;
  final double itemMaxHeight;

  MultiPick(
      {Key key,
      this.values,
      this.pickedValues,
      this.onChanged,
      this.itemMaxWidth,
      this.itemMaxHeight})
      : assert(values != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map<MultiPickItem<T>>((T value) {
        return MultiPickItem<T>(
          maxWidth: itemMaxWidth,
          maxHeight: itemMaxHeight,
          pickConfirm: (selected) {
            if (selected) {
              pickedValues.add(value);
              onChanged(pickedValues);
              return true;
            } else {
              // At least on item be picked.
              if (pickedValues.length > 1) {
                pickedValues.remove(value);
                onChanged(pickedValues);
                return false;
              } else {
                return true;
              }
            }
          },
          value: value,
          selected: pickedValues.contains(value),
        );
      }).toList(),
    );
  }
}

class RepeatCustomPage extends StatefulWidget {
  final GoalAction goalAction;

  RepeatCustomPage({this.goalAction}) : assert(goalAction != null);

  @override
  _RepeatCustomPageState createState() => _RepeatCustomPageState();
}

class _RepeatCustomPageState extends State<RepeatCustomPage> {
  final _repeatEveryTextController = TextEditingController();
  String _repeatEveryErrorText;
  Repeat _repeat;
  var _weekRepeatOnList = <int>[];
  var _monthDayRepeatOnList = <int>[];
  var _monthWeekdayRepeatOnList = <int>[];
  var _yearRepeatOnList = <int>[];
  List<String> _weekdayTextList;
  List<String> _monthTextList;
  MonthRepeatOn _monthRepeatOn;
  WeekdaySeqOfMonth _weekdaySeqOfMonth;

  @override
  void initState() {
    super.initState();

    _repeat = widget.goalAction.getRepeat();
    assert(_repeat.type == RepeatType.custom);

    // We cache repeat on list for each repeat every.
    _weekRepeatOnList.add(_repeat.startTime.weekday);
    _monthDayRepeatOnList.add(_repeat.startTime.day);
    _monthWeekdayRepeatOnList.add(_repeat.startTime.weekday);
    _yearRepeatOnList.add(_repeat.startTime.month);
    if (_repeat.every == RepeatEvery.week) {
      _weekRepeatOnList = _repeat.onList;
    }
    if (_repeat.every == RepeatEvery.month) {
      _monthRepeatOn = _repeat.monthRepeatOn;
      if (_monthRepeatOn == MonthRepeatOn.day) {
        _monthDayRepeatOnList = _repeat.onList;
      } else {
        _weekdaySeqOfMonth = _repeat.weekdaySeqOfMonth;
        _monthWeekdayRepeatOnList = _repeat.onList;
      }
    } else {
      _repeat.monthRepeatOn = null;
      _repeat.weekdaySeqOfMonth = null;
      _monthRepeatOn = MonthRepeatOn.day;
      _weekdaySeqOfMonth = TimeUtil.getWeekdaySeqOfMonth(_repeat.startTime);
    }
    if (_repeat.every == RepeatEvery.year) {
      _yearRepeatOnList = _repeat.onList;
    }

    _repeatEveryTextController.text = _repeat.everyStep.toString();
    _repeatEveryTextController.addListener(() {
      String value = _repeatEveryTextController.text;
      int n = int.tryParse(value);
      setState(() {
        if (n == null) {
          _repeatEveryErrorText = 'Repeat every must be integer';
          _repeat.everyStep = 1;
        } else if (n <= 0) {
          _repeatEveryErrorText = 'Repeat every must bigger than 0';
          _repeat.everyStep = 1;
        } else {
          _repeatEveryErrorText = null;
          _repeat.everyStep = n;
        }
      });
    });
  }

  Widget _weekdayPick(List<int> picked) {
    return MultiPick<String>(
      onChanged: (newValues) {
        setState(() {
          picked.clear();
          picked.addAll(newValues.map<int>((value) {
            return _weekdayTextList.indexOf(value);
          }).toList());
        });
      },
      pickedValues: picked.map((int repeatOn) {
        return _weekdayTextList[repeatOn];
      }).toList(),
      values: _weekdayTextList.sublist(1),
      itemMaxWidth: 60,
      itemMaxHeight: 40,
    );
  }

  Widget _createRepeatsOnWidget() {
    if (_repeat.every == RepeatEvery.week) {
      return _weekdayPick(_weekRepeatOnList);
    }
    if (_repeat.every == RepeatEvery.month) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              InkWell(
                child: Row(
                  children: <Widget>[
                    Radio<MonthRepeatOn>(
                      value: MonthRepeatOn.day,
                      groupValue: _monthRepeatOn,
                      onChanged: (value) {
                        setState(() {
                          _monthRepeatOn = value;
                        });
                      },
                    ),
                    Text(TypeToStr.monthRepeatOnToStr(MonthRepeatOn.day, context)),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _monthRepeatOn = MonthRepeatOn.day;
                  });
                },
              ),
              InkWell(
                child: Row(
                  children: <Widget>[
                    Radio<MonthRepeatOn>(
                      value: MonthRepeatOn.week,
                      groupValue: _monthRepeatOn,
                      onChanged: (value) {
                        setState(() {
                          _monthRepeatOn = value;
                        });
                      },
                    ),
                    Text(TypeToStr.monthRepeatOnToStr(MonthRepeatOn.week, context)),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _monthRepeatOn = MonthRepeatOn.week;
                  });
                },
              ),
            ],
          ),
          _monthRepeatOn == MonthRepeatOn.day
              ? Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: MultiPick<int>(
                    onChanged: (newValues) {
                      setState(() {
                        _monthDayRepeatOnList = newValues;
                      });
                    },
                    pickedValues: _monthDayRepeatOnList,
                    values: List.generate(31, (index) => index + 1),
                    itemMaxWidth: 40,
                    itemMaxHeight: 40,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _weekdaySeqOfMonth,
                        onChanged: (newValue) {
                          setState(() {
                            _weekdaySeqOfMonth = newValue;
                          });
                        },
                        items: weekdaySeqOfMonthList
                            .map<DropdownMenuItem<WeekdaySeqOfMonth>>((e) {
                          return DropdownMenuItem<WeekdaySeqOfMonth>(
                            child:
                                Text('${TypeToStr.weekdaySeqOfMonthToStr(e, context)}'),
                            value: e,
                          );
                        }).toList(),
                      ),
                    ),
                    _weekdayPick(_monthWeekdayRepeatOnList),
                  ],
                ),
        ],
      );
    }
    if (_repeat.every == RepeatEvery.year) {
      return MultiPick<String>(
        onChanged: (newValues) {
          setState(() {
            _yearRepeatOnList.clear();
            _yearRepeatOnList.addAll(newValues.map((monthText) {
              return _monthTextList.indexOf(monthText);
            }).toList());
          });
        },
        pickedValues: _yearRepeatOnList.map((month) {
          return _monthTextList[month];
        }).toList(),
        values: _monthTextList.sublist(1),
        itemMaxWidth: 60,
        itemMaxHeight: 40,
      );
    }
    return Container();
  }

  void _updateRepeat() {
    if (_repeat.every == RepeatEvery.day) {
      _repeat.onList = [];
    }
    if (_repeat.every == RepeatEvery.week) {
      _repeat.onList = _weekRepeatOnList;
    }
    if (_repeat.every == RepeatEvery.month) {
      _repeat.monthRepeatOn = _monthRepeatOn;
      if (_repeat.monthRepeatOn == MonthRepeatOn.day) {
        _repeat.onList = _monthDayRepeatOnList;
      } else {
        _repeat.weekdaySeqOfMonth = _weekdaySeqOfMonth;
        _repeat.onList = _monthWeekdayRepeatOnList;
      }
    }
    if (_repeat.every == RepeatEvery.year) {
      _repeat.onList = _yearRepeatOnList;
    }
    _repeat.onList.sort();
  }

  Future<bool> _onWillPop() async {
    _updateRepeat();
    widget.goalAction.setRepeat(_repeat);
    return true;
  }

  String _createRepeatReadableText() {
    _updateRepeat();
    return TypeToStr.repeatToReadableText(_repeat, context);
  }

  @override
  Widget build(BuildContext context) {
    if (_weekdayTextList == null) {
      _weekdayTextList =
          TimeUtil.getWeekdayTextList(Localizations.localeOf(context).toString());
    }
    if (_monthTextList == null) {
      _monthTextList =
          TimeUtil.getMonthTextList(Localizations.localeOf(context).toString());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom recurrence'),
        centerTitle: true,
      ),
      body: Form(
        onWillPop: _onWillPop,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, top: 24, right: 16, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Repeats every',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 60,
                        child: Center(
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            keyboardType:
                                TextInputType.numberWithOptions(signed: true),
                            decoration: InputDecoration(),
                            style: Theme.of(context).textTheme.subhead,
                            controller: _repeatEveryTextController,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<RepeatEvery>(
                          value: _repeat.every,
                          onChanged: (RepeatEvery newValue) {
                            setState(() {
                              _repeat.every = newValue;
                            });
                          },
                          items: defaultRepeatEveryList
                              .map<DropdownMenuItem<RepeatEvery>>(
                                  (RepeatEvery value) {
                            return DropdownMenuItem<RepeatEvery>(
                              value: value,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  TypeToStr.repeatEveryToStr(value, context),
                                  style: Theme.of(context).textTheme.subhead,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _repeatEveryErrorText != null
                      ? Text(
                          _repeatEveryErrorText,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('Do action ${_createRepeatReadableText()}'),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _repeat.every != RepeatEvery.day
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Repeats on',
                              style: Theme.of(context).textTheme.subhead,
                            ),
                            SizedBox(height: 16),
                            _createRepeatsOnWidget(),
                          ],
                        ),
                      ],
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
