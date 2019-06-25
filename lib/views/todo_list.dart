import 'package:flutter/material.dart';


class ToDoList extends StatefulWidget {
  final String name;

  ToDoList({this.name}) : assert(name != null);

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('${widget.name}'),
    );
  }
}
