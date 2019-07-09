import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:data_life/models/repeat_types.dart';
import 'package:data_life/models/goal_action.dart';


class _Repeat {
  RepeatEvery every;
  int everyStep;
  MonthRepeatOn monthRepeatOn;
  WeekdaySeqOfMonth weekdaySeqOfMonth;
  List<int> onList = <int>[];
}

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

String _monthRepeatOnToStr(MonthRepeatOn monthRepeatsOn, BuildContext context) {
  switch (monthRepeatsOn) {
    case MonthRepeatOn.day:
      return 'Day';
    case MonthRepeatOn.week:
      return 'Week';
    default:
      return null;
  }
}

String _repeatEveryToStr(RepeatEvery t, BuildContext context) {
  switch (t) {
    case RepeatEvery.day:
      return 'day';
    case RepeatEvery.week:
      return 'week';
    case RepeatEvery.month:
      return 'month';
    case RepeatEvery.year:
      return 'year';
    default:
      return null;
  }
}

String _weekdaySeqOfMonthToStr(WeekdaySeqOfMonth seq, context) {
  switch (seq) {
    case WeekdaySeqOfMonth.first:
      return 'First';
    case WeekdaySeqOfMonth.second:
      return 'Second';
    case WeekdaySeqOfMonth.third:
      return 'Third';
    case WeekdaySeqOfMonth.fourth:
      return 'Fourth';
    case WeekdaySeqOfMonth.last:
      return 'Last';
    default:
      return null;
  }
}

List<String> getWeekdayTextList(String localeName) {
  DateFormat formatter = DateFormat(DateFormat.ABBR_WEEKDAY, localeName);
  var l = [
    DateTime(2000, 1, 3, 1),
    DateTime(2000, 1, 4, 1),
    DateTime(2000, 1, 5, 1),
    DateTime(2000, 1, 6, 1),
    DateTime(2000, 1, 7, 1),
    DateTime(2000, 1, 8, 1),
    DateTime(2000, 1, 9, 1)
  ].map((day) => formatter.format(day)).toList();
  l.insert(0, null);
  return l;
}

List<String> getMonthTextList(String localeName) {
  DateFormat formatter = DateFormat(DateFormat.ABBR_MONTH, localeName);
  var l = List.generate(12, (index) {
    return formatter.format(DateTime(2019, index+1));
  });
  l.insert(0, null);
  return l;
}

String getWeekdayStr(int weekday, String localeName) {
  return getWeekdayTextList(localeName)[weekday];
}

class MultiPickItem<T> extends StatefulWidget {
  final T value;
  final double maxWidth;
  final double maxHeight;
  final bool selected;
  final ValueChanged<bool> onSelect;

