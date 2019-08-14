import 'package:flutter/material.dart';

import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/login_page.dart';


class MeView extends StatefulWidget {
  @override
  _MeViewState createState() => _MeViewState();
}


class _MeViewState extends State<MeView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 48,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
                SizedBox(width: 20),
                Text('立即登陆',
                  style: Theme.of(context).textTheme.headline,
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                PageTransition(
                  child: LoginPage(),
                  type: PageTransitionType.rightToLeft,
                ));
          },
        ),
      ],
    );
  }
}
