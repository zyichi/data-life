import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';

import 'package:data_life/views/title_form_field.dart';
import 'package:data_life/views/progress_target_form_field.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/item_picker_form_field.dart';

import 'package:data_life/models/activity.dart';


final howOftenOptions = [
  HowOften.onceMonth, HowOften.twiceMonth, HowOften.onceWeek, HowOften.twiceWeek,
  HowOften.threeTimesWeek, HowOften.fourTimesWeek, HowOften.fiveTimesWeek,
  HowOften.sixTimesWeek, HowOften.everyday,
];

final howLongOptions = [
  HowLong.fifteenMinutes, HowLong.thirtyMinutes, HowLong.oneHour, HowLong.twoHours,
  HowLong.halfDay, HowLong.wholeDay
];

final bestTimeOptions = [
  BestTime.morning, BestTime.afternoon, BestTime.evening, BestTime.anyTime,
];

String getHowOftenLiteral(BuildContext context, HowOften howOften) {
  switch (howOften) {
    case HowOften.onceMonth: return AppLocalizations.of(context).onceMonth;
    case HowOften.twiceMonth: return AppLocalizations.of(context).twiceMonth;
    case HowOften.onceWeek: return AppLocalizations.of(context).onceWeek;
    case HowOften.twiceWeek: return AppLocalizations.of(context).twiceWeek;
    case HowOften.threeTimesWeek: return AppLocalizations.of(context).threeTimesWeek;
    case HowOften.fourTimesWeek: return AppLocalizations.of(context).fourTimesWeek;
    case HowOften.fiveTimesWeek: return AppLocalizations.of(context).fiveTimesWeek;
    case HowOften.sixTimesWeek: return AppLocalizations.of(context).sixTimesWeek;
    case HowOften.everyday: return AppLocalizations.of(context).everyday;
    default: return null;
  }
}

String getHowLongLiteral(BuildContext context, HowLong howLong) {
  switch (howLong) {
    case HowLong.fifteenMinutes: return AppLocalizations.of(context).fifteenMinutes;
    case HowLong.thirtyMinutes: return AppLocalizations.of(context).thirtyMinutes;
    case HowLong.oneHour: return AppLocalizations.of(context).oneHour;
    case HowLong.twoHours: return AppLocalizations.of(context).twoHours;
    case HowLong.halfDay: return AppLocalizations.of(context).halfDay;
    case HowLong.wholeDay: return AppLocalizations.of(context).wholeDay;
    default: return null;
  }
}

String getBestTimeLiteral(BuildContext context, BestTime bestTime) {
  switch (bestTime) {
    case BestTime.morning: return AppLocalizations.of(context).morning;
    case BestTime.afternoon: return AppLocalizations.of(context).afternoon;
    case BestTime.evening: return AppLocalizations.of(context).evening;
    case BestTime.anyTime: return AppLocalizations.of(context).anyTime;
    default: return null;
  }
}

class ActionEdit extends StatefulWidget {
  static const routeName = '/actionEdit';
  final String title;

  const ActionEdit(this.title);

  @override
  ActionEditState createState() {
    return new ActionEditState();
  }
}

class ActionEditState extends State<ActionEdit> {
  final _formKey = GlobalKey<FormState>();
  String _title;
  DateTime _startDateTime;

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  void initState() {
    super.initState();

    _title = widget.title;
    final now = DateTime.now();
    _startDateTime = now;
  }

  void _titleChanged(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _title = text;
      });
    } else {
      setState(() {
        _title = widget.title;
      });
    }
  }

  void _targetChanged(num value) {}

  void _progressChanged(num value) {}

  Widget _createStartTimeWidget() {
    return DateTimePicker(
      labelText: AppLocalizations.of(context).startTime,
      initialDateTime: _startDateTime,
      selectDateTime: (value) {
        setState(() {
          _startDateTime = value;
        });
      },
    );
  }

  Widget _createDurationWidget() {
    final durationList = [
      '15 minutes',
      'one hour',
      'one day',
      'half month',
      'one month',
      'three month',
      'half year',
      'one year'
    ];

    return ItemPicker(
      labelText: 'Duration',
      items: durationList,
      defaultPicked: 0,
      onItemPicked: (value, index) {
      },
    );
  }

  Widget _createRepeatWidget() {
    final repeatList = [
      'Does not repeat',
    ];

    for (var howOften in howOftenOptions) {
      repeatList.add(getHowOftenLiteral(context, howOften));
    }

    return ItemPicker(
      labelText: 'Repeat',
      items: repeatList,
      defaultPicked: 0,
      onItemPicked: (value, index) {},
    );
  }

  Widget _createHowLongWidget() {
    final howLongList = <String>[];
    for (var howLong in howLongOptions) {
      howLongList.add(getHowLongLiteral(context, howLong));
    }

    return ItemPicker(
      labelText: 'How long',
      items: howLongList,
      defaultPicked: 0,
      onItemPicked: (value, index) {},
    );
  }

  Widget _createBestTimeWidget() {
    final bestTimeList = <String>[];
    for (var bestTime in bestTimeOptions) {
      bestTimeList.add(getBestTimeLiteral(context, bestTime));
    }

    return ItemPicker(
      labelText: 'Best time',
      items: bestTimeList,
      defaultPicked: 0,
      onItemPicked: (value, index) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {}
            },
            child: Text(
              AppLocalizations.of(context).save,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            children: <Widget>[
              TitleFormField(_titleChanged),
              Divider(),
              ProgressTarget(
                padding: EdgeInsets.symmetric(vertical: 16),
                progressChanged: _progressChanged,
                targetChanged: _targetChanged,
              ),
              Divider(),
              _createStartTimeWidget(),
              _createDurationWidget(),
              Divider(),
              _createRepeatWidget(),
              _createHowLongWidget(),
              _createBestTimeWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
