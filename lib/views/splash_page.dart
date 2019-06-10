import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageState createState() {
    return new SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Image.asset(
                'assets/icon/launcher.png',
                fit: BoxFit.scaleDown,
                width: 192.0,
                height: 192.0,
              ),
              Text(
                AppLocalizations.of(context).appName,
                style: Theme.of(context).textTheme.title,
              ),
              Spacer(
                flex: 4,
              ),
              Text(
                '${AppLocalizations.of(context).createdBy} ${AppLocalizations.of(context).author}',
                style: Theme.of(context).textTheme.caption,
              ),
              Spacer(
                flex: 2,
              )
            ],
          ),
        ),
      ),
    );
  }
}
