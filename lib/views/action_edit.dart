import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/models/action.dart';

import 'package:data_life/blocs/action_bloc.dart';

import 'package:data_life/views/unique_check_form_field.dart';
import 'package:data_life/views/labeled_text_form_field.dart';

class ActionEdit extends StatefulWidget {
  final MyAction action;

  ActionEdit({this.action});

  @override
  _ActionEditState createState() => _ActionEditState();
}

class _ActionEditState extends State<ActionEdit> {
  final _formKey = GlobalKey<FormState>();
  MyAction _action;
  String _title;
  ActionBloc _actionBloc;
  bool _isReadOnly = true;
  FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _action = MyAction.copyCreate(widget.action);
    _title = _action.name;

    _actionBloc = BlocProvider.of<ActionBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          _isReadOnly
              ? IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isReadOnly = false;
                    });
                    FocusScope.of(context).requestFocus(_nameFocusNode);
                  },
                )
              : IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _editAction();
                      Navigator.of(context).pop();
                    }
                  },
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LabelFormField(
                label: 'Name',
              ),
              UniqueCheckFormField(
                initialValue: _action.name,
                focusNode: _nameFocusNode,
                autofocus: false,
                enabled: !_isReadOnly,
                hintText: 'Enter action name',
                validator: (String text, bool isUnique) {
                  if (text.isEmpty) {
                    return 'Action name can not empty';
                  }
                  if (!isUnique && text != widget.action?.name) {
                    return 'Action name already exist';
                  }
                  return null;
                },
                uniqueCheckCallback: (String text) async {
                  return _actionBloc.actionNameUniqueCheck(text);
                },
                textChanged: _actionNameChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  void _actionNameChanged(String text) {
    _action.name = text;
    if (_action.name.isNotEmpty) {
      setState(() {
        _title = _action.name;
      });
    } else {
      setState(() {
        _title = 'Action';
      });
    }
  }

  void _editAction() {
    _actionBloc
        .dispatch(UpdateAction(oldAction: widget.action, newAction: _action));
  }
}
