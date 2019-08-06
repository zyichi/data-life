import 'package:flutter/material.dart';

import 'package:data_life/views/action_list.dart';


class ActionPage extends StatefulWidget {
  static final String routeName = '/action';

  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  final String _title = 'Actions';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: ActionList(name: _title),
    );
  }
}