  MultiPickItem(
      {this.value,
      this.maxWidth,
      this.maxHeight,
      this.selected = false,
      this.onSelect});

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
        color: _selected ? Colors.blue : Colors.grey[300],
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
        setState(() {
          _selected = !_selected;
        });
        widget.onSelect(_selected);
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
          onSelect: (selected) {
            if (selected) {
              pickedValues.add(value);
              onChanged(pickedValues);
            } else {
              pickedValues.remove(value);
              onChanged(pickedValues);
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
  final _repeat = _Repeat();
  var _weekRepeatOnList = <int>[];
  var _monthDayRepeatOnList = <int>[];
  var _monthWeekdayRepeatOnList = <int>[];
  var _yearRepeatOnList = <int>[];
  List<String> _weekdayTextList;
  List<String> _monthTextList;

  @override
  void initState() {
    super.initState();

    _repeat.every = widget.goalAction.repeatEvery;
    _repeat.everyStep = widget.goalAction.repeatEveryStep;
    _repeat.monthRepeatOn = widget.goalAction.monthRepeatOn;
    _repeat.weekdaySeqOfMonth = widget.goalAction.weekdaySeqOfMonth;

    // We cache repeat on list for each repeat every.
    DateTime startTime =
        DateTime.fromMillisecondsSinceEpoch(widget.goalAction.startTime);
    _weekRepeatOnList.add(startTime.weekday);
    _monthDayRepeatOnList.add(startTime.day);
    _monthWeekdayRepeatOnList.add(startTime.weekday);
    _yearRepeatOnList.add(startTime.month);
    if (widget.goalAction.repeatEvery == RepeatEvery.week) {
      _weekRepeatOnList = widget.goalAction.repeatOnList;
    }
    if (widget.goalAction.repeatEvery == RepeatEvery.month) {
      if (widget.goalAction.monthRepeatOn == MonthRepeatOn.day) {
        _monthDayRepeatOnList = widget.goalAction.repeatOnList;
      } else {
        _monthWeekdayRepeatOnList = widget.goalAction.repeatOnList;
      }
    }
    if (widget.goalAction.repeatEvery == RepeatEvery.year) {
      _yearRepeatOnList = widget.goalAction.repeatOnList;
    }

    _repeatEveryTextController.text = _repeat.everyStep.toString();
    _repeatEveryTextController.addListener(() {
      String value = _repeatEveryTextController.text;
      int n = int.tryParse(value);
      setState(() {
        if (n == null || n <= 0) {
          _repeatEveryErrorText = 'Repeats every must be integer bigger than 0';
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
                      groupValue: _repeat.monthRepeatOn,
                      onChanged: (value) {
                        setState(() {
                          _repeat.monthRepeatOn = value;
                        });
                      },
                    ),
                    Text(_monthRepeatOnToStr(MonthRepeatOn.day, context)),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _repeat.monthRepeatOn = MonthRepeatOn.day;
                  });
                },
              ),
              InkWell(
                child: Row(
                  children: <Widget>[
                    Radio<MonthRepeatOn>(
                      value: MonthRepeatOn.week,
                      groupValue: _repeat.monthRepeatOn,
                      onChanged: (value) {
                        setState(() {
                          _repeat.monthRepeatOn = value;
                        });
                      },
                    ),
                    Text(_monthRepeatOnToStr(MonthRepeatOn.week, context)),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _repeat.monthRepeatOn = MonthRepeatOn.week;
                  });
                },
              ),
            ],
          ),
          _repeat.monthRepeatOn == MonthRepeatOn.day
              ? Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: MultiPick<int>(
                    onChanged: (newValues) {
                      _monthDayRepeatOnList = newValues;
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
                        value: _repeat.weekdaySeqOfMonth,
                        onChanged: (newValue) {
                          setState(() {
                            _repeat.weekdaySeqOfMonth = newValue;
                          });
                        },
                        items: weekdaySeqOfMonthList
                            .map<DropdownMenuItem<WeekdaySeqOfMonth>>((e) {
                          return DropdownMenuItem<WeekdaySeqOfMonth>(
                            child:
                                Text('${_weekdaySeqOfMonthToStr(e, context)}'),
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

  Future<bool> _onWillPop() async {
    widget.goalAction.repeatEveryStep = _repeat.everyStep;
    widget.goalAction.repeatEvery = _repeat.every;
    widget.goalAction.monthRepeatOn = _repeat.monthRepeatOn;
    widget.goalAction.weekdaySeqOfMonth = _repeat.weekdaySeqOfMonth;
    if (widget.goalAction.repeatEvery == RepeatEvery.week) {
      widget.goalAction.repeatOnList = _weekRepeatOnList;
      widget.goalAction.monthRepeatOn = MonthRepeatOn.day;
    }
    if (widget.goalAction.repeatEvery == RepeatEvery.month) {
      if (widget.goalAction.monthRepeatOn == MonthRepeatOn.day) {
        widget.goalAction.repeatOnList = _monthDayRepeatOnList;
      } else {
        widget.goalAction.repeatOnList = _monthWeekdayRepeatOnList;
      }
    }
    if (widget.goalAction.repeatEvery == RepeatEvery.year) {
      widget.goalAction.repeatOnList = _yearRepeatOnList;
      widget.goalAction.monthRepeatOn = MonthRepeatOn.day;
    }
    if (widget.goalAction.repeatEvery == RepeatEvery.day) {
      widget.goalAction.repeatOnList = [];
      widget.goalAction.monthRepeatOn = MonthRepeatOn.day;
    }
    print('Repeat on list: ${widget.goalAction.repeatOnList}');
    return true;
  }

  String _createRepeatText() {
    if (_repeat.every == RepeatEvery.day) {
      String dayText = _repeat.everyStep == 1 ? 'day' : 'days';
      return 'Do action every ${_repeat.everyStep} $dayText';
    }
    if (_repeat.every == RepeatEvery.week) {
      _weekRepeatOnList.sort();
      List<String> weeks = _weekRepeatOnList.map((weekday) {
        return _weekdayTextList[weekday];
      }).toList();
      String weekText = _repeat.everyStep == 1 ? 'week' : '${_repeat.everyStep} weeks';
      return 'Do action every $weekText on ${weeks.join(', ')}';
    }
    if (_repeat.every == RepeatEvery.month) {
    }
    if (_repeat.every == RepeatEvery.year) {
      _yearRepeatOnList.sort();
      List<String> years = _yearRepeatOnList.map((month) {
        return _monthTextList[month];
      }).toList();
      DateTime d = DateTime.fromMillisecondsSinceEpoch(widget.goalAction.startTime);
      String yearText = _repeat.everyStep == 1 ? 'year' : '${_repeat.everyStep} years';
      return 'Do action every $yearText on ${years.join(', ')} ${d.day}';
    }
    return 'Not implemented';
  }

  @override
  Widget build(BuildContext context) {
    if (_weekdayTextList == null) {
      _weekdayTextList =
          getWeekdayTextList(Localizations.localeOf(context).toString());
    }
    if (_monthTextList == null) {
      _monthTextList =
          getMonthTextList(Localizations.localeOf(context).toString());
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
                              if (_repeat.every == RepeatEvery.week) {}
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
                                  _repeatEveryToStr(value, context),
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
              child: Text(_createRepeatText()),
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
