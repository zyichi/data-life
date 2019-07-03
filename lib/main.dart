import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:amap/amap.dart';

import 'package:data_life/views/splash_page.dart';
import 'package:data_life/views/home_page.dart';

import 'package:data_life/repositories/moment_repository.dart';
import 'package:data_life/repositories/moment_provider.dart';
import 'package:data_life/repositories/contact_provider.dart';
import 'package:data_life/repositories/contact_repository.dart';
import 'package:data_life/repositories/location_provider.dart';
import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/repositories/action_provider.dart';
import 'package:data_life/repositories/action_repository.dart';
import 'package:data_life/repositories/goal_provider.dart';
import 'package:data_life/repositories/goal_repository.dart';

import 'package:data_life/blocs/moment_edit_bloc.dart';
import 'package:data_life/blocs/contact_edit_bloc.dart';
import 'package:data_life/blocs/location_edit_bloc.dart';
import 'package:data_life/blocs/goal_edit_bloc.dart';
import 'package:data_life/blocs/db_bloc.dart';
import 'package:data_life/blocs/theme_bloc.dart';

import 'package:data_life/paging/page_bloc.dart';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';

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
  ContactRepository _contactRepository;
  LocationRepository _locationRepository;
  ActionRepository _actionRepository;
  GoalRepository _goalRepository;

  PageBloc<Moment> _momentListBloc;
  PageBloc<Goal> _goalListBloc;
  PageBloc<Contact> _contactListBloc;
  PageBloc<Location> _locationListBloc;

  MomentEditBloc _momentEditBloc;
  ContactEditBloc _contactEditBloc;
  LocationEditBloc _locationEditBloc;
  GoalEditBloc _goalEditBloc;

  @override
  void initState() {
    super.initState();

    _momentRepository = MomentRepository(MomentProvider());
    _contactRepository = ContactRepository(ContactProvider());
    _locationRepository = LocationRepository(LocationProvider());
    _actionRepository = ActionRepository(ActionProvider());
    _goalRepository = GoalRepository(GoalProvider());

    _momentListBloc = PageBloc<Moment>(pageRepository: _momentRepository);
    _goalListBloc = PageBloc<Goal>(pageRepository: _goalRepository);
    _contactListBloc = PageBloc<Contact>(pageRepository: _contactRepository);
    _locationListBloc = PageBloc<Location>(pageRepository: _locationRepository);

    _momentEditBloc = MomentEditBloc(
      momentRepository: _momentRepository,
      actionRepository: _actionRepository,
      locationRepository: _locationRepository,
      contactRepository: _contactRepository,
    );
    _contactEditBloc = ContactEditBloc(
      locationRepository: _locationRepository,
      contactRepository: _contactRepository,
    );
    _locationEditBloc =
        LocationEditBloc(locationRepository: _locationRepository);
    _goalEditBloc = GoalEditBloc(
      goalRepository: _goalRepository,
      actionRepository: _actionRepository,
    );

    _dbBloc.dispatch(OpenDb());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<DbBloc>(builder: (BuildContext context) => _dbBloc),
        BlocProvider<ThemeBloc>(builder: (BuildContext context) => _themeBloc),
        BlocProvider<MomentEditBloc>(builder: (BuildContext context) => _momentEditBloc),
        BlocProvider<ContactEditBloc>(builder: (BuildContext context) => _contactEditBloc),
        BlocProvider<LocationEditBloc>(builder: (BuildContext context) => _locationEditBloc),
        BlocProvider<GoalEditBloc>(builder: (BuildContext context) => _goalEditBloc),
        BlocProvider<PageBloc<Moment>>(builder: (BuildContext context) => _momentListBloc),
        BlocProvider<PageBloc<Goal>>(builder: (BuildContext context) => _goalListBloc),
        BlocProvider<PageBloc<Contact>>(builder: (BuildContext context) => _contactListBloc),
        BlocProvider<PageBloc<Location>>(builder: (BuildContext context) => _locationListBloc),
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
                  return HomePage(title: 'home');
                }
              },
            ),
          );
        },
      ),
    );
  }
}
