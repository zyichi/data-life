import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/blocs/timer_bloc.dart';

enum _LoginMode {
  password,
  sms,
  weChat,
  qq,
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginMode _loginMode = _LoginMode.password;
  String _phoneNumber = '';
  String _username = '';
  String _password = '';
  String _smsCode = '';
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _smsCodeController = TextEditingController();
  TimerBloc _timerBloc;

  @override
  void initState() {
    super.initState();

    _timerBloc = BlocProvider.of<TimerBloc>(context);

    _phoneNumberController.addListener(() {
      setState(() {
        _phoneNumber = _phoneNumberController.text;
      });
    });
    _usernameController.addListener(() {
      setState(() {
        _username = _usernameController.text;
      });
    });
    _passwordController.addListener(() {
      setState(() {
        _password = _passwordController.text;
      });
    });
    _smsCodeController.addListener(() {
      setState(() {
        _smsCode = _smsCodeController.text;
      });
    });
  }

  @override
  void dispose() {
    _timerBloc.dispatch(Reset());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _createAppIdentity(),
            SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _createLoginArea(_loginMode),
            ),
            Spacer(),
            _createPartnerLoginArea(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _createAppIdentity() {
    return Center(
      child: Column(
        children: <Widget>[
          Image.asset(
            'assets/icon/launcher.png',
            fit: BoxFit.scaleDown,
            width: 128,
            height: 128,
          ),
          Text(
            'DataLife',
            style: Theme.of(context).textTheme.title,
          ),
        ],
      ),
    );
  }

  Widget _createLoginArea(_LoginMode loginMode) {
    if (loginMode == _LoginMode.sms) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              prefixText: '+86 ',
              hintText: '请输入手机号',
              prefixIcon: Icon(Icons.smartphone),
              border: UnderlineInputBorder(),
              labelText: '请输入手机号',
              helperText: '未注册手机验证后自动创建',
            ),
            controller: _phoneNumberController,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '请输入验证码',
                    prefixIcon: Icon(Icons.sms),
                    border: UnderlineInputBorder(),
                    labelText: '请输入验证码',
                  ),
                  controller: _smsCodeController,
                ),
              ),
              BlocBuilder(
                bloc: _timerBloc,
                builder: (context, state) {
                  String text = '获取验证码';
                  bool _enableTap = true;
                  if (state is Running) {
                    final String secondsStr = (state.duration % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    text = '$secondsStr 秒后重发';
                    _enableTap = false;
                  }
                  if (state is Finished) {
                    _enableTap = true;
                  }
                  return RaisedButton(
                    elevation: 0,
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      text,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: _phoneNumber.isEmpty || !_enableTap
                        ? null
                        : () {
                            _timerBloc.dispatch(Start(duration: 8));
                            _enableTap = false;
                          },
                  );
                },
              )
            ],
          ),
          SizedBox(height: 16),
          RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 40),
            color: Theme.of(context).primaryColor,
            child: Text(
              '下一步',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: !_validSmsLoginData() ? null : () {
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '帐号密码登陆',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _loginMode = _LoginMode.password;
                  });
                },
              ),
              _createForgetPasswordWidget(),
            ],
          )
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              hintText: '手机号/邮箱/用户名',
              prefixIcon: Icon(Icons.perm_identity),
              border: UnderlineInputBorder(),
              labelText: '帐号',
            ),
            controller: _usernameController,
          ),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: '请输入密码',
              prefixIcon: Icon(Icons.vpn_key),
              border: UnderlineInputBorder(),
              labelText: '密码',
            ),
            controller: _passwordController,
          ),
          SizedBox(height: 16),
          RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 40),
            color: Theme.of(context).primaryColor,
            child: Text(
              '下一步',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: !_validPasswordLoginData() ? null : () {},
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '手机验证码登陆',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _loginMode = _LoginMode.sms;
                  });
                },
              ),
              _createForgetPasswordWidget(),
            ],
          )
        ],
      );
    }
  }

  bool _validPasswordLoginData() {
    return _username.isNotEmpty && _password.length >= 8;
  }

  bool _validSmsLoginData() {
    return _phoneNumber.isNotEmpty && _smsCode.length == 6;
  }

  Widget _createForgetPasswordWidget() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          '忘记密码？',
          style: TextStyle(
            color: Theme.of(context).textTheme.caption.color,
          ),
        ),
      ),
      onTap: () {},
    );
  }

  Widget _createPartnerLoginArea() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/icon/icon64_appwx_logo.png',
                fit: BoxFit.scaleDown,
                width: 64,
                height: 64,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '微信登陆',
            style: TextStyle(
              color: Theme.of(context).textTheme.caption.color,
            ),
          ),
        ],
      ),
      onTap: () {},
    );
  }
}
