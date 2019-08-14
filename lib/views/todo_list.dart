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

  Widget _createItem(BuildContext context) {
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
      return GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.only(left: 0.0, top: 0.0, bottom: 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            todo.goal.name ?? '',
                            style: Theme.of(context).textTheme.title,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        ),
                        todo.status == TodoStatus.waiting
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 24,
                                ),
                                onPressed: () {
                                  todoBloc.dispatch(DismissTodo(todo: todo));
                                },
                              )
                            : Container(height: 40),
                      ],
                    ),
                    Text(
                      '${todo.goalAction.action.name} at ${DateFormat(DateFormat.HOUR_MINUTE).format(DateTime.fromMillisecondsSinceEpoch(todo.startTime))}',
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ],
                ),
              ),
              todo.status == TodoStatus.waiting
                  ? FlatButton(
                      child: Text(
                        'Mark as done'.toUpperCase(),
                        style: Theme.of(context).textTheme.button.copyWith(
                            color: Theme.of(context).primaryColorDark),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8),
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
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        'Done on ${DateFormat(DateFormat.HOUR_MINUTE).format(DateTime.fromMillisecondsSinceEpoch(todo.doneTime))}',
                        style: Theme.of(context)
                            .textTheme
                            .button
                            .copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      child: _createItem(context),
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
    return BlocListener(
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
                  return Divider();
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
    );
  }

  Widget _createEmptyResults() {
    return Center(
      child: Text('No tasks',
        style: Theme.of(context).textTheme.display2,
      ),
    );
  }
}
