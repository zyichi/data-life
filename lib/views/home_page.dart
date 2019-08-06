import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/goal_edit.dart';
import 'package:data_life/views/search_page.dart';
import 'package:data_life/views/moment_list.dart';
import 'package:data_life/views/goal_list.dart';
import 'package:data_life/views/todo_list.dart';
import 'package:data_life/views/moment_edit.dart';
import 'package:data_life/views/my_bottom_sheet.dart';

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

enum TabType {
  moments,
  goals,
  todo,
}
List<TabType> tabTypeList = [
  TabType.moments,
  TabType.goals,
  TabType.todo,
];
String tabTypeToStr(TabType t, BuildContext context) {
  switch (t) {
    case TabType.moments:
      return AppLocalizations.of(context).moments;
    case TabType.goals:
      return AppLocalizations.of(context).goals;
    case TabType.todo:
      return 'To-do';
    default:
      return null;
  }
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
  TabController _tabController;

  MomentBloc _momentBloc;
  GoalBloc _goalBloc;
  ContactBloc _contactBloc;
  LocationBloc _locationBloc;
  ActionBloc _actionBloc;
  TodoBloc _todoBloc;

  var _androidApp = MethodChannel("android_app");

  var _newTodoCount = 0;
  final double _todoCountBubbleMinWidth = 24;
  final double _todoCountBubbleMinHeight = 24;

  @override
  void initState() {
    print('HomePage.initState');

    super.initState();

    _momentBloc = BlocProvider.of<MomentBloc>(context);
    _contactBloc = BlocProvider.of<ContactBloc>(context);
    _locationBloc = BlocProvider.of<LocationBloc>(context);
    _goalBloc = BlocProvider.of<GoalBloc>(context);
    _actionBloc = BlocProvider.of<ActionBloc>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);

    _tabController = TabController(length: tabTypeList.length, vsync: this);
  }

  @override
  void dispose() {
    print('HomePage.dispose');

    super.dispose();
  }

  Widget _createHomeSearchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
      ),
      child: TapOnlyTextField(
        hintText: 'Search life',
        borderRadius: BorderRadius.all(Radius.circular(8)),
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              child: SearchPage(),
              type: PageTransitionType.fade,
              duration: Duration(microseconds: 300),
              // alignment: Alignment.topCenter,
            ),
          );
        },
      ),
    );
  }

  Decoration _getIndicator() {
    return const UnderlineTabIndicator();
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
      print('Goal updated, dispatch GoalUpdatedTodoEvent');
      _todoBloc.dispatch(
          GoalUpdatedTodoEvent(oldGoal: state.oldGoal, newGoal: state.newGoal));
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

  void _locationBlocListener(
      BuildContext context, LocationState state) {
    if (state is LocationUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
    }
    if (state is LocationFailed) {
      print('${state.error}');
    }
  }

  void _actionBlocListener(
      BuildContext context, ActionState state) {
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
    print('HomePage.build');
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
            title: _createHomeSearchBar(),
            bottom: TabBar(
              indicator: _getIndicator(),
              controller: _tabController,
              tabs: tabTypeList.map((tabType) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, top: 0, right: 16, bottom: 0),
                              child: Text(tabTypeToStr(tabType, context)),
                            ),
                          ),
                          (tabType == TabType.todo && _newTodoCount > 0)
                              ? Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          _todoCountBubbleMinWidth / 2),
                                      color: Colors.red,
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: _todoCountBubbleMinWidth,
                                      minHeight: _todoCountBubbleMinHeight,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          _newTodoCount > 99
                                              ? '99+'
                                              : _newTodoCount.toString(),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(growable: false),
            ),
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
            child: TabBarView(
              controller: _tabController,
              children: tabTypeList.map((tabType) {
                String text = tabTypeToStr(tabType, context);
                print('Create tab view for $text');
                switch (tabType) {
                  case TabType.moments:
                    return MomentList(name: text);
                  case TabType.goals:
                    return GoalList(name: text);
                  case TabType.todo:
                    return TodoList(name: text);
                  default:
                    return null;
                }
              }).toList(growable: false),
            ),
          ),
          bottomNavigationBar: _BottomBar(),
        ),
      ),
    );
  }
}

class TapOnlyTextField extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;
  final BorderRadius borderRadius;

  const TapOnlyTextField({
    Key key,
    this.onTap,
    this.hintText,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: Colors.transparent,
            child: IgnorePointer(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                ),
              ),
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() {
    return new _BottomBarState();
  }
}

class _BottomBarState extends State<_BottomBar> {
  void addMomentOnTap() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MomentEdit(),
          fullscreenDialog: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TapOnlyTextField(
                onTap: addMomentOnTap,
                hintText: 'Add moment',
              ),
            ),
            IconButton(
              icon: Icon(Icons.outlined_flag),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => GoalEdit(),
                    fullscreenDialog: true,
                    settings: RouteSettings(name: GoalEdit.routeName),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return MyBottomSheet();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
