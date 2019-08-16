import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/repositories/user_repository.dart';


abstract class AuthState extends Equatable {}


class AuthUninitialized extends AuthState {
  @override
  String toString() => 'AuthUninitialized';
}


class AuthAuthenticated extends AuthState {
  @override
  String toString() => 'AuthAuthenticated';
}


class AuthUnauthenticated extends AuthState {
  @override
  String toString() => 'AuthUnauthenticated';
}


class AuthLoading extends AuthState {
  @override
  String toString() => 'AuthLoading';
}


abstract class AuthEvent extends Equatable {
  AuthEvent([List props = const []]) : super(props);
}


class AuthCheck extends AuthEvent {
  @override
  String toString() => 'AuthCheck';
}


class LoggedIn extends AuthEvent {
  final String token;

  LoggedIn({@required this.token}) : super([token]);

  @override
  String toString() => 'LoggedIn { token: $token }';
}


class LoggedOut extends AuthEvent {
  @override
  String toString() => 'LoggedOut';
}


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({@required this.userRepository}) : assert(userRepository != null);

  @override
  AuthState get initialState => AuthUninitialized();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthCheck) {
      final bool hasToken = await userRepository.hasToken();
      if (hasToken) {
        yield AuthAuthenticated();
      } else {
        yield AuthUnauthenticated();
      }
    }
    if (event is LoggedIn) {
      yield AuthLoading();
      await userRepository.persistToken(event.token);
      yield AuthAuthenticated();
    }
    if (event is LoggedOut) {
      yield AuthLoading();
      await userRepository.deleteToken();
      yield AuthUnauthenticated();
    }
  }

}