import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:data_life/views/splash_page.dart';
import 'package:data_life/blocs/goal_bloc.dart';
import 'package:data_life/blocs/event_bloc.dart';
import 'package:data_life/services/goal_service.dart';
import 'package:data_life/services/event_service.dart';
import 'package:data_life/life_db.dart';
import 'package:data_life/services/activity_service.dart';
import 'package:data_life/models/event.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/activity.dart';
import 'package:data_life/blocs/db_bloc.dart';
import 'localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_life/views/x_home_page.dart';

void main() {
  final goalService = GoalService();
  final goalBloc = GoalBloc(goalService);

  final eventService = EventService();
  final eventBloc = EventBloc(eventService);

  goalBloc.invalid.add(true);
  eventBloc.invalid.add(true);

  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DbBloc _dbBloc = DbBloc();

  @override
  void initState() {
    super.initState();
    _dbBloc.dispatch(OpenDb());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<DbBloc>(
          bloc: _dbBloc,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          const AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        onGenerateTitle: (context) => AppLocalizations.of(context).appName,
        supportedLocales: [
          const Locale('en', ''),
          const Locale('zh', ''),
        ],
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green[500],
          accentColor: Colors.deepOrange[500],
          // canvasColor: Colors.white,
        ),
        home: BlocBuilder(
          bloc: _dbBloc,
          builder: (BuildContext context, DbState state) {
            if (state is DbClosed) {
              return SplashPage();
            }
            if (state is DbOpen) {
              return XHomePage();
            }
          },
        ),
      ),
    );
  }
}

class _MyApp extends StatelessWidget {
  final GoalBloc goalBloc;
  final EventBloc eventBloc;

  _MyApp(this.goalBloc, this.eventBloc);

  Map<String, WidgetBuilder> _buildRoutes() {
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return GoalProvider(
      goalBloc: goalBloc,
      child: EventProvider(
        eventBloc: eventBloc,
        child: MaterialApp(
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          supportedLocales: [
            const Locale('en', ''),
            const Locale('zh', ''),
          ],
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColor: Colors.green[500],
            accentColor: Colors.deepOrange[500],
            // canvasColor: Colors.white,
          ),
          home: SplashPage(),
          routes: _buildRoutes(),
        ),
      ),
    );
  }
}

Future initDatabase() async {
  // await LifeDb.delete();
  await LifeDb.open();
  _createTestData();
}

void _createTestData() async {
  final _goals = await _createTestGoals();
  final _activities = await _createTestActivities(_goals);
  final _ = await _createTestEvents(_activities);
}

final _random = Random();
T _randomItem<T>(List<T> items) {
  return items[_random.nextInt(items.length)];
}

Future<List<Event>> _createTestEvents(List<Activity> activities) async {
  final _events = <Event>[];
  final _eventService = EventService();
  int now = DateTime.now().millisecondsSinceEpoch;
  for (var i = 0; i < 111; i++) {
    var eventNum = _random.nextInt(8);
    for (var i = 0; i < eventNum; i++) {
      final event = Event();
      var activity = _randomItem<Activity>(activities);
      event.activityId = activity.id;
      event.location = '家';
      event.people = '丫宝，我';
      event.cost = 0;
      event.beginTime = now;
      event.endTime = now + 30 * 1000 * 60;
      event.sentiment = Sentiment.VerySatisfied;
      event.createTime = now;
      await _eventService.insert(event);
    }
  }
  return _events;
}

Future<List<Activity>> _createTestActivities(List<Goal> goals) async {
  final _activityService = ActivityService();
  final _activities = <Activity>[];
  int now = DateTime.now().millisecondsSinceEpoch;
  for (var goal in goals) {
    var toDoNum = _random.nextInt(4);
    for (var i = 0; i < toDoNum; i++) {
      final todo = Activity();
      todo.goalId = goal.id;
      todo.name = 'To-Do $i for goal ${goal.name}';
      todo.target = 100;
      todo.alreadyCompleted = 0;
      todo.timeSpent = 0;
      todo.howOften = HowOften.threeTimesWeek;
      todo.howLong = HowLong.thirtyMinutes;
      todo.bestTime = BestTime.anyTime;
      todo.timeSpent = i * 15 * 60 * 60;
      todo.lastActiveTime = now;
      todo.createTime = now;
      await _activityService.insert(todo);
      _activities.add(todo);
    }
  }
  return _activities;
}

Future<List<Goal>> _createTestGoals() async {
  final _goalService = GoalService();
  final _goals = <Goal>[];
  for (var i = 0; i < 8; i++) {
    var goal = Goal();
    goal.name = 'Goal $i';
    goal.target = 100;
    goal.alreadyDone = 0;
    int now = DateTime.now().millisecondsSinceEpoch;
    goal.lastActiveTime = now;
    goal.createTime = now;
    await _goalService.insert(goal);
    _goals.add(goal);
  }
  return _goals;
}
