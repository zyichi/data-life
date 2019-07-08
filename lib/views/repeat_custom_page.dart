import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum RepeatEveryType {
  day,
  week,
  month,
  year,
}
enum MonthRepeatsOnType {
  day,
  week,
}

class _Repeat {
  RepeatEveryType repeatEveryType;
  int repeatEveryPeriod;
  List<int> repeatOn;
  int weekOfMonth;
}

Map<MonthRepeatsOnType, String> monthRepeatsOnTypeToName = {
  MonthRepeatsOnType.day: 'Day',
  MonthRepeatsOnType.week: 'Week',
};

List<RepeatEveryType> defaultRepeatEveryList = [
  RepeatEveryType.day,
  RepeatEveryType.week,
  RepeatEveryType.month,
  RepeatEveryType.year,
];

String _repeatEveryTypeToStr(RepeatEveryType t, context) {
  switch (t) {
    case RepeatEveryType.day:
      return 'day';
      break;
    case RepeatEveryType.week:
      return 'week';
      break;
    case RepeatEveryType.month:
      return 'month';
      break;
    case RepeatEveryType.year:
      return 'year';
      break;
  }
  return null;
}

class _RepeatEveryItem {
  final RepeatEveryType repeatEveryType;
  final String text;

  _RepeatEveryItem({this.repeatEveryType, this.text});
}

class RepeatCustomPage extends StatefulWidget {
  final DateTime startTime;

  RepeatCustomPage({this.startTime}) : assert(startTime != null);

  @override
  _RepeatCustomPageState createState() => _RepeatCustomPageState();
}

List<String> getWeekDays(String localeName) {
  DateFormat formatter = DateFormat(DateFormat.ABBR_WEEKDAY, localeName);
  return [
    DateTime(2000, 1, 3, 1),
    DateTime(2000, 1, 4, 1),
    DateTime(2000, 1, 5, 1),
    DateTime(2000, 1, 6, 1),
    DateTime(2000, 1, 7, 1),
    DateTime(2000, 1, 8, 1),
    DateTime(2000, 1, 9, 1)
  ].map((day) => formatter.format(day)).toList();
}

List<String> getMonthList(String localeName) {
  DateFormat formatter = DateFormat(DateFormat.ABBR_MONTH, localeName);
  return List.generate(12, (index) {
    return formatter.format(DateTime(2019, index + 1));
  });
}

