import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/moment_list.dart';
import 'package:data_life/views/goal_list.dart';
import 'package:data_life/views/todo_list.dart';
import 'package:data_life/views/action_page.dart';
import 'package:data_life/views/location_page.dart';
import 'package:data_life/views/contact_page.dart';
import 'package:data_life/views/goal_edit.dart';
import 'package:data_life/views/moment_edit.dart';
import 'package:data_life/views/me_view.dart';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/todo.dart';

import 'package:data_life/blocs/moment_bloc.dart';
import 'package:data_life/blocs/goal_bloc.dart';
import 'package:data_life/blocs/contact_bloc.dart';
import 'package:data_life/blocs/location_bloc.dart';
import 'package:data_life/blocs/todo_bloc.dart';
import 'package:data_life/blocs/action_bloc.dart';

import 'package:data_life/paging/page_bloc.dart';

import 'package:data_life/localizations.dart';

class _Tab {
  final String label;
  final String title;
  final IconData fabIconData;
  final VoidCallback fabOnPressed;
  final Widget view;

  _Tab(
      {this.view, this.label, this.title, this.fabIconData, this.fabOnPressed});
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title});

  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  MomentBloc _momentBloc;
  GoalBloc _goalBloc;
  ContactBloc _contactBloc;
  LocationBloc _locationBloc;
  ActionBloc _actionBloc;
  TodoBloc _todoBloc;

  var _androidApp = MethodChannel("android_app");

  var _newTodoCount = 0;
  int _selectedNavigationIndex;
  List<_Tab> _tabs;

  @override
  void initState() {
    super.initState();

    _momentBloc = BlocProvider.of<MomentBloc>(context);
    _contactBloc = BlocProvider.of<ContactBloc>(context);
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _goalBloc = BlocProvider.of<GoalBloc>(context);
    _actionBloc = BlocProvider.of<ActionBloc>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);

    _tabs = <_Tab>[
      _Tab(
        view: MomentList(name: 'moment'),
        fabIconData: Icons.event,
        fabOnPressed: _momentFabOnPressed,
        label: '动态',
        title: 'DataLife',
      ),
      _Tab(
        view: GoalList(name: 'goal'),
        fabIconData: Icons.outlined_flag,
        fabOnPressed: _goalFabOnPressed,
        label: '目标',
        title: '目标',
      ),
      _Tab(
        view: TodoList(name: 'todo'),
        fabIconData: null,
        fabOnPressed: null,
        label: '待办',
        title: '今日待办',
      ),
      _Tab(
        view: MeView(),
        fabIconData: null,
        fabOnPressed: null,
        label: '我',
        title: '我',
      ),
    ];
    _selectedNavigationIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _momentBlocListener(BuildContext context, MomentState state) {
    if (state is MomentAdded ||
        state is MomentDeleted ||
        state is MomentUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
    }
    if (state is MomentDeleted) {
      _goalBloc.dispatch(MomentDeletedGoalEvent(moment: state.moment));
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text('Your moment ${state.moment.action.name} has been deleted'),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // We add back the deleted moment as new moment, so moment.id must
            // set to null.
            state.moment.id = null;
            _momentBloc.dispatch(AddMoment(moment: state.moment));
          },
        ),
      ));
    }
    if (state is MomentAdded) {
      _goalBloc.dispatch(MomentAddedGoalEvent(moment: state.moment));
    }
    if (state is MomentUpdated) {
      _goalBloc.dispatch(MomentUpdatedGoalEvent(
          newMoment: state.newMoment, oldMoment: state.oldMoment));
    }
    if (state is MomentFailed) {
      print('${state.error}');
    }
  }

  void _goalBlocListener(BuildContext context, GoalState state) {
    if (state is GoalAdded ||
        state is GoalDeleted ||
        state is GoalUpdated ||
        state is GoalStatusUpdated) {
      BlocProvider.of<PageBloc<Goal>>(context).dispatch(RefreshPage());
    }
    if (state is GoalDeleted) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Your goal ${state.goal.name} has been deleted'),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // We add back the deleted goal as new goal, so goal.id must
            // set to null.
            state.goal.id = null;
            _goalBloc.dispatch(AddGoal(goal: state.goal));
          },
        ),
      ));
      _todoBloc.dispatch(GoalDeletedTodoEvent(goal: state.goal));
    }
    if (state is GoalAdded) {
      _todoBloc.dispatch(GoalAddedTodoEvent(goal: state.goal));
    }
    if (state is GoalUpdated) {
      _todoBloc.dispatch(
          GoalUpdatedTodoEvent(oldGoal: state.oldGoal, newGoal: state.newGoal));
    }
    if (state is GoalResumed) {
      _todoBloc.dispatch(
          GoalUpdatedTodoEvent(oldGoal: null, newGoal: state.goal));
    }
    if (state is GoalPaused) {
      _todoBloc.dispatch(
          GoalUpdatedTodoEvent(oldGoal: null, newGoal: state.goal));
    }
    if (state is GoalFinished) {
      _todoBloc.dispatch(
          GoalUpdatedTodoEvent(oldGoal: null, newGoal: state.goal));
    }
    if (state is GoalFailed) {
      print('${state.error}');
    }
  }

  void _contactBlocListener(BuildContext context, ContactState state) {
    if (state is ContactUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
    }
    if (state is ContactFailed) {
      print('${state.error}');
    }
  }

  void _locationBlocListener(BuildContext context, LocationState state) {
    if (state is LocationUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
    }
    if (state is LocationFailed) {
      print('${state.error}');
    }
  }

  void _actionBlocListener(BuildContext context, ActionState state) {
    if (state is ActionUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<MyAction>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Goal>>(context).dispatch(RefreshPage());
    }
    if (state is ActionFailed) {
      print('${state.error}');
    }
  }

  void _todoBlocListener(BuildContext context, TodoState state) {
    if (state is TodayTodoCreated ||
        state is TodoDismissed ||
        state is TodoDone ||
        state is TodoDeleted ||
        state is TodoUpdated) {
      setState(() {
        _newTodoCount = _todoBloc.waitingTodoCount;
      });
      BlocProvider.of<PageBloc<Todo>>(context).dispatch(RefreshPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (Platform.isAndroid) {
          if (Navigator.of(context).canPop()) {
            return Future.value(true);
          } else {
            _androidApp.invokeMethod("toBack");
          }
        } else {
          return Future.value(true);
        }
        return Future.value(true);
      },
      child: Material(
        child: Scaffold(
          appBar: AppBar(
            title: Text(_tabs.elementAt(_selectedNavigationIndex).title),
            centerTitle: false,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
              /*
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'contact') {
                    Navigator.push(
                        context,
                        PageTransition(
                          child: ContactPage(),
                          type: PageTransitionType.rightToLeft,
                        ));
                  }
                  if (value == 'location') {
                    Navigator.push(
                        context,
                        PageTransition(
                          child: LocationPage(),
                          type: PageTransitionType.rightToLeft,
                        ));
                  }
                  if (value == 'action') {
                    Navigator.push(
                        context,
                        PageTransition(
                          child: ActionPage(),
                          type: PageTransitionType.rightToLeft,
                        ));
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'contact',
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.people,
                            color: _captionColor(),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Contacts',
                            style: TextStyle(
                              color: _captionColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'location',
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.place,
                            color: _captionColor(),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Locations',
                            style: TextStyle(
                              color: _captionColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'action',
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.accessibility_new,
                            color: _captionColor(),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Actions',
                            style: TextStyle(
                              color: _captionColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ];
                },
              ),
              */
            ],
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<MomentBloc, MomentState>(
                bloc: _momentBloc,
                listener: _momentBlocListener,
              ),
              BlocListener<TodoBloc, TodoState>(
                bloc: _todoBloc,
                listener: _todoBlocListener,
              ),
              BlocListener<GoalBloc, GoalState>(
                bloc: _goalBloc,
                listener: _goalBlocListener,
              ),
              BlocListener<ContactBloc, ContactState>(
                bloc: _contactBloc,
                listener: _contactBlocListener,
              ),
              BlocListener<LocationBloc, LocationState>(
                bloc: _locationBloc,
                listener: _locationBlocListener,
              ),
              BlocListener<ActionBloc, ActionState>(
                bloc: _actionBloc,
                listener: _actionBlocListener,
              ),
            ],
            child: _tabs.elementAt(_selectedNavigationIndex).view,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.event_note),
                title: Text(_tabs.elementAt(0).label),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.flag),
                title: Text(_tabs.elementAt(1).label),
              ),
              BottomNavigationBarItem(
                icon: Row(
                  children: <Widget>[
                    Spacer(),
                    Stack(
                      children: <Widget>[
                        Container(
                          width: 40,
                          child: Icon(
                            Icons.notifications,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: _createTodoBadge(_newTodoCount),
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
                title: Text(_tabs.elementAt(2).label),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                title: Text(_tabs.elementAt(3).label),
              ),
            ],
            currentIndex: _selectedNavigationIndex,
            onTap: _onNavigationItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
          floatingActionButton:
              _createFloatingActionButton(_selectedNavigationIndex),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }

  void _momentFabOnPressed() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MomentEdit(),
          fullscreenDialog: true,
        ));
  }

  void _goalFabOnPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => GoalEdit(),
        fullscreenDialog: true,
        settings: RouteSettings(name: GoalEdit.routeName),
      ),
    );
  }

  Widget _createFloatingActionButton(int index) {
    _Tab tab = _tabs.elementAt(index);
    if (tab.fabIconData == null) return Container();
    return FloatingActionButton(
      child: Icon(tab.fabIconData),
      onPressed: tab.fabOnPressed,
      mini: false,
      // backgroundColor: Colors.lightGreen,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }

  void _onNavigationItemTapped(int index) {
    setState(() {
      _selectedNavigationIndex = index;
    });
  }

  Widget _createTodoBadge(int count) {
    if (count == 0) return Container();
    if (count < 10) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
    );
  }

  Color _captionColor() {
    return Theme.of(context).textTheme.caption.color;
  }
}
