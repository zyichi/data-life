import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/localizations.dart';
import 'package:data_life/views/test_layout.dart';
import 'package:data_life/views/goal_edit.dart';
import 'package:data_life/views/timer_page.dart';
import 'package:data_life/views/search_page.dart';
import 'package:data_life/views/my_color.dart';
import 'package:data_life/views/people_suggestion.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:data_life/views/contact_page.dart';
import 'package:data_life/views/moment_list.dart';
import 'package:data_life/views/contact_list.dart';
import 'package:data_life/views/goal_list.dart';
import 'package:data_life/views/moment_edit.dart';
import 'package:data_life/views/location_list.dart';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/goal.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/views/repositories.dart';

import 'package:data_life/repositories/moment_repository.dart';
import 'package:data_life/repositories/moment_provider.dart';
import 'package:data_life/repositories/goal_provider.dart';
import 'package:data_life/repositories/goal_repository.dart';
import 'package:data_life/repositories/contact_provider.dart';
import 'package:data_life/repositories/contact_repository.dart';
import 'package:data_life/repositories/location_provider.dart';
import 'package:data_life/repositories/location_repository.dart';

import 'package:data_life/blocs/moment_edit_bloc.dart';

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
  PageBloc<Moment> _momentBloc;
  PageBloc<Goal> _goalBloc;
  PageBloc<Contact> _contactBloc;
  PageBloc<Location> _locationBloc;
  MomentRepository _momentRepository;
  GoalRepository _goalRepository;
  ContactRepository _contactRepository;
  LocationRepository _locationRepository;

  MomentEditBloc _momentEditBloc;

  var _androidApp = MethodChannel("android_app");

  @override
  void initState() {
    print('HomePage.initState');

    super.initState();

    _momentRepository = MomentRepository(MomentProvider());
    _goalRepository = GoalRepository(GoalProvider());
    _contactRepository = ContactRepository(ContactProvider());
    _locationRepository = LocationRepository(LocationProvider());

    _momentBloc = PageBloc<Moment>(pageRepository: _momentRepository);
    _goalBloc = PageBloc<Goal>(pageRepository: _goalRepository);
    _contactBloc = PageBloc<Contact>(pageRepository: _contactRepository);
    _locationBloc = PageBloc<Location>(pageRepository: _locationRepository);

    _momentEditBloc = BlocProvider.of<MomentEditBloc>(context);

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    print('HomePage.dispose');
    _momentBloc.dispose();

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

  @override
  Widget build(BuildContext context) {
    print('HomePage.build');
    var _tabs = <String>[
      AppLocalizations.of(context).moments,
      AppLocalizations.of(context).goals,
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
      child: Repositories(
        momentRepository: _momentRepository,
        contactRepository: _contactRepository,
        locationRepository: _locationRepository,
        child: BlocProviderTree(
          blocProviders: [
            BlocProvider<PageBloc<Moment>>(
              bloc: _momentBloc,
            ),
            BlocProvider<PageBloc<Goal>>(
              bloc: _goalBloc,
            ),
            BlocProvider<PageBloc<Contact>>(
              bloc: _contactBloc,
            ),
            BlocProvider<PageBloc<Location>>(
              bloc: _locationBloc,
            ),
          ],
          child: Material(
            child: BlocListener(
              bloc: _momentEditBloc,
              listener: (context, momentEditState) {
                print('MomentEditBloc listener');
                if (momentEditState is MomentAdded ||
                    momentEditState is MomentDeleted ||
                    momentEditState is MomentUpdated) {
                  print(
                      'Moment edit state received, refresh moment/contact/location list');
                  BlocProvider.of<PageBloc<Moment>>(context)
                      .dispatch(RefreshPage());
                  BlocProvider.of<PageBloc<Contact>>(context)
                      .dispatch(RefreshPage());
                  BlocProvider.of<PageBloc<Location>>(context)
                      .dispatch(RefreshPage());
                }
                if (momentEditState is MomentEditFailed) {
                  print('${momentEditState.error}');
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: _createHomeSearchBar(),
                  bottom: TabBar(
                    indicator: _getIndicator(),
                    controller: _tabController,
                    tabs: _tabs.map((text) {
                      return Tab(
                        text: text,
                      );
                    }).toList(growable: false),
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((text) {
                    print('Create tab view for $text');
                    if (text == AppLocalizations.of(context).moments) {
                      return MomentList(
                        name: text,
                      );
                    }
                    if (text == AppLocalizations.of(context).goals) {
                      return GoalList(
                        name: text,
                      );
                    }
                    if (text == AppLocalizations.of(context).contacts) {
                      return ContactList(
                        name: text,
                      );
                    }
                    if (text == AppLocalizations.of(context).location) {
                      return LocationList(
                        name: text,
                      );
                    }
                  }).toList(growable: false),
                ),
                bottomNavigationBar: _BottomBar(),
              ),
            ),
          ),
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
            fullscreenDialog: true));
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
                hintText: 'Save moment',
              ),
            ),
            IconButton(
              color: MyColor.greyIcon,
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
                    ),
                  ),
                );
              },
            ),
            IconButton(
              color: MyColor.greyIcon,
              icon: Icon(Icons.people_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ContactPage(),
                    fullscreenDialog: true,
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
                    settings: RouteSettings(
                      name: TestLayout.routeName,
                    ),
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
