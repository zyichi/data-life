import 'dart:io';

import 'package:flutter/material.dart';
import 'package:data_life/localizations.dart';
import 'package:data_life/views/test_layout.dart';
import 'package:data_life/views/goal_edit.dart';
import 'package:data_life/views/timer_page.dart';
import 'package:data_life/views/event_edit.dart';
import 'package:data_life/views/search_page.dart';
import 'package:data_life/views/my_color.dart';
import 'package:data_life/views/hero_name.dart';
import 'package:data_life/views/people_suggestion.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:math';

class XHomePage extends StatefulWidget {
  final String title;

  const XHomePage({Key key, this.title});

  @override
  XHomePageState createState() {
    return XHomePageState();
  }
}

class XHomePageState extends State<XHomePage>
    with SingleTickerProviderStateMixin {
  final List<String> _tabs = <String>[
    "Event",
    "Goal",
    "People",
    "Statistics",
  ];

  var _androidApp = MethodChannel("android_app");

  ScrollController _scrollViewController;

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
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
      },
      child: Material(
        child: Scaffold(
          body: DefaultTabController(
            length: _tabs.length,
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    child: SliverSafeArea(
                      top: false,
                      bottom: false,
                      sliver: SliverAppBar(
                        elevation: 16.0,
                        title: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _createHomeSearchBar(),
                        ),
                        pinned: true,
                        floating: true,
                        primary: true,
                        automaticallyImplyLeading: false,
                        titleSpacing: 8.0,
                        snap: false,
                        forceElevated: innerBoxIsScrolled,
                        bottom: TabBar(
                          tabs: _tabs
                              .map((String name) => Tab(
                                    text: name,
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: TabBarView(
                      children: _tabs.map((String name) {
                        return SafeArea(
                          top: false,
                          bottom: false,
                          child: Builder(
                            // This Builder is needed to provide a BuildContext that is "inside"
                            // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
                            // find the NestedScrollView.
                            builder: (BuildContext context) {
                              return CustomScrollView(
                                // The "controller" and "primary" members should be left
                                // unset, so that the NestedScrollView can control this
                                // inner scroll view.
                                // If the "controller" property is set, then this scroll
                                // view will not be associated with the NestedScrollView.
                                // The PageStorageKey should be unique to this ScrollView;
                                // it allows the list to remember its scroll position when
                                // the tab view is not on the screen.
                                key: PageStorageKey<String>(name),
                                slivers: <Widget>[
                                  SliverOverlapInjector(
                                    // This is the flip side of the SliverOverlapAbsorber above.
                                    handle: NestedScrollView
                                        .sliverOverlapAbsorberHandleFor(context),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.all(8.0),
                                    // In this example, the inner scroll view has
                                    // fixed-height list items, hence the use of
                                    // SliverFixedExtentList. However, one could use any
                                    // sliver widget here, e.g. SliverList or SliverGrid.
                                    sliver: SliverFixedExtentList(
                                      // The items in this example are fixed to 48 pixels
                                      // high. This matches the Material Design spec for
                                      // ListTile widgets.
                                      itemExtent: 48.0,
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          // This builder is called for each child.
                                          // In this example, we just number each list item.
                                          return Container(
                                            color: Color(
                                                    (Random().nextDouble() * 0xFFFFFF)
                                                            .toInt() <<
                                                        0)
                                                .withOpacity(1.0),
                                          );
                                        },
                                        // The childCount of the SliverChildBuilderDelegate
                                        // specifies how many children this inner list
                                        // has. In this example, each tab has a list of
                                        // exactly 30 items, but this is arbitrary.
                                        childCount: 30,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _BottomBar(),
                ],
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
  void addEventOnTap() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EventEdit(
                  title: AppLocalizations.of(context).event,
                ),
            fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 0, right: 8.0, bottom: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TapOnlyTextField(
                onTap: addEventOnTap,
                hintText: AppLocalizations.of(context).addEvent,
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
              onPressed: () {},
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
