import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/repeat_custom_page.dart';

import 'package:data_life/models/repeat_types.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/constants.dart';



String repeatTypeToStr(RepeatType t, DateTime time) {
  switch (t) {
    case RepeatType.custom:
      return 'Custom...';
    case RepeatType.oneTime:
      return 'One-time action';
    case RepeatType.daily:
      return 'Daily';
    case RepeatType.mondayToFriday:
      return 'Monday to Friday';
    case RepeatType.weekly:
      return 'Weekly (every ${DateFormat(DateFormat.WEEKDAY).format(time)})';
    case RepeatType.monthlyFirstWeekDay:
      return 'Monthly (first ${DateFormat(DateFormat.WEEKDAY).format(time)} of every month)';
    case RepeatType.monthlySameDay:
      return 'Monthly (on the same day each month)';
    case RepeatType.yearly:
      return 'Yearly (every ${DateFormat(DateFormat.MONTH_DAY).format(time)})';
    default:
      return null;
  }
}

class RepeatPage extends StatefulWidget {
  final GoalAction goalAction;

  RepeatPage({this.goalAction})
      : assert(goalAction != null);

  @override
  _RepeatPageState createState() => _RepeatPageState();
}

class _RepeatPageState extends State<RepeatPage> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> _createRepeatTypeList() {
    return defaultRepeatTypeList.map((t) {
      String _repeatText = repeatTypeToStr(t, DateTime.fromMillisecondsSinceEpoch(widget.goalAction.startTime));
      return InkWell(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 8, top: 0, right: 16, bottom: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio<RepeatType>(
                value: t,
                groupValue: widget.goalAction.repeatType,
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
      widget.goalAction.repeatType = t;
    });
    if (t == RepeatType.custom) {
      Navigator.push(
          context,
          PageTransition(
            child: RepeatCustomPage(
              goalAction: widget.goalAction,
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
