import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/views/contact_page.dart';
import 'package:data_life/views/location_page.dart';

import 'package:data_life/blocs/theme_bloc.dart';

class MyBottomSheet extends StatefulWidget {
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[   
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 16, right: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.people),
                    SizedBox(width: 16),
                    Text('Contacts'),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ContactPage(),
                    fullscreenDialog: true,
                    settings: RouteSettings(name: ContactPage.routeName),
                  ),
                );
              },
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 16, right: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.place),
                    SizedBox(width: 16),
                    Text('Location'),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LocationPage(),
                    fullscreenDialog: true,
                    settings: RouteSettings(name: LocationPage.routeName),
                  ),
                );
              },
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 16, right: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.accessibility_new),
                    SizedBox(width: 16),
                    Text('Actions'),
                  ],
                ),
              ),
              onTap: () {
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ActionPage(),
                    fullscreenDialog: true,
                    settings: RouteSettings(name: ActionPage.routeName),
                  ),
                );
                */
              },
            ),
            Divider(),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 16, right: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.lock),
                    SizedBox(width: 16),
                    Text('Privacy mode'),
                  ],
                ),
              ),
              onTap: () {
                BlocProvider.of<ThemeBloc>(context)
                    .dispatch(PrivacyChanged(privacy: true));
                Navigator.pop(context);
              },
            ),
            Divider(),
            InkWell(
              child: Padding(
                padding:
                    EdgeInsets.only(
                        left: 16, top: 16, right: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.settings),
                    SizedBox(width: 16),
                    Text('Settings'),
                  ],
                ),
              ),
              onTap: () {},
            ),
            InkWell(
              child: Padding(
                padding:
                    EdgeInsets.only(
                        left: 16, top: 16, right: 16, bottom: 16),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.info),
                    SizedBox(width: 16),
                    Text('About'),
                  ],
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
