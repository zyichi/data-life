import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/location_text_field.dart';
import 'package:data_life/views/common_dialog.dart';

import 'package:data_life/models/action.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/models/moment.dart';
import 'package:data_life/models/todo.dart';

import 'package:data_life/localizations.dart';

import 'package:data_life/blocs/moment_bloc.dart';

class MomentEdit extends StatefulWidget {
  final Moment moment;
  final Todo todo;

  const MomentEdit({
    this.moment,
    this.todo,
  });

  @override
  _MomentEditState createState() {
    return new _MomentEditState();
  }
}

class _SentimentSource {
  const _SentimentSource({this.icon, this.sentiment});

  final Icon icon;
  final Sentiment sentiment;
}

class _MomentEditState extends State<MomentEdit> {
  bool _isReadOnly = false;
  final _formKey = GlobalKey<FormState>();
  final Moment _moment = Moment();
  String _title;

  double _sentimentIconSize = 48.0;

  final _actionNameController = TextEditingController();
  final _actionNameFocusNode = FocusNode();
  final _locationNameController = TextEditingController();
  final _locationNameFocusNode = FocusNode();
  final _contactController = TextEditingController();
  final _contactFocusNode = FocusNode();
  final _costController = TextEditingController();
  final _feelingsController = TextEditingController();

  final _suggestionsBoxController = SuggestionsBoxController();

  MomentBloc _momentBloc;

