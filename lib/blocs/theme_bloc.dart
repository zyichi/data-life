import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';


abstract class ThemeEvent extends Equatable {
  ThemeEvent([List props = const []]) : super(props);
}


class PrivacyChanged extends ThemeEvent {
  final bool privacy;

  PrivacyChanged({@required this.privacy})
      : assert(privacy != null),
        super([privacy]);
}


class ThemeState extends Equatable {
  final ThemeData theme;
  final MaterialColor color;

  ThemeState({@required this.theme, @required this.color})
      : assert(theme != null),
        assert(color != null),
        super([theme, color]);
}


class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeData _XprivacyTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Colors.purple[200],
    accentColor: Colors.deepOrange[200],
    // canvasColor: Colors.white,
    scaffoldBackgroundColor: Color(0x121212),
  );
  final ThemeData _privacyTheme = ThemeData.dark().copyWith(
  );
  final ThemeData _defaultTheme = ThemeData.light().copyWith(
    primaryColorLight: Colors.green[200],
    primaryColorDark: Colors.green[700],
    primaryColor: Colors.green[500],
    accentColor: Colors.deepOrange[500],
    scaffoldBackgroundColor: Colors.white,
  );
  final ThemeData _XdefaultTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: Colors.green[500],
    accentColor: Colors.deepOrange[500],
    scaffoldBackgroundColor: Colors.white,
  );
  final Color _color = Colors.grey;
  bool _privacy = false;

  @override
  ThemeState get initialState => ThemeState(
    theme: _defaultTheme,
    color: Colors.grey,
  );

  @override
  Stream<ThemeState> mapEventToState(ThemeEvent event) async* {
    if (event is PrivacyChanged) {
      _privacy = !_privacy;
      if (_privacy) {
        yield ThemeState(theme: _privacyTheme, color: _color);
      } else {
        yield ThemeState(theme: _defaultTheme, color: _color);
      }
    }
  }

}