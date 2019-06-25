import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/models/goal.dart';

import 'package:data_life/views/my_color.dart';
import 'package:data_life/views/goal_edit.dart';

class _GoalListItem extends StatelessWidget {
  final Goal goal;

  _GoalListItem({this.goal});

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 48.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 8.0, bottom: 8.0),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => GoalEdit(goal: goal),
                  fullscreenDialog: true));
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 8.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                goal.name,
                style:
                    Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class GoalList extends StatefulWidget {
  final String name;

  GoalList({@required this.name}) : assert(name != null);

  @override
  _GoalListState createState() => _GoalListState();
}

class _GoalListState extends State<GoalList>
    with AutomaticKeepAliveClientMixin {
  PageBloc<Goal> _goalListBloc;

  @override
  void initState() {
    print('GoalList.initState');
    super.initState();

    _goalListBloc = BlocProvider.of<PageBloc<Goal>>(context);
    _goalListBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    print('GoalList.dispose');
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print('GoalList.build');
    super.build(context);
    return BlocBuilder(
      bloc: _goalListBloc,
      builder: (context, state) {
        if (state is PageUninitialized) {
          return Center(
            child: Text('No results'),
          );
        }
        if (state is PageLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is PageLoaded<Goal>) {
          PageList pagedList = state.pageList;
          return ListView.separated(
            key: PageStorageKey<String>(widget.name),
            separatorBuilder: (context, index) {
              return Divider(
                color: MyColor.greyDivider,
              );
            },
            itemCount: pagedList.total,
            itemBuilder: (context, index) {
              Goal goal = pagedList.itemAt(index);
              if (goal == null) {
                _goalListBloc.getItem(index);
              }
              return _GoalListItem(
                goal: goal,
              );
            },
          );
        }
        if (state is PageError) {
          return Center(
            child: Text('Load goal failed'),
          );
        }
      },
    );
  }
}
