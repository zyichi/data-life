import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data_life/models/user.dart';
import 'package:data_life/constants.dart';

class UserRepository {

  static const String fakedAuthToken = 'faked-auth-token';

  Future<String> passwordAuth({
    @required String username,
    @required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return fakedAuthToken;
  }

  Future<String> smsAuth({
    @required String phoneNumber,
    @required String smsCode,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return fakedAuthToken;
  }

  Future<bool> deleteToken() async {
    var sharePrefs = await SharedPreferences.getInstance();
    return await sharePrefs.remove(SP_KEY_authToken);
  }

  Future<bool> persistToken(String token) async {
    var sharePrefs = await SharedPreferences.getInstance();
    return await sharePrefs.setString(SP_KEY_authToken, token);
  }

  Future<bool> hasToken() async {
    var sharePrefs = await SharedPreferences.getInstance();
    var token = sharePrefs.getString(SP_KEY_authToken);
    return token != null && token.isNotEmpty;
  }

  Future<User> getUser() async {
    await Future.delayed(Duration(seconds: 1));
    var user = User();
    user.username = '张一驰';
    user.phoneNumber = '18611124182';
    user.email = 'zyichi@foxmail.com';
    user.authToken = fakedAuthToken;
    user.loginKind = 'sms';
    return user;
  }
}
