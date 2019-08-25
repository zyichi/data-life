import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/repeat_custom_page.dart';
import 'package:data_life/views/type_to_str.dart';

import 'package:data_life/models/repeat_types.dart';
import 'package:data_life/models/goal_action.dart';

import 'package:data_life/constants.dart';

class RepeatPage extends StatefulWidget {
  final GoalAction goalAction;
  final Repeat customRepeat;

  RepeatPage({this.goalAction, this.customRepeat}) : assert(goalAction != null);

  @override
  _RepeatPageState createState() => _RepeatPageState();
}

class _RepeatPageState extends State<RepeatPage> {
  Repeat _customRepeat;

  @override
  void initState() {
    if (widget.goalAction.repeatType == RepeatType.custom) {
      _customRepeat = widget.goalAction.getRepeat();
    } else {
      _customRepeat = widget.customRepeat;
    }
    super.initState();
  }

  List<Widget> _createRepeatTypeList() {
    return defaultRepeatTypeList.map((t) {
      String _repeatText;
      if (t == RepeatType.custom) {
        if (_customRepeat != null) {
          _repeatText = TypeToStr.repeatToReadableText(_customRepeat, context);
          _repeatText = 'Custom ($_repeatText)';
        } else {
          _repeatText = 'Custom...';
        }
      } else {
        var repeat = Repeat.buildRepeat(t,
            DateTime.fromMillisecondsSinceEpoch(widget.goalAction.startTime));
        _repeatText = TypeToStr.repeatToReadableText(repeat, context);
      }
      return InkWell(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 0, right: 16, bottom: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Radio<RepeatType>(
                value: t,
                groupValue: widget.goalAction.repeatType,
                onChanged: (newValue) {
                  _repeatTypeChanged(newValue);
                },
                activeColor: Theme.of(context).primaryColorDark,
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

  void _repeatTypeChanged(RepeatType t) async {
    setState(() {
      widget.goalAction.repeatType = t;
    });
    if (t == RepeatType.custom) {
      await Navigator.push(
          context,
          PageTransition(
            child: RepeatCustomPage(
              goalAction: widget.goalAction,
            ),
            type: PageTransitionType.rightToLeft,
          ));
      setState(() {
        _customRepeat = widget.goalAction.getRepeat();
      });
    } else {
      widget.goalAction.setRepeat(Repeat.buildRepeat(
          t, DateTime.fromMillisecondsSinceEpoch(widget.goalAction.startTime)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 40,
          ),
          onPressed: () {
            Navigator.pop(context, _customRepeat);
          },
        ),
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
