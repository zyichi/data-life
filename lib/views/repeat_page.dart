import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/repeat_custom_page.dart';
import 'package:data_life/models/time_types.dart';
import 'package:data_life/constants.dart';



String repeatTypeToStr(RepeatType t, DateTime time) {
  switch (t) {
    case RepeatType.custom:
      return 'Custom...';
      break;
    case RepeatType.oneTime:
      return 'One-time action';
      break;
    case RepeatType.daily:
      return 'Daily';
      break;
    case RepeatType.mondayToFriday:
      return 'Monday to Friday';
      break;
    case RepeatType.weekly:
      return 'Weekly (every ${DateFormat(DateFormat.WEEKDAY).format(time)})';
      break;
    case RepeatType.monthlyFirstWeekDay:
      return 'Monthly (first ${DateFormat(DateFormat.WEEKDAY).format(time)} of every month)';
      break;
    case RepeatType.monthlySameDay:
      return 'Monthly (on the same day each month)';
      break;
    case RepeatType.yearly:
      return 'Yearly (every ${DateFormat(DateFormat.MONTH_DAY).format(time)})';
      break;
  }
  return null;
}

class RepeatPage extends StatefulWidget {
  final DateTime startTime;
  final RepeatType repeatType;

  RepeatPage({this.startTime, this.repeatType})
      : assert(startTime != null),
        assert(repeatType != null);

  @override
  _RepeatPageState createState() => _RepeatPageState();
}

class _RepeatPageState extends State<RepeatPage> {
  RepeatType _repeatType;

  @override
  void initState() {
    super.initState();

    _repeatType = widget.repeatType;
  }

  List<Widget> _createRepeatTypeList() {
    return defaultRepeatTypeList.map((t) {
      String _repeatText = repeatTypeToStr(t, widget.startTime);
      return InkWell(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 8, top: 0, right: 16, bottom: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio<RepeatType>(
                value: t,
                groupValue: _repeatType,
                onChanged: (newValue) {
                  _repeatTypeChanged(newValue);
                },
              ),
              Text(
                _repeatText,
              ),
            ],
          ),
        ),
        onTap: () {
          _repeatTypeChanged(t);
        },
      );
    }).toList();
  }

  void _repeatTypeChanged(RepeatType t) {
    setState(() {
      _repeatType = t;
    });
    if (t == RepeatType.custom) {
      Navigator.push(
          context,
          PageTransition(
            child: RepeatCustomPage(
              startTime: widget.startTime,
            ),
            type: PageTransitionType.rightToLeft,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Repeat'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _createRepeatTypeList(),
        ),
      ),
    );
  }
}
