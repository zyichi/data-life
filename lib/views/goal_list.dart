import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';
import 'package:data_life/models/goal.dart';

class GoalList extends StatefulWidget {
  final String name;

  GoalList({@required this.name}) : assert(name != null);

  @override
  _GoalListState createState() => _GoalListState();
}

class _GoalListState extends State<GoalList> with AutomaticKeepAliveClientMixin {
  PageBloc<Goal> _goalBloc;

  @override
  void initState() {
    print('GoalList.initState');
    super.initState();

    _goalBloc = BlocProvider.of<PageBloc<Goal>>(context);
    _goalBloc.dispatch(RefreshPage());
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
      bloc: _goalBloc,
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
          return ListView.builder(
            key: PageStorageKey<String>(widget.name),
            itemCount: pagedList.total,
            itemBuilder: (context, index) {
              Goal goal = pagedList.itemAt(index);
              if (goal == null) {
                _goalBloc.getItem(index);
                return Container(
                  alignment: Alignment.centerLeft,
                  height: 48.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text('Loading ...'),
                  ),
                );
              }
              return Container(
                height: 48.0,
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        goal.name,
                      ),
                    ],
                  ),
                ),
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