  @override
  void initState() {
    super.initState();

    _momentBloc = BlocProvider.of<MomentBloc>(context);

    if (widget.moment != null) {
      _isReadOnly = true;

      _actionNameController.text = widget.moment.action.name;
      _locationNameController.text = widget.moment.location.name;
      _costController.text = widget.moment.cost.toString();
      _feelingsController.text = widget.moment.details;

      _moment.copy(widget.moment);
      // We must create new contact list and copy contact to compare
      // old moment and new moment different.
      _moment.contacts = <Contact>[];
      for (Contact contact in widget.moment.contacts) {
        _moment.contacts.add(Contact.copyCreate(contact));
      }

      _title = '动态';
    } else {
      final now = DateTime.now();
      _moment.beginDateTime = now.subtract(Duration(minutes: 60));
      _moment.endDateTime = now;

      if (widget.todo != null) {
        _actionNameController.text = widget.todo.goalAction.action.name;
      }
      _title = '记录新动态';
    }

    _contactController.addListener(_contactControllerListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  @override
  void dispose() {
    _costController.dispose();
    _feelingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_title),
        actions: <Widget>[
          _createSaveAction(),
        ],
      ),
      floatingActionButton: _createFloatingActionButton(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AbsorbPointer(
          absorbing: _isReadOnly,
          child: Form(
            key: _formKey,
            onWillPop: _onWillPop,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16,),
              children: <Widget>[
                widget.todo != null
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: _createEditHint(),
                      )
                    : Container(),
                widget.moment == null && widget.todo == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _createActionNameFormField(),
                          ),
                          Divider(),
                        ],
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _createLocationField(),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _createPeopleFormField(),
                ),
                Divider(),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: FormField(
                    builder: (fieldState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DateTimePickerFormField(
                            labelText: AppLocalizations.of(context).begin,
                            initialDateTime: _moment.beginDateTime,
                            selectDateTime: (value) {
                              _moment.beginDateTime = value;
                              fieldState.didChange(null);
                            },
                          ),
                          DateTimePickerFormField(
                            labelText: AppLocalizations.of(context).end,
                            initialDateTime: _moment.endDateTime,
                            selectDateTime: (value) {
                              _moment.endDateTime = value;
                              fieldState.didChange(null);
                            },
                          ),
                          FormFieldError(
                            errorText: fieldState.errorText,
                          ),
                        ],
                      );
                    },
                    autovalidate: true,
                    validator: (value) {
                      // If to-do is not null, we need to limit time to today.
                      var now = DateTime.now();
                      if (widget.todo != null) {
                        var t = _moment.beginDateTime;
                        if (t.isBefore(DateTime(now.year, now.month, now.day))) {
                          return "任务完成时间必须是今天";
                        }
                      }
                      if (_moment.endDateTime.isAfter(now)) {
                        return '结束时间不能在将来';
                      }
                      if (_moment.beginTime > _moment.endTime) {
                        return '开始时间必须早于结束时间';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 8),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _createExpendFormField(),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _createSentimentFormField(),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _createFeelingsFormField(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _isNewMoment => widget.moment == null;

  void _requestPermissions() async {
    final permissionGroups = [
      PermissionGroup.location,
      PermissionGroup.storage,
      PermissionGroup.phone,
    ];
    Map<PermissionGroup, PermissionStatus> _ =
    await PermissionHandler().requestPermissions(permissionGroups);
  }

  bool _needExitConfirm() {
    if (_isReadOnly) {
      return false;
    }
    _updateMomentFromForm();
    if (_isNewMoment) {
      if (_moment.action != null ||
          _moment.location != null ||
          _moment.sentiment != null ||
          _moment.contacts.isNotEmpty ||
          _moment.details.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      if (_moment.isContentSameWith(widget.moment)) {
        return false;
      } else {
        return true;
      }
    }
  }

  List<Widget> _createSentimentIcons() {
    final widgets = <Widget>[];
    final sentimentSources = [
      _SentimentSource(
        icon: Icon(Icons.sentiment_very_satisfied),
        sentiment: Sentiment.VerySatisfied,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_satisfied),
        sentiment: Sentiment.Satisfied,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_neutral),
        sentiment: Sentiment.Neutral,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_dissatisfied),
        sentiment: Sentiment.Dissatisfied,
      ),
      _SentimentSource(
        icon: Icon(Icons.sentiment_very_dissatisfied),
        sentiment: Sentiment.VeryDissatisfied,
      ),
    ];
    for (var source in sentimentSources) {
      var iconButton = IconButton(
        iconSize: _sentimentIconSize,
        icon: source.icon,
        onPressed: _isReadOnly
            ? () {}
            : () {
          setState(() {
            _moment.sentiment = source.sentiment;
          });
        },
        color: _moment.sentiment == source.sentiment
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      );
      widgets.add(iconButton);
    }
    return widgets;
  }

  num _parseCost(String cost) {
    var value = num.tryParse(cost);
    return value ?? 0.0;
  }

  void _updateMomentFromForm() {
    _moment.duration = _moment.durationInMillis();
    _moment.cost = _parseCost(_costController.text);
    _moment.details = _feelingsController.text;
    if (_moment.action == null) {
      if (_actionNameController.text.isNotEmpty) {
        var a = MyAction();
        a.name = _actionNameController.text;
        _moment.action = a;
      }
    }
    if (_moment.location == null) {
      if (_locationNameController.text.isNotEmpty) {
        var l = Location();
        l.name = _locationNameController.text;
        _moment.location = l;
      }
    }
    if (_contactController.text.isNotEmpty) {
      var contact = Contact();
      contact.name = _contactController.text;
      _addContact(contact);
    }
  }

  void _editMoment() {
    _updateMomentFromForm();
    if (_isNewMoment) {
      _momentBloc.dispatch(
        AddMoment(moment: _moment, todo: widget.todo),
      );
    } else {
      if (_moment.isContentSameWith(widget.moment)) {
        print('Moment content is same, no need to save');
        return;
      }
      _momentBloc.dispatch(UpdateMoment(
        oldMoment: widget.moment,
        newMoment: _moment,
      ));
    }
  }

  Future<bool> _onWillPop() async {
    _suggestionsBoxController.close();

    if (!_needExitConfirm()) {
      return true;
    }

    return await CommonDialog.showEditExitConfirmDialog(context,
        'Are you sure you want to discard your changes to the moment?');
  }

  Widget _createLocationField() {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LabelFormField(
            label: 'Location',
            padding: EdgeInsets.all(0),
          ),
          LocationTextField(
            locationChanged: (Location location) {
              _moment.location = location;
            },
            location: _moment.location,
            addressController: _locationNameController,
            focusNode: _locationNameFocusNode,
            suggestionsBoxController: _suggestionsBoxController,
          ),
        ],
      ),
    );
  }

  Widget _selfInputChip() {
    return InputChip(
      padding: EdgeInsets.only(left: 4.0, right: 4.0),
      label: Text('Me'),
      avatar: Icon(Icons.person),
      deleteIcon: Icon(
        Icons.clear,
        size: 20.0,
      ),
      onPressed: () {},
    );
  }

  void _contactControllerListener() {
    var name = _contactController.text;
    if (name.endsWith(',') || name.endsWith('，')) {
      name = name.replaceAll(',', '');
      name = name.replaceAll('，', '');
      if (name.isNotEmpty) {
        var contact = Contact();
        contact.name = name;
        setState(() {
          _addContact(contact);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _contactController.text = '';
        });
        FocusScope.of(context).requestFocus(_contactFocusNode);
      }
    }
  }

  List<Widget> _selectedContactWidget() {
    List<Widget> widgets = _moment.contacts.map((contact) {
      return InputChip(
        padding: EdgeInsets.only(left: 4.0, right: 4.0),
        label: Text(contact.name),
        avatar: Icon(Icons.person),
        deleteIcon: Icon(
          Icons.clear,
          size: 20.0,
        ),
        onDeleted: _isReadOnly
            ? null
            : () {
          setState(() {
            _moment.contacts.remove(contact);
          });
          FocusScope.of(context).requestFocus(_contactFocusNode);
        },
        onPressed: _isReadOnly
            ? () {}
            : () {
          setState(() {
            _moment.contacts.remove(contact);
            if (_contactController.text.isNotEmpty) {
              var contact = Contact();
              contact.name = _contactController.text;
              _addContact(contact);
            }
          });
          FocusScope.of(context).requestFocus(_contactFocusNode);
          // TODO: Set cursor to the end of text on Android platform.
          _contactController.text = contact.name;
        },
      );
    }).toList(growable: true);
    widgets.insert(0, _selfInputChip());
    return widgets;
  }

  Widget _createPeopleFormField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LabelFormField(
            label: 'People',
            padding: EdgeInsets.all(0),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            children: _selectedContactWidget(),
          ),
          _isReadOnly
              ? Container()
              : TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autocorrect: false,
              controller: _contactController,
              focusNode: _contactFocusNode,
              decoration: InputDecoration(
                hintText: "Enter people, delimited by commas",
                border: InputBorder.none,
              ),
              autofocus: !_isReadOnly,
            ),
            suggestionsBoxDecoration: SuggestionsBoxDecoration(),
            suggestionsCallback: (pattern) {
              return _momentBloc.getContactSuggestions(pattern);
            },
            itemBuilder: (context, suggestion) {
              final Contact contact = suggestion as Contact;
              return Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 8, right: 16, bottom: 8),
                child: Text(
                  contact.name,
                ),
              );
            },
            hideOnEmpty: true,
            hideOnLoading: true,
            getImmediateSuggestions: true,
            onSuggestionSelected: (suggestion) {
              setState(() {
                _contactController.text = '';
                _addContact(suggestion as Contact);
                FocusScope.of(context).requestFocus(_contactFocusNode);
              });
            },
          ),
        ],
      ),
    );
  }

  void _addContact(Contact contact) {
    if (_moment.contacts.contains(contact)) {
      return;
    }
    _moment.contacts.add(contact);
  }

  Widget _createExpendFormField() {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: LabeledTextFormField(
        inputType: TextInputType.number,
        labelText: 'Cost (unit: ${AppLocalizations.of(context).currencyName})',
        hintText: '0.0',
        controller: _costController,
        validator: (value) {
          if (value.isNotEmpty && num.tryParse(value) == null) {
            return 'Please input a valid number';
          } else {
            return null;
          }
        },
      ),
    );
  }

  Widget _createSentimentFormField() {
    return FormField(
      builder: (state) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).sentiment,
            border: InputBorder.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _createSentimentIcons(),
              ),
              FormFieldError(
                errorText: state.errorText,
              ),
            ],
          ),
        );
      },
      validator: (value) {
        if (_moment.sentiment == null) {
          return AppLocalizations.of(context).selectSentiment;
        }
        return null;
      },
    );
  }

  Widget _createFeelingsFormField() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: LabeledTextFormField(
        labelText: AppLocalizations.of(context).detail,
        hintText: 'Say something ...',
        maxLines: 4,
        controller: _feelingsController,
      ),
    );
  }

  Widget _createActionNameFormField() {
    return TypeAheadFormField(
      hideOnEmpty: true,
      hideOnLoading: true,
      getImmediateSuggestions: true,
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
          hintText: 'Enter action',
          border: InputBorder.none,
        ),
        controller: _actionNameController,
        focusNode: _actionNameFocusNode,
        style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
        autofocus: !_isReadOnly && widget.todo == null,
        enabled: _isNewMoment && widget.todo == null,
      ),
      onSuggestionSelected: (MyAction action) {
        _actionNameController.text = action.name;
        _moment.action = action;
      },
      itemBuilder: (context, suggestion) {
        final action = suggestion as MyAction;
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
          child: Text(
            action.name,
          ),
        );
      },
      suggestionsCallback: (pattern) {
        return _momentBloc.getActionSuggestions(pattern);
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter action';
        }
        return null;
      },
    );
  }

  Widget _createSaveAction() {
    if (_isReadOnly) {
      return Container();
    } else {
      return IconButton(
        icon: Icon(Icons.check),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            _editMoment();
            Navigator.of(context).pop(true);
          }
        },
      );
    }
  }

  Widget _createEditHint() {
    return Text(
      '标记任务 ${widget.todo.goalAction.action.name} 为已完成',
      style: TextStyle(
        color: Theme.of(context).primaryColorDark,
      ),
    );
  }

  Widget _createFloatingActionButton() {
    if (_isNewMoment) {
      return Container();
    }
    if (!_isReadOnly) {
      return Container();
    }
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      onPressed: () {
        setState(() {
          _isReadOnly = false;
          _title = '修改动态';
        });
        FocusScope.of(context).requestFocus(_locationNameFocusNode);
      },
      child: Icon(
        Icons.edit,
      ),
    );
  }

}
