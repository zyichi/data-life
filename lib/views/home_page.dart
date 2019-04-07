import 'package:flutter/material.dart';

import 'package:data_life/views/event_edit.dart';
import 'package:data_life/views/goal_list.dart';
import 'package:data_life/views/activity_list.dart';
import 'package:data_life/blocs/goal_bloc.dart';
import 'package:data_life/localizations.dart';
import 'package:data_life/views/goal_edit.dart';
import 'package:data_life/views/timer_page.dart';
import 'package:data_life/views/test_layout.dart';
import 'package:data_life/views/x_home_page.dart';

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class MyHomePage extends StatefulWidget {
  static const routeName = 'home';

  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TabController _tabController;
  bool _initGoalStream = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        {
          print('HomePage resumed');
          break;
        }
      case AppLifecycleState.inactive:
        {
          print('HomePage inactive');
          break;
        }
      case AppLifecycleState.paused:
        {
          print('HomePage paused');
          break;
        }
      case AppLifecycleState.suspending:
        {
          print('HomePage suspending');
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initGoalStream) {
      _initGoalStream = false;
      GoalProvider.of(context).invalid.add(true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appName),
        bottom: TabBar(
          indicator: _getIndicator(),
          controller: _tabController,
          tabs: [
            Tab(
              text: AppLocalizations.of(context).events,
            ),
            Tab(
              text: AppLocalizations.of(context).goals,
            ),
            Tab(
              text: AppLocalizations.of(context).people,
            ),
            Tab(
              text: AppLocalizations.of(context).statistics,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          EventList(),
          GoalList(),
          Icon(Icons.people),
          Icon(Icons.insert_chart),
        ],
      ),
      bottomNavigationBar: _BottomAppBar(),
    );
  }

  Decoration _getIndicator() {
    return const UnderlineTabIndicator();
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar();

  Widget _buildActivityTextField(BuildContext context) {
    return new TapOnlyTextField();
  }

  void _showSnackBar(BuildContext context, String action) {
    final snackBar = SnackBar(
      content: Text('$action clicked'),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          _buildActivityTextField(context),
          IconButton(
            icon: Icon(Icons.outlined_flag),
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          GoalEdit(AppLocalizations.of(context).goal),
                      fullscreenDialog: true,
                      settings: RouteSettings(
                        name: GoalEdit.routeName,
                      )));
            },
          ),
          IconButton(
            icon: Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => XHomePage(
                        title: AppLocalizations.of(context).people,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.timer),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => TimerPage(
                        title: AppLocalizations.of(context).timer,
                      ),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.menu),
            // onPressed: () => _showSnackBar(context, 'menu'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestLayout(),
                  fullscreenDialog: true,
                  settings: RouteSettings(
                    name: TestLayout.routeName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TapOnlyTextField extends StatelessWidget {
  const TapOnlyTextField({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: Colors.transparent,
            child: IgnorePointer(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context).addEvent,
                ),
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => EventEdit(
                        title: AppLocalizations.of(context).event,
                      ),
                  fullscreenDialog: true));
        },
      ),
    );
  }
}
