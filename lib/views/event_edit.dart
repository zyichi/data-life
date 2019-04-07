import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:data_life/models/event.dart';
import 'package:data_life/localizations.dart';
import 'package:data_life/blocs/goal_bloc.dart';
import 'package:data_life/services/event_service.dart';
import 'package:data_life/blocs/event_bloc.dart';
import 'package:data_life/life_db.dart';
import 'package:data_life/blocs/acitivity_hint_bloc.dart';
import 'package:data_life/services/activity_service.dart';
import 'package:data_life/models/activity.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/common_form_field.dart';


class _EventTitlePage extends StatefulWidget {
  final String title;

  _EventTitlePage({Key key, @required this.title}) : super(key: key);

  @override
  _EventTitlePageState createState() {
    return new _EventTitlePageState();
  }
}

class _EventTitlePageState extends State<_EventTitlePage> {
  final _titleController = TextEditingController();
  bool _needInitHint = true;
  ActivityHintsBloc _hintsBloc;
  ActivityService _activityService;

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService();
    _hintsBloc = ActivityHintsBloc(_activityService);
    _titleController.text = widget.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Widget _createHint(Activity activity) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(Icons.outlined_flag),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  activity.name,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'goal',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _titleController.text = activity.name;
          Navigator.pop(context, _titleController.text);
        });
      },
    );
  }

  Widget _createSuggestionWidget(GoalBloc goalBloc) {
    return Expanded(
      child: StreamBuilder(
        stream: _hintsBloc.hints,
        initialData: _hintsBloc.hints.value,
        builder: (context, snapshot) => ListView.builder(
              itemCount: (snapshot.data as List).length,
              itemBuilder: (context, index) {
                List<Activity> activities = snapshot.data;
                final activity = activities[index];
                return _createHint(activity);
              },
            ),
      ),
    );
  }

  Widget _createTitleTextField() {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Expanded(
          child: TextField(
            controller: _titleController,
            // focusNode: _focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
              suffixIcon: _titleController.text.isEmpty
                  ? null
                  : IconButton(
                      color: Colors.black45,
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _titleController.text = '';
                        });
                      },
                    ),
              hintText: AppLocalizations.of(context).enterEventTitleOrSelectOne,
            ),
            onChanged: (text) {
              _hintsBloc.query.add(text);
              setState(() {});
            },
            autofocus: true,
          ),
        ),
        IconButton(
          icon: Icon(Icons.done),
          onPressed: () {
            Navigator.pop(context, _titleController.text);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalBloc = GoalProvider.of(context);

    if (_needInitHint) {
      _needInitHint = false;
      _hintsBloc.query.add('');
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Hero(
              tag: 'eventTitleHero',
              child: Material(
                elevation: 4.0,
                child: _createTitleTextField(),
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
            _createSuggestionWidget(goalBloc),
          ],
        ),
      ),
    );
  }
}

class EventEdit extends StatefulWidget {
  final String title;

  const EventEdit({this.title});

  @override
  EventEditState createState() {
    return new EventEditState();
  }
}

class _SentimentSource {
  const _SentimentSource({this.icon, this.sentiment});

  final Icon icon;
  final Sentiment sentiment;
}