String getWeekDayStr(int weekDay, String localeName) {
  return getWeekDays(localeName)[weekDay];
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

class _RepeatCustomPageState extends State<RepeatCustomPage> {
  List<_RepeatEveryItem> _repeatEveryItems;
  _RepeatEveryItem _repeatEveryItem;
  MonthRepeatsOnType _monthRepeatsOnType;
  final List<String> _weekSeqListOfMonth = [
    'First',
    'Second',
    'Third',
    'Fourth',
    'Last'
  ];
  String _weekSeq;
  _Repeat _repeat = _Repeat();
  TextEditingController _repeatEveryTextController = TextEditingController();
  String _repeatEveryErrorText;

  @override
  void initState() {
    super.initState();

    _repeat.repeatEveryType = RepeatEveryType.day;
    _repeat.repeatEveryPeriod = 1;
    _repeat.repeatOn = <int>[];
    _repeat.weekOfMonth = null;

    _repeatEveryItems =
        defaultRepeatEveryList.map<_RepeatEveryItem>((RepeatEveryType t) {
      return _RepeatEveryItem(
        repeatEveryType: t,
        text: _repeatEveryTypeToStr(t, context),
      );
    }).toList();
    _repeatEveryItem = _repeatEveryItems[0];

    _monthRepeatsOnType = MonthRepeatsOnType.day;
    _weekSeq = _weekSeqListOfMonth[0];
    _repeatEveryTextController.text = _repeat.repeatEveryPeriod.toString();
    _repeatEveryTextController.addListener(() {
      String value = _repeatEveryTextController.text;
      int n = int.tryParse(value);
      setState(() {
        if (n == null || n <= 0) {
          _repeatEveryErrorText =
          'Repeats every must be integer bigger than 0';
        } else {
          _repeatEveryErrorText = null;
        }
      });
    });
  }

  Widget _createRepeatsOnWidget() {
    List<String> weekDays =
        getWeekDays(Localizations.localeOf(context).toString());
    if (_repeatEveryItem.repeatEveryType == RepeatEveryType.week) {
      return MultiPick<String>(
        onChanged: (newValues) {
          print(newValues);
        },
        pickedValues: [weekDays[0], weekDays[2], weekDays[4]],
        values: weekDays,
        itemMaxWidth: 60,
        itemMaxHeight: 40,
      );
    }
    if (_repeatEveryItem.repeatEveryType == RepeatEveryType.month) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              InkWell(
                child: Row(
                  children: <Widget>[
                    Radio<MonthRepeatsOnType>(
                      value: MonthRepeatsOnType.day,
                      groupValue: _monthRepeatsOnType,
                      onChanged: (value) {
                        setState(() {
                          _monthRepeatsOnType = value;
                        });
                      },
                    ),
                    Text(monthRepeatsOnTypeToName[MonthRepeatsOnType.day]),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _monthRepeatsOnType = MonthRepeatsOnType.day;
                  });
                },
              ),
              InkWell(
                child: Row(
                  children: <Widget>[
                    Radio<MonthRepeatsOnType>(
                      value: MonthRepeatsOnType.week,
                      groupValue: _monthRepeatsOnType,
                      onChanged: (value) {
                        setState(() {
                          _monthRepeatsOnType = value;
                        });
                      },
                    ),
                    Text(monthRepeatsOnTypeToName[MonthRepeatsOnType.week]),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _monthRepeatsOnType = MonthRepeatsOnType.week;
                  });
                },
              ),
            ],
          ),
          _monthRepeatsOnType == MonthRepeatsOnType.day
              ? Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: MultiPick<int>(
                    onChanged: (newValues) {
                      print(newValues);
                    },
                    pickedValues: [1, 3, 5],
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
                        value: _weekSeq,
                        onChanged: (newValue) {
                          setState(() {
                            _weekSeq = newValue;
                          });
                        },
                        items: _weekSeqListOfMonth
                            .map<DropdownMenuItem<String>>((e) {
                          return DropdownMenuItem<String>(
                            child: Text('$e week of month'),
                            value: e,
                          );
                        }).toList(),
                      ),
                    ),
                    MultiPick<String>(
                      onChanged: (newValues) {
                        print(newValues);
                      },
                      pickedValues: [weekDays[0], weekDays[2], weekDays[4]],
                      values: weekDays,
                      itemMaxWidth: 60,
                      itemMaxHeight: 40,
                    ),
                  ],
                ),
        ],
      );
    }
    if (_repeatEveryItem.repeatEveryType == RepeatEveryType.year) {
      List<String> monthList =
          getMonthList(Localizations.localeOf(context).toString());
      return MultiPick<String>(
        onChanged: (newValues) {
          print(newValues);
        },
        pickedValues: [monthList[0], monthList[3]],
        values: monthList,
        itemMaxWidth: 60,
        itemMaxHeight: 40,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom recurrence'),
        centerTitle: true,
      ),
      body: Form(
          child: ListView(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 16),
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
                      child: DropdownButton<_RepeatEveryItem>(
                        value: _repeatEveryItem,
                        onChanged: (_RepeatEveryItem newValue) {
                          setState(() {
                            _repeatEveryItem = newValue;
                          });
                        },
                        items: _repeatEveryItems
                            .map<DropdownMenuItem<_RepeatEveryItem>>(
                                (_RepeatEveryItem value) {
                          return DropdownMenuItem<_RepeatEveryItem>(
                            value: value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                value.text,
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
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _repeatEveryItem.repeatEveryType != RepeatEveryType.day
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
      )),
    );
  }
}
