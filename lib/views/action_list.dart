import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/models/action.dart';

import 'package:data_life/views/action_edit.dart';

import 'package:data_life/utils/time_util.dart';

class _ActionListItem extends StatelessWidget {
  final MyAction action;

  _ActionListItem({this.action});

  @override
  Widget build(BuildContext context) {
    if (action == null) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 48.0,
        child: Padding(
          padding:
          const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                child: ActionEdit(
                  action: action,
                ),
                type: PageTransitionType.rightToLeft,
              ));
        },
        child: Padding(
          padding:
          const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                action.name,
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 8),
              _createLastActiveTimeWidget(context),
              SizedBox(height: 8),
              _createTotalTimeTakenWidget(context),
            ],
          ),
        ),
      );
    }
  }

  Widget _createLastActiveTimeWidget(BuildContext context) {
    String s;
    if (action.lastActiveTime == 0) {
      s = '未活动';
    } else {
      s = TimeUtil.dateStringFromMillis(action.lastActiveTime) +
          ' ' +
          TimeUtil.timeStringFromMillis(action.lastActiveTime, context);
    }
    return Text(
      '最近活动: $s',
    );
  }

  Widget _createTotalTimeTakenWidget(BuildContext context) {
    return Text(
      "共花时间: ${TimeUtil.formatMillisToDHM(action.totalTimeTaken, context)}",
      style: Theme.of(context).textTheme.caption,
    );
  }
}

class ActionList extends StatefulWidget {
  final String name;

  ActionList({@required this.name}) : assert(name != null);

  @override
  _ActionListState createState() => _ActionListState();
}

class _ActionListState extends State<ActionList>
    with AutomaticKeepAliveClientMixin {
  PageBloc<MyAction> _actionListBloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();

    _actionListBloc = BlocProvider.of<PageBloc<MyAction>>(context);
    _actionListBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener(
      bloc: _actionListBloc,
      listener: (context, state) {
        if (state is PageLoaded || state is PageError) {
          _refreshCompleter?.complete();
          _refreshCompleter = null;
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 8),
        child: RefreshIndicator(
          onRefresh: () {
            _refreshCompleter = Completer<void>();
            _actionListBloc.dispatch(RefreshPage());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
            bloc: _actionListBloc,
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
              if (state is PageLoaded<MyAction>) {
                PageList pagedList = state.pageList;
                return ListView.separated(
                  key: PageStorageKey<String>(widget.name),
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: pagedList.total,
                  itemBuilder: (context, index) {
                    MyAction action = pagedList.itemAt(index);
                    if (action == null) {
                      _actionListBloc.getItem(index);
                    }
                    return _ActionListItem(
                      action: action,
                    );
                  },
                );
              }
              if (state is PageError) {
                return Center(
                  child: Text('Load action failed'),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
