import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/views/test_layout.dart';
import 'package:data_life/views/goal_edit.dart';
import 'package:data_life/views/timer_page.dart';
import 'package:data_life/views/search_page.dart';
import 'package:data_life/views/my_color.dart';
import 'package:data_life/views/people_suggestion.dart';
import 'package:data_life/views/contact_page.dart';
import 'package:data_life/views/moment_list.dart';
import 'package:data_life/views/contact_list.dart';
import 'package:data_life/views/goal_list.dart';
import 'package:data_life/views/todo_list.dart';
import 'package:data_life/views/moment_edit.dart';
import 'package:data_life/views/location_list.dart';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';

import 'package:data_life/blocs/moment_edit_bloc.dart';
import 'package:data_life/blocs/contact_edit_bloc.dart';
import 'package:data_life/blocs/location_edit_bloc.dart';

import 'package:data_life/paging/page_bloc.dart';

import 'package:data_life/localizations.dart';

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

  MomentEditBloc _momentEditBloc;
  ContactEditBloc _contactEditBloc;
  LocationEditBloc _locationEditBloc;

  var _androidApp = MethodChannel("android_app");

  @override
  void initState() {
    print('HomePage.initState');

    super.initState();

    _momentEditBloc = BlocProvider.of<MomentEditBloc>(context);
    _contactEditBloc = BlocProvider.of<ContactEditBloc>(context);
    _locationEditBloc = BlocProvider.of<LocationEditBloc>(context);

    _tabController = TabController(length: 5, vsync: this);
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
        color: Colors.white,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            color: MyColor.greyIcon,
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          Expanded(
            child: TapOnlyTextField(
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
              hintText: 'Search life',
            ),
          ),
        ],
      ),
    );
  }

  Decoration _getIndicator() {
    return const UnderlineTabIndicator();
  }

  void _momentEditBlocListener(BuildContext context, MomentEditState state) {
    if (state is MomentAdded ||
        state is MomentDeleted ||
        state is MomentUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
    }
    if (state is MomentDeleted) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Your moment has been deleted'),
        duration: Duration(seconds: 10),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // We add back the deleted moment as new moment, so moment.id must
            // set to null.
            state.moment.id = null;
            _momentEditBloc.dispatch(AddMoment(moment: state.moment));
          },
        ),
      ));
    }
    if (state is MomentEditFailed) {
      print('${state.error}');
    }
  }

  void _contactEditBlocListener(BuildContext context, ContactEditState state) {
    if (state is ContactUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
    }
    if (state is ContactEditFailed) {
      print('${state.error}');
    }
  }

  void _locationEditBlocListener(
      BuildContext context, LocationEditState state) {
    if (state is LocationUpdated) {
      BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
      BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
    }
    if (state is LocationEditFailed) {
      print('${state.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('HomePage.build');
    var _tabs = <String>[
      AppLocalizations.of(context).moments,
      AppLocalizations.of(context).goals,
      'ToDo',
      AppLocalizations.of(context).contacts,
      AppLocalizations.of(context).location,
    ];

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
      },
      child: Material(
        child: Scaffold(
          appBar: AppBar(
            title: _createHomeSearchBar(),
            bottom: TabBar(
              indicator: _getIndicator(),
              controller: _tabController,
              tabs: _tabs.map((text) {
                return Tab(text: text);
              }).toList(growable: false),
            ),
          ),
          body: BlocListenerTree(
            blocListeners: [
              BlocListener<MomentEditEvent, MomentEditState>(
                bloc: _momentEditBloc,
                listener: _momentEditBlocListener,
              ),
              BlocListener<ContactEditEvent, ContactEditState>(
                bloc: _contactEditBloc,
                listener: _contactEditBlocListener,
              ),
              BlocListener<LocationEditEvent, LocationEditState>(
                bloc: _locationEditBloc,
                listener: _locationEditBlocListener,
              ),
            ],
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((text) {
                print('Create tab view for $text');
                if (text == AppLocalizations.of(context).moments) {
                  return MomentList(name: text);
                }
                if (text == AppLocalizations.of(context).goals) {
                  return GoalList(name: text);
                }
                if (text == 'ToDo') {
                  return ToDoList(name: text);
                }
                if (text == AppLocalizations.of(context).contacts) {
                  return ContactList(name: text);
                }
                if (text == AppLocalizations.of(context).location) {
                  return LocationList(name: text);
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

  const TapOnlyTextField({
    Key key,
    this.onTap,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
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
      color: Colors.white,
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
              color: MyColor.greyIcon,
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
              color: MyColor.greyIcon,
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
              color: MyColor.greyIcon,
              icon: Icon(Icons.menu),
              // onPressed: () => _showSnackBar(context, 'menu'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PeopleSuggestion(),
                    fullscreenDialog: true,
                    settings: RouteSettings(name: TestLayout.routeName),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