class EventEditState extends State<EventEdit> {
  DateTime _beginDate;
  TimeOfDay _beginTime;
  DateTime _endDate;
  TimeOfDay _endTime;
  double _sentimentIconSize = 48.0;
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _peopleController = TextEditingController();
  final _expendController = TextEditingController();
  Sentiment _selectedSentiment;
  final _feelingsController = TextEditingController();
  bool _showSentimentError = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _beginDate = now;
    _endDate = now;
    _beginTime = TimeOfDay(hour: now.hour, minute: now.minute);
    _endTime = TimeOfDay(hour: now.hour, minute: now.minute);
    _selectedSentiment = null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _peopleController.dispose();
    _expendController.dispose();
    _feelingsController.dispose();
    super.dispose();
  }

  bool needExitConfirm() {
    if (_titleController.text.isNotEmpty ||
        _locationController.text.isNotEmpty ||
        _expendController.text.isNotEmpty ||
        _feelingsController.text.isNotEmpty ||
        _selectedSentiment != null) {
      return true;
    }
    return false;
  }

  List<Widget> _createSentimentIcons() {
    final widgets = <Widget>[];
    final sentimentSources = [
      _SentimentSource(
        icon: Icon(Icons.sentiment_very_satisfied),
        sentiment: Sentiment.VerySatisfied,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_satisfied),
        sentiment: Sentiment.Satisfied,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_neutral),
        sentiment: Sentiment.Neutral,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_dissatisfied),
        sentiment: Sentiment.Dissatisfied,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_very_dissatisfied),
        sentiment: Sentiment.VeryDissatisfied,
      ),
    ];
    for (var source in sentimentSources) {
      var iconButton = IconButton(
        iconSize: _sentimentIconSize,
        icon: source.icon,
        onPressed: () {
          setState(() {
            _showSentimentError = false;
            _selectedSentiment = source.sentiment;
          });
        },
        color: _selectedSentiment == source.sentiment
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      );
      widgets.add(iconButton);
    }
    return widgets;
  }

  num parseCost(String cost) {
    var value = num.tryParse(cost);
    return value ?? 0.0;
  }

  int getTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute)
        .millisecondsSinceEpoch;
  }

  void _saveEvent() async {
    final event = Event();
    event.location = _locationController.text;
    event.people = json.encode({
      EventTable.columnPeople: ['丫宝', '我']
    });
    event.sentiment = _selectedSentiment;
    event.beginTime = getTime(_beginDate, _beginTime);
    event.endTime = getTime(_endDate, _endTime);
    event.cost = parseCost(_expendController.text);
    event.details = _feelingsController.text;
    event.createTime = DateTime.now().millisecondsSinceEpoch;
    if (_titleController.text.isNotEmpty && event.sentiment != null) {
      final eventService = EventService();
      await eventService.insert(event);
      if (event.id != null) {
        EventProvider.of(context).invalid.add(true);
        print('_saveEvent success: ${event.toMap()}');
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!needExitConfirm()) {
      return true;
    }

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                AppLocalizations.of(context).discardNewEvent,
                style: dialogTextStyle,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(AppLocalizations.of(context).keepEditing),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text(AppLocalizations.of(context).discard),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  Widget _createTitleFormField() {
    return InkWell(
      child: Hero(
        tag: 'eventTitleHero',
        child: Material(
          child: Container(
            padding: EdgeInsets.only(left: 16.0),
            color: Colors.transparent,
            child: IgnorePointer(
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).enterTitle,
                  border: InputBorder.none,
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterEventName;
                  }
                },
                style:
                    Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
              ),
            ),
          ),
        ),
      ),
      onTap: () async {
        final String result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) {
                  return _EventTitlePage(
                    title: _titleController.text,
                  );
                },
                fullscreenDialog: true));
        setState(() {
          _titleController.text = result;
        });
      },
    );
  }

  Widget _createLocationFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
      child: TextInputFormField(
        labelText: AppLocalizations.of(context).location,
        hintText: AppLocalizations.of(context).enterLocation,
        controller: _locationController,
      ),
    );
  }

  Widget _createPeopleFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
      child: TextInputFormField(
        labelText: AppLocalizations.of(context).people,
        hintText: AppLocalizations.of(context).enterPeople,
        controller: _peopleController,
      ),
    );
  }

  Widget _createBeginTimeField() {
    return DateTimePicker(
      lableText: AppLocalizations.of(context).begin,
      selectedDate: _beginDate,
      selectedTime: _beginTime,
      selectDate: (value) {
        setState(() {
          _beginDate = value;
        });
      },
      selectTime: (value) {
        setState(() {
          _beginTime = value;
        });
      },
    );
  }

  Widget _createEndTimeField() {
    return DateTimePicker(
      lableText: AppLocalizations.of(context).end,
      selectedDate: _endDate,
      selectedTime: _endTime,
      selectDate: (value) {
        setState(() {
          _endDate = value;
        });
      },
      selectTime: (value) {
        setState(() {
          _endTime = value;
        });
      },
    );
  }

  Widget _createExpendFormField() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 16.0),
      child: TextInputFormField(
        labelText: '花费 (单位: ${AppLocalizations.of(context).currencyName})',
        hintText: AppLocalizations.of(context).enterSpend,
        controller: _expendController,
      ),
    );
  }

  Widget _createSentimentFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).sentiment,
          border: InputBorder.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _createSentimentIcons(),
            ),
            _showSentimentError
                ? Text(
                    AppLocalizations.of(context).selectSentiment,
                    style: TextStyle(color: Colors.red),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _createFeelingsFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 16.0),
      child: TextInputFormField(
        labelText: AppLocalizations.of(context).detail,
        hintText: AppLocalizations.of(context).enterEventDetail,
        maxLines: 4,
        controller: _feelingsController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              if (_formKey.currentState.validate()) {
                if (_selectedSentiment == null) {
                  setState(() {
                    _showSentimentError = true;
                  });
                } else {
                  _saveEvent();
                  Navigator.of(context).pop();
                }
              }
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
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: <Widget>[
              _createTitleFormField(),
              Divider(),
              SizedBox(
                height: 8.0,
              ),
              _createLocationFormField(),
              _createPeopleFormField(),
              _createBeginTimeField(),
              _createEndTimeField(),
              SizedBox(
                height: 16.0,
              ),
              Divider(),
              _createExpendFormField(),
              Divider(),
              SizedBox(
                height: 8.0,
              ),
              _createSentimentFormField(),
              Divider(),
              _createFeelingsFormField(),
            ],
          ),
        ),
      ),
    );
  }
}
