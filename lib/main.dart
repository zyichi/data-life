import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:amap/amap.dart';

import 'package:data_life/views/splash_page.dart';
import 'package:data_life/blocs/db_bloc.dart';
import 'localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_life/views/home_page.dart';


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
              return HomePage(title: 'home');
            }
          },
        ),
      ),
    );
  }
}
