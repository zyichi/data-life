import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';
import 'package:data_life/blocs/todo_bloc.dart';

import 'package:data_life/views/moment_edit.dart';

import 'package:data_life/models/todo.dart';

class _TodoListItem extends StatelessWidget {
  final Todo todo;
  final TodoBloc todoBloc;

  _TodoListItem({this.todo, this.todoBloc})
      : assert(todo != null),
        assert(todoBloc != null);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: _buildListItem(context),
    );
  }

  Widget _buildStatus(BuildContext context, TodoStatus status) {
    var statusStr;
    var statusColor;
    var statusIconData;
    if (todo.status == TodoStatus.dismiss) {
      statusStr = '已放弃';
      statusColor = Theme.of(context).accentColor;
      statusIconData = Icons.do_not_disturb;
    } else {
      statusStr = '${DateFormat(DateFormat.HOUR_MINUTE).format(todo.doneDateTime)}已完成';
      statusColor = Theme.of(context).primaryColor;
      statusIconData = Icons.done;
    }
    return Row(
      children: <Widget>[
        Icon(statusIconData,
          color: statusColor,
        ),
        SizedBox(width: 8),
        Text(
          statusStr,
          style: TextStyle(
            color: statusColor,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context) {
    if (todo == null) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 48.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 8.0, bottom: 8.0),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              todo.goalAction.action.name,
              style: Theme.of(context).textTheme.title,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
            ),
            SizedBox(height: 8),
            Text(
              '${DateFormat(DateFormat.HOUR_MINUTE).format(todo.startDateTime)}开始, 目标: ${todo.goal.name}',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            todo.status == TodoStatus.waiting ? _buildButton(context) : _buildStatus(context, todo.status),
          ],
        ),
      );
    }
  }

  Widget _buildButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
          child: Text(
            '放弃',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            todoBloc.dispatch(DismissTodo(todo: todo));
          },
        ),
        SizedBox(width: 32),
        FlatButton(
          color: Theme.of(context).primaryColor,
          child: Text(
            '标记为已完成',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              PageTransition(
                child: MomentEdit(
                  moment: null,
                  todo: todo,
                ),
                type: PageTransitionType.rightToLeft,
              ),
            );
          },
        ),
      ],
    );
  }
}

class TodoList extends StatefulWidget {
  final String name;

  TodoList({@required this.name}) : assert(name != null);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>
    with AutomaticKeepAliveClientMixin {
  PageBloc<Todo> _todoListBloc;
  TodoBloc _todoBloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    super.initState();

    _todoListBloc = BlocProvider.of<PageBloc<Todo>>(context);
    _todoBloc = BlocProvider.of<TodoBloc>(context);
    _todoListBloc.dispatch(RefreshPage());
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
    return Material(
      color: Colors.grey[200],
      child: BlocListener(
        bloc: _todoListBloc,
        listener: (context, state) {
          if (state is PageLoaded || state is PageError) {
            _refreshCompleter?.complete();
            _refreshCompleter = null;
          }
        },
        child: RefreshIndicator(
          onRefresh: () {
            _refreshCompleter = Completer<void>();
            // _todoBloc.dispatch(CreateTodayTodo());
            _todoListBloc.dispatch(RefreshPage());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
            bloc: _todoListBloc,
            builder: (context, state) {
              if (state is PageUninitialized) {
                return _createEmptyResults();
              }
              if (state is PageLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is PageLoaded<Todo>) {
                PageList pagedList = state.pageList;
                if (pagedList.total == 0) {
                  return _createEmptyResults();
                }
                return ListView.separated(
                  key: PageStorageKey<String>(widget.name),
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 16,
                      color: Colors.grey[200],
                    );
                  },
                  itemCount: pagedList.total,
                  itemBuilder: (context, index) {
                    Todo todo = pagedList.itemAt(index);
                    if (todo == null) {
                      _todoListBloc.getItem(index);
                    }
                    return _TodoListItem(
                      todo: todo,
                      todoBloc: _todoBloc,
                    );
                  },
                );
              }
              if (state is PageError) {
                return Center(
                  child: Text('Load todo failed'),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _createEmptyResults() {
    return Center(
      child: Text(
        '今天无任务',
        style: Theme.of(context).textTheme.display2,
      ),
    );
  }
}
