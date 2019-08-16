import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/repositories/user_repository.dart';
import 'package:data_life/blocs/auth_bloc.dart';

abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginInitial extends LoginState {
  @override
  String toString() => 'LoginInitial';
}

class LoginLoading extends LoginState {
  @override
  String toString() => 'LoginLoading';
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({@required this.error}) : super([error]);

  @override
  String toString() => 'LoginFailure';
}

abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class PasswordLogin extends LoginEvent {
  final String username;
  final String password;

  PasswordLogin({@required this.username, @required this.password})
      : super([username, password]);

  @override
  String toString() =>
      'PasswordLogin { username: $username, password: $password }';
}

class SmsLogin extends LoginEvent {
  final String phoneNumber;
  final String smsCode;

  SmsLogin({@required this.phoneNumber, @required this.smsCode})
      : super([phoneNumber, smsCode]);

  @override
  String toString() =>
      'SmsLogin { phoneNumber: $phoneNumber, smsCode: $smsCode }';
}

class WeChatLogin extends LoginEvent {
  final String appId;
  final String appSecret;

  WeChatLogin({@required this.appId, @required this.appSecret})
      : super([appId, appSecret]);

  @override
  String toString() =>
      'WeChatLogin { appId: $appId, appSecret: $appSecret }';
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthBloc authBloc;

  LoginBloc({@required this.userRepository, @required this.authBloc})
      : assert(userRepository != null),
        assert(authBloc != null);

  @override
  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is PasswordLogin || event is SmsLogin) {
      yield LoginLoading();
      try {
        var token;
        if (event is PasswordLogin) {
          token = await userRepository.passwordAuth(
              username: event.username, password: event.password);
        }
        if (event is SmsLogin) {
          token = await userRepository.smsAuth(
              phoneNumber: event.phoneNumber, smsCode: event.smsCode);
        }

        authBloc.dispatch(LoggedIn(token: token));
        yield LoginInitial();
      } catch (e) {
        yield LoginFailure(error: e.toString());
      }
    }
    
    if (event is WeChatLogin) {
    }
  }
}
