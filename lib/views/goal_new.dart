import 'package:flutter/material.dart';

import 'package:data_life/models/old_goal.dart';
import 'package:data_life/services/goal_service.dart';
import 'package:data_life/localizations.dart';
import 'package:data_life/blocs/goal_bloc.dart';

const double _kFabMiniLayoutSize = 48;

typedef OnTapCallback(String data, int index);

class _ActivityAttrWidget extends StatefulWidget {
  final String title;
  final OldGoal goal;
  final List<String> items;
  final OnTapCallback itemOnTap;
  final bool isCustomItem;
  final ValueChanged<String> selectCustomItem;

  const _ActivityAttrWidget(
      {Key key,
      this.title,
      this.goal,
      this.items,
      this.itemOnTap,
      this.isCustomItem = false,
      this.selectCustomItem})
      : super(key: key);

  @override
  _ActivityAttrWidgetState createState() {
    return new _ActivityAttrWidgetState();
  }
}

class _ActivityAttrWidgetState extends State<_ActivityAttrWidget> {
  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Widget> _createListWidgets(BuildContext context) {
    final widgets = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      var item = widget.items[i];
      widgets.add(InkWell(
          child: Padding(
            padding: const EdgeInsets.only(left: 48.0, top: 16.0, bottom: 16.0),
            child: Text(
              item,
            ),
          ),
          onTap: () {
            widget.itemOnTap(item, i);
          }));
    }
    return widgets;
  }

  Widget _buildTitleWidget(BuildContext context) {
    var decoration = InputDecoration(
      border: InputBorder.none,
      hintText: widget.title,
    );
    bool autoFocus = false;
    if (!widget.isCustomItem) {
      decoration =
          decoration.copyWith(hintStyle: Theme.of(context).textTheme.headline.copyWith(fontSize: 28.0));
      _controller.clear();
    } else {
      autoFocus = true;
    }
    final textField = TextField(
      decoration: decoration,
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (text) {
        setState(() {});
      },
      style: Theme.of(context).textTheme.headline.copyWith(fontSize: 28.0),
      enabled: widget.isCustomItem,
      autofocus: autoFocus,
    );
    if (widget.isCustomItem) {
      setState(() {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
    return textField;
  }

  Widget _buildCustomInputWidget(BuildContext context) {
    if (widget.isCustomItem) {
      return Container(
        height: _kFabMiniLayoutSize,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              top: _kFabMiniLayoutSize / 2,
              right: 0,
              child: Divider(
                height: 1,
              ),
            ),
            _controller.text.isNotEmpty
                ? Positioned(
                    right: 16.0,
                    child: FloatingActionButton(
                      child: Icon(Icons.done),
                      mini: true,
                      onPressed: () {
                        widget.selectCustomItem(_controller.text);
                      },
                    ),
                  )
                : Container()
          ],
        ),
      );
    } else {
      return SizedBox(
        height: _kFabMiniLayoutSize / 2.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            InkWell(
              child: Padding(
                padding: const EdgeInsets.only(left: 48.0, top: 32.0),
                child: _buildTitleWidget(context),
              ),
            ),
            _buildCustomInputWidget(context),
            Expanded(
              child: ListView(
                children: _createListWidgets(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitySummaryPage extends StatefulWidget {
  final OldGoal goal;

  const _ActivitySummaryPage({Key key, this.goal});

  @override
  _ActivitySummaryPageState createState() {
    return new _ActivitySummaryPageState();
  }
}

class _ActivitySummaryPageState extends State<_ActivitySummaryPage> {


  Future _saveGoal() async {
    widget.goal.progress = 0;
    widget.goal.timeSpent = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    widget.goal.lastActiveTime = now;
    widget.goal.createTime = now;
    final goalService = GoalService();
    // await goalService.insert(widget.goal);
    if (widget.goal.id != null) {
      GoalProvider.of(context).invalid.add(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 48.0, top: 32.0, bottom: 8.0),
            child: Text(
              widget.goal.activityName,
              style: Theme.of(context).textTheme.headline.copyWith(fontSize: 28.0),
            ),
          ),
          Container(
            height: _kFabMiniLayoutSize,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  top: _kFabMiniLayoutSize / 2,
                  right: 0,
                  child: Divider(
                    height: 1,
                  ),
                ),
                Positioned(
                  right: 16.0,
                  child: FloatingActionButton(
                    child: Icon(Icons.done),
                    mini: true,
                    onPressed: () {
                      _saveGoal();
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).goalSummary,
                  style: Theme.of(context).textTheme.title,
                ),
                SizedBox(height: 8.0,),
                Text(
                  getHowOftenLiteral(context, widget.goal.howOften),
                ),
                Text(
                  '${getHowLongLiteral(context, widget.goal.howLong)}, ${getBestTimeLiteral(context, widget.goal.bestTime)}'
                ),
              ],
            ),
          ),
          SizedBox(height: 32.0,),
          InkWell(
            child: Padding(
              padding: const EdgeInsets.only(left: 48.0, top: 8.0, bottom: 8.0),
              child: Text(
                AppLocalizations.of(context).moreOptionsLiteral.toUpperCase(),
                style: Theme.of(context).textTheme.title.copyWith(fontSize: 18.0),
              ),
            ),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}

class _BestTimePage extends StatefulWidget {
  final OldGoal goal;

  const _BestTimePage({Key key, this.goal});

  @override
  _BestTimePageState createState() {
    return new _BestTimePageState();
  }
}

class _BestTimePageState extends State<_BestTimePage> {

  @override
  void initState() {
    super.initState();
  }

  List<String> _createOptions() {
    return bestTimeOptions.map((bestTime) {
      return getBestTimeLiteral(context, bestTime);
    }).toList();
  }

  void itemOnTap(String item, int index) {
    widget.goal.bestTime = bestTimeOptions[index];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return _ActivitySummaryPage(
          goal: widget.goal,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActivityAttrWidget(
      title: AppLocalizations.of(context).bestTime,
      goal: widget.goal,
      items: _createOptions(),
      itemOnTap: itemOnTap,
    );
  }
}

class _ForHowLongPage extends StatefulWidget {
  final OldGoal goal;

  const _ForHowLongPage({Key key, this.goal});

  @override
  _ForHowLongPageState createState() {
    return new _ForHowLongPageState();
  }
}

class _ForHowLongPageState extends State<_ForHowLongPage> {

  List<String> _createHowLongOptions() {
    return howLongOptions.map((howLong) {
      return getHowLongLiteral(context, howLong);
    }).toList();
  }

  void itemOnTap(String item, int index) {
    widget.goal.howLong = howLongOptions[index];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return _BestTimePage(
          goal: widget.goal,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ActivityAttrWidget(
      title: AppLocalizations.of(context).forHowLong,
      goal: widget.goal,
      items: _createHowLongOptions(),
      itemOnTap: itemOnTap,
    );
  }
}

class _HowOftenPage extends StatefulWidget {
  final OldGoal goal;

  const _HowOftenPage({Key key, this.goal});

  @override
  _HowOftenPageState createState() {
    return new _HowOftenPageState();
  }
}

class _HowOftenPageState extends State<_HowOftenPage> {
  bool optionExtended = false;

  @override
  void initState() {
    super.initState();
  }

  List<String> getDefaultOptions() {
    final defaultOptions = howOftenOptions.map((howOften) {
      return getHowOftenLiteral(context, howOften);
    }).toList(growable: true);
    defaultOptions.add(AppLocalizations.of(context).moreOptions);
    return defaultOptions;
  }

  List<String> getAllOptions() {
    final allOptions = howOftenAllOptions.map((howOften) {
      return getHowOftenLiteral(context, howOften);
    }).toList(growable: true);
    return allOptions;
  }

  List<String> _getOptions() {
    if (optionExtended) {
      return getAllOptions();
    } else {
      return getDefaultOptions();
    }
  }

  void itemOnTap(String item, int index) {
    if (item == AppLocalizations.of(context).moreOptions) {
      setState(() {
        optionExtended = true;
      });
    } else {
      if (optionExtended) {
        widget.goal.howOften = howOftenAllOptions[index];
      } else {
        widget.goal.howOften = howOftenOptions[index];
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) {
          return _ForHowLongPage(
            goal: widget.goal,
          );
        }),
      );
    }
  }

  Future<bool> _handlePopUp() async {
    if (optionExtended) {
      setState(() {
        optionExtended = false;
      });
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _onWillPop() {
    return _handlePopUp();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: _ActivityAttrWidget(
        title: AppLocalizations.of(context).howOften,
        goal: widget.goal,
        items: _getOptions(),
        itemOnTap: itemOnTap,
      ),
    );
  }
}

class _ActivityPage extends StatefulWidget {
  final OldGoal goal;

  const _ActivityPage({Key key, this.goal});

  @override
  _ActivityPageState createState() {
    return new _ActivityPageState();
  }
}

class _ActivityPageState extends State<_ActivityPage> {
  bool _isCustom = false;
  List<ActivityType> types;

  @override
  void initState() {
    super.initState();
  }

  String _getTitle(GoalType goalType) {
    switch (goalType) {
      case GoalType.exercise: return AppLocalizations.of(context).whichExercise;
      case GoalType.skill: return AppLocalizations.of(context).whichSkill;
      case GoalType.familyAndFriends: return AppLocalizations.of(context).whichActivity;
      case GoalType.meTime: return AppLocalizations.of(context).whichActivity;
      case GoalType.organizeMyLife: return AppLocalizations.of(context).whichActivity;
      default: return null;
    }
  }

  List<String> _getActivityNames() {
    List<String> names;
    if (_isCustom) {
      types = getGoalExtraActivities(widget.goal.type);
      names = types.map((activityType) {
        return getActivityLiteral(context, activityType);
      }).toList();
    } else {
      types = getGoalActivities(widget.goal.type);
      names = types.map((activityType) {
        return getActivityLiteral(context, activityType);
      }).toList(growable: true);
      names.add(AppLocalizations.of(context).customActivity);
    }
    return names;
  }

  void itemOnTap(String item, int index) {
    if (item == AppLocalizations.of(context).customActivity) {
      setState(() {
        _isCustom = true;
      });
    } else {
      widget.goal.activityType = types[index];
      widget.goal.activityName = item;
      _toHowOftenPage();
    }
  }

  void _toHowOftenPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) {
        return _HowOftenPage(
          goal: widget.goal,
        );
      }),
    );
  }

  void _selectCustomItem(String value) {
    widget.goal.activityName = value;
    _toHowOftenPage();
  }

  Future<bool> _handlePopUp() async {
    if (_isCustom) {
      setState(() {
        _isCustom = false;
      });
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _onWillPop() {
    return _handlePopUp();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: _ActivityAttrWidget(
        title: _getTitle(widget.goal.type),
        goal: widget.goal,
        items: _getActivityNames(),
        itemOnTap: itemOnTap,
        isCustomItem: _isCustom,
        selectCustomItem: _selectCustomItem,
      ),
    );
  }
}

class GoalPage extends StatelessWidget {
  static const routeName = '/newGoal';

  List<Widget> _createGoalWidgets(BuildContext context) {
    final goalWidgets = <Widget>[];
    for (var goalType in goalTypes) {
      goalWidgets.add(InkWell(
          child: ListTile(
            title: Text(getGoalTypeLiteral(context, goalType)),
            subtitle: Text(getGoalTypeCaption(context, goalType)),
          ),
          onTap: () {
            final goal = OldGoal();
            goal.type = goalType;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) {
                return _ActivityPage(
                  goal: goal,
                );
              }),
            );
          }));
    }
    return goalWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).selectGoal,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: ListView(
          children: _createGoalWidgets(context),
        ),
      ),
    );
  }
}
