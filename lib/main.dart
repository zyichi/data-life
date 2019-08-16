import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amap/amap.dart';

import 'package:data_life/views/splash_page.dart';
import 'package:data_life/views/home_page.dart';

import 'package:data_life/repositories/moment_repository.dart';
import 'package:data_life/repositories/moment_provider.dart';
import 'package:data_life/repositories/goal_provider.dart';
import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/todo_provider.dart';
import 'package:data_life/repositories/todo_repository.dart';
import 'package:data_life/repositories/contact_provider.dart';
import 'package:data_life/repositories/contact_repository.dart';
import 'package:data_life/repositories/location_provider.dart';
import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/repositories/action_provider.dart';
import 'package:data_life/repositories/action_repository.dart';

import 'package:data_life/blocs/moment_bloc.dart';
import 'package:data_life/blocs/contact_bloc.dart';
import 'package:data_life/blocs/location_bloc.dart';
import 'package:data_life/blocs/goal_bloc.dart';
import 'package:data_life/blocs/db_bloc.dart';
import 'package:data_life/blocs/todo_bloc.dart';
import 'package:data_life/blocs/theme_bloc.dart';
import 'package:data_life/blocs/action_bloc.dart';
import 'package:data_life/blocs/timer_bloc.dart';

import 'package:data_life/paging/page_bloc.dart';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/models/todo.dart';
import 'package:data_life/models/action.dart';

import 'localizations.dart';

void main() async {
  await AMap().init('1624c8484217cdfdf2fdf38ecdd365ab');

  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DbBloc _dbBloc = DbBloc();
  ThemeBloc _themeBloc = ThemeBloc();

  MomentRepository _momentRepository;
  GoalRepository _goalRepository;
  TodoRepository _todoRepository;
  ContactRepository _contactRepository;
  LocationRepository _locationRepository;
  ActionRepository _actionRepository;

  PageBloc<Moment> _momentListBloc;
  PageBloc<Goal> _goalListBloc;
  PageBloc<Todo> _todoListBloc;
  PageBloc<Contact> _contactListBloc;
  PageBloc<Location> _locationListBloc;
  PageBloc<MyAction> _actionListBloc;

  MomentBloc _momentBloc;
  ContactBloc _contactBloc;
  LocationBloc _locationBloc;
  GoalBloc _goalBloc;
  TodoBloc _todoBloc;
  ActionBloc _actionBloc;
  TimerBloc _timerBloc;

  @override
  void initState() {
    super.initState();

    _momentRepository = MomentRepository(MomentProvider());
    _goalRepository = GoalRepository(GoalProvider());
    _todoRepository = TodoRepository(TodoProvider());
    _contactRepository = ContactRepository(ContactProvider());
    _locationRepository = LocationRepository(LocationProvider());
    _actionRepository = ActionRepository(ActionProvider());

    _momentListBloc = PageBloc<Moment>(pageRepository: _momentRepository);
    _goalListBloc = PageBloc<Goal>(pageRepository: _goalRepository);
    _todoListBloc = PageBloc<Todo>(pageRepository: _todoRepository);
    _contactListBloc = PageBloc<Contact>(pageRepository: _contactRepository);
    _locationListBloc = PageBloc<Location>(pageRepository: _locationRepository);
    _actionListBloc = PageBloc<MyAction>(pageRepository: _actionRepository);

    _momentBloc = MomentBloc(
      momentRepository: _momentRepository,
      actionRepository: _actionRepository,
      locationRepository: _locationRepository,
      contactRepository: _contactRepository,
      todoRepository: _todoRepository,
      goalRepository: _goalRepository,
    );
    _contactBloc = ContactBloc(
      locationRepository: _locationRepository,
      contactRepository: _contactRepository,
    );
    _locationBloc =
        LocationBloc(locationRepository: _locationRepository);
    _goalBloc = GoalBloc(
      goalRepository: _goalRepository,
      actionRepository: _actionRepository,
      momentRepository: _momentRepository,
    );
    _actionBloc = ActionBloc(actionRepository: _actionRepository);
    _todoBloc = TodoBloc(
      todoRepository: _todoRepository,
      goalRepository: _goalRepository,
    );

    _timerBloc = TimerBloc(ticker: Ticker());

    _dbBloc.dispatch(OpenDb());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DbBloc>(builder: (BuildContext context) => _dbBloc),
        BlocProvider<TodoBloc>(builder: (BuildContext context) => _todoBloc),
        BlocProvider<ThemeBloc>(builder: (BuildContext context) => _themeBloc),
        BlocProvider<MomentBloc>(builder: (BuildContext context) => _momentBloc),
        BlocProvider<GoalBloc>(builder: (BuildContext context) => _goalBloc),
        BlocProvider<ContactBloc>(builder: (BuildContext context) => _contactBloc),
        BlocProvider<LocationBloc>(builder: (BuildContext context) => _locationBloc),
        BlocProvider<ActionBloc>(builder: (BuildContext context) => _actionBloc),
        BlocProvider<TimerBloc>(builder: (BuildContext context) => _timerBloc),
        BlocProvider<PageBloc<Moment>>(builder: (BuildContext context) => _momentListBloc),
        BlocProvider<PageBloc<Goal>>(builder: (BuildContext context) => _goalListBloc),
        BlocProvider<PageBloc<Todo>>(builder: (BuildContext context) => _todoListBloc),
        BlocProvider<PageBloc<Contact>>(builder: (BuildContext context) => _contactListBloc),
        BlocProvider<PageBloc<Location>>(builder: (BuildContext context) => _locationListBloc),
        BlocProvider<PageBloc<MyAction>>(builder: (BuildContext context) => _actionListBloc),
      ],
      child: BlocBuilder(
        bloc: _themeBloc,
        builder: (_, ThemeState themeState) {
          return MaterialApp(
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
            theme: themeState.theme,
            home: BlocBuilder(
              bloc: _dbBloc,
              builder: (BuildContext context, DbState state) {
                if (state is DbClosed) {
                  return SplashPage();
                }
                if (state is DbOpen) {
                  _todoBloc.dispatch(CreateTodayTodo());
                  _goalBloc.dispatch(UpdateGoalStatus());
                  return HomePage(title: 'home');
                }
                return null;
              },
            ),
          );
        },
      ),
    );
  }
}
