import 'package:flutter/material.dart';
import 'package:data_life/models/moment.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:data_life/localizations.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/common_form_field.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/moment_contact.dart';

import 'package:data_life/repositories/action_repository.dart';
import 'package:data_life/repositories/action_provider.dart';
import 'package:data_life/repositories/contact_repository.dart';
import 'package:data_life/repositories/contact_provider.dart';
import 'package:data_life/repositories/moment_repository.dart';
import 'package:data_life/repositories/moment_provider.dart';
import 'package:data_life/repositories/location_provider.dart';
import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/views/location_text_field.dart';
import 'package:data_life/models/location.dart';


class MomentEdit extends StatefulWidget {
  final Moment moment;

  const MomentEdit({
    this.moment,
  });

  @override
  MomentEditState createState() {
    return new MomentEditState();
  }
}

class _SentimentSource {
  const _SentimentSource({this.icon, this.sentiment});

  final Icon icon;
  final Sentiment sentiment;
}

class MomentEditState extends State<MomentEdit> {
  bool _isReadOnly = false;
  DateTime _beginDate;
  TimeOfDay _beginTime;
  DateTime _endDate;
  TimeOfDay _endTime;
  double _sentimentIconSize = 48.0;
  final _actionNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _contactFocusNode = FocusNode();
  final _costController = TextEditingController();
  Sentiment _selectedSentiment;
  final _feelingsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _contacts = List<Contact>();
  Action _selectedAction;
  bool _isNewMoment = false;
  Location _location;
  final _addressController = TextEditingController();

  ActionRepository _actionRepository;
  ContactRepository _contactRepository;
  MomentRepository _momentRepository;
  LocationRepository _locationRepository;

  @override
  void initState() {
    super.initState();

    _actionRepository = ActionRepository(ActionProvider());
    _contactRepository = ContactRepository(ContactProvider());
    _momentRepository = MomentRepository(MomentProvider());
    _locationRepository = LocationRepository(LocationProvider());

    if (widget.moment != null) {
      _isReadOnly = true;
      _actionNameController.text = widget.moment.action.name;
      _beginDate = DateTime.fromMillisecondsSinceEpoch(widget.moment.beginTime);
      _endDate = DateTime.fromMillisecondsSinceEpoch(widget.moment.endTime);
      _beginTime = TimeOfDay(hour: _beginDate.hour, minute: _beginDate.minute);
      _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
      _costController.text = widget.moment.cost.toString();
      _feelingsController.text = widget.moment.details;
      _selectedSentiment = widget.moment.sentiment;
      _selectedAction = widget.moment.action;
      _location = widget.moment.location;
      widget.moment.contacts.forEach((item) {
        _contacts.add(Contact.copyCreate(item));
      });
    } else {
      _isNewMoment = true;
      final now = DateTime.now();
      _beginDate = now;
      _endDate = now;
      _beginTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _endTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _selectedSentiment = null;
    }
    _contactController.addListener(_contactControllerListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissions();
    });
  }

  @override
  void dispose() {
    _costController.dispose();
    _feelingsController.dispose();
    super.dispose();
  }

  void requestPermissions() async {
    final permissionGroups = [
      PermissionGroup.location,
      PermissionGroup.storage,
      PermissionGroup.phone,
    ];
    Map<PermissionGroup, PermissionStatus> _ =
        await PermissionHandler().requestPermissions(permissionGroups);
  }

  bool needExitConfirm() {
    if (_isReadOnly) {
      return false;
    }
    if (_isNewMoment) {
      var m = _currentMoment();
      if (m.action != null ||
          m.location != null ||
          m.contacts.isNotEmpty ||
          m.details.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      if (Moment.isSameMoment(_currentMoment(), widget.moment)) {
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
                  _selectedSentiment = source.sentiment;
                });
              },
        color: _selectedSentiment == source.sentiment
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      );
      widgets.add(iconButton);
    }
    return widgets;
  }

  num parseCost(String cost) {
    var value = num.tryParse(cost);
    return value ?? 0.0;
  }

  int getTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute)
        .millisecondsSinceEpoch;
  }

  // XXX NOTE: This current moment is only for exit confirm compare.
  Moment _currentMoment() {
    final moment = Moment();
    if (_location == null) {
      _location = Location();
      _location.displayAddress = _addressController.text;
    }
    moment.location = _location;
    moment.sentiment = _selectedSentiment;
    moment.beginTime = getTime(_beginDate, _beginTime);
    moment.endTime = getTime(_endDate, _endTime);
    moment.cost = parseCost(_costController.text);
    moment.details = _feelingsController.text;
    final action = Action();
    action.name = _actionNameController.text;
    moment.action = action;
    moment.actionId = _selectedAction?.id;
    moment.contacts = _contacts;
    return moment;
  }

  Future<void> _saveAction(Moment moment, int now) async {
    if (_selectedAction == null) {
      _selectedAction = Action();
      _selectedAction.name = _actionNameController.text;
    }
    if (_selectedAction.id == null) {
      Action savedAction = await _actionRepository.getViaName(_actionNameController.text);
      if (savedAction != null) {
        _selectedAction.copy(savedAction);
      }
    }
    if (_selectedAction.id == null) {
      _selectedAction.createTime = now;
      _selectedAction.lastActiveTime = moment.beginTime;
    } else {
      _selectedAction.updateTime = now;
      if (_selectedAction.lastActiveTime == null) {
        _selectedAction.lastActiveTime = moment.beginTime;
      } else {
        if (_selectedAction.lastActiveTime < moment.beginTime) {
          _selectedAction.lastActiveTime = moment.beginTime;
        }
      }
    }
    if (_isNewMoment) {
      _selectedAction.totalTimeSpend += moment.durationInMillis();
    } else {
      if (_selectedAction.id == widget.moment.action.id) {
        // Action not change.
        _selectedAction.totalTimeSpend = _selectedAction.totalTimeSpend -
            widget.moment.durationInMillis() +
            moment.durationInMillis();
      } else {
        // Action changed.
        _selectedAction.totalTimeSpend += moment.durationInMillis();
        Action oldAction = widget.moment.action;
        oldAction.totalTimeSpend -= widget.moment.durationInMillis();
        oldAction.lastActiveTime = await _momentRepository.getActionLastActiveTime(oldAction.id, widget.moment.id);
        await _actionRepository.save(oldAction);
      }
    }
    await _actionRepository.save(_selectedAction);
    moment.actionId = _selectedAction.id;
    moment.action = _selectedAction;
  }

  Future<void> _saveLocation(Moment moment, int now) async {
    if (_location == null) {
      _location = Location();
      _location.displayAddress = _addressController.text;
    }
    if (_location.id == null) {
      Location savedLocation = await _locationRepository
          .getViaDisplayAddress(_location.displayAddress);
      if (savedLocation != null) {
        _location.copy(savedLocation);
      }
    }
    if (_location.id == null) {
      _location.createTime = now;
      _location.lastVisitTime = moment.beginTime;
    } else {
      _location.updateTime = now;
      if (_location.lastVisitTime == null) {
        _location.lastVisitTime = moment.beginTime;
      } else {
        if (_location.lastVisitTime < moment.beginTime) {
          _location.lastVisitTime = moment.beginTime;
        }
      }
    }
    if (_isNewMoment) {
      _location.totalTimeStay += moment.durationInMillis();
    } else {
      if (_location.id == widget.moment.location.id) {
        // Location not change
        _location.totalTimeStay = _location.totalTimeStay -
            widget.moment.durationInMillis() +
            moment.durationInMillis();
      } else {
        // Location changed
        _location.totalTimeStay += moment.durationInMillis();
        Location oldLocation = widget.moment.location;
        oldLocation.totalTimeStay -=
            widget.moment.durationInMillis();
        oldLocation.lastVisitTime = await _momentRepository.getLocationLastVisitTime(oldLocation.id, widget.moment.id);
        await _locationRepository.save(oldLocation);
      }
    }
    await _locationRepository.save(_location);
    moment.locationId = _location.id;
    moment.location = _location;
  }

  Future<void> _saveContact(Moment moment, int now) async {
    // Add contact not submitted to contacts list. This happens when
    // inputted name not end with comma.
    if (_contactController.text.isNotEmpty) {
      var contact = Contact();
      contact.name = _contactController.text;
      _addContact(contact);
    }
    for (Contact contact in _contacts) {
      Contact savedContact;
      if (contact.id == null) {
        savedContact = await _contactRepository.getViaName(contact.name);
        if (savedContact != null) {
          contact.copy(savedContact);
        }
      }
      if (contact.id != null) {
        // Existed contact
        contact.updateTime = now;
        if (contact.lastMeetTime == null) {
          contact.lastMeetTime = moment.beginTime;
        } else {
          if (contact.lastMeetTime < moment.beginTime) {
            contact.lastMeetTime = moment.beginTime;
          }
        }
      } else {
        // New contact
        contact.createTime = now;
        contact.lastMeetTime = moment.beginTime;
      }
    }
    if (_isNewMoment) {
      for (Contact contact in _contacts) {
        contact.totalTimeTogether += moment.durationInMillis();
        await _contactRepository.save(contact);
        var momentContact = MomentContact();
        momentContact.momentId = moment.id;
        momentContact.contactId = contact.id;
        momentContact.momentBeginTime = moment.beginTime;
        momentContact.createTime = now;
        await _momentRepository.saveMomentContact(momentContact);
      }
    } else {
      List<Contact> added =
          _calculateAddedContact(widget.moment.contacts, _contacts);
      List<Contact> removed =
          _calculateRemovedContact(widget.moment.contacts, _contacts);
      for (Contact contact in _contacts) {
        if (added.contains(contact)) {
          contact.totalTimeTogether += moment.durationInMillis();
          await _contactRepository.save(contact);
          var momentContact = MomentContact();
          momentContact.momentId = moment.id;
          momentContact.contactId = contact.id;
          momentContact.momentBeginTime = moment.beginTime;
          momentContact.createTime = now;
          await _momentRepository.saveMomentContact(momentContact);
        } else {
          contact.totalTimeTogether = contact.totalTimeTogether -
              widget.moment.durationInMillis() +
              moment.durationInMillis();
          await _contactRepository.save(contact);
        }
      }
      for (Contact contact in removed) {
        contact.totalTimeTogether -= widget.moment.durationInMillis();
        await _momentRepository.deleteMomentContact(moment.id, contact.id);
        contact.lastMeetTime = await _momentRepository.getContactLastMeetTime(contact.id, moment.id);
        await _contactRepository.save(contact);
      }
    }
    moment.contacts = _contacts;
  }

  List<Contact> _calculateRemovedContact(List<Contact> lhs, List<Contact> rhs) {
    var removed = <Contact>[];
    for (Contact l in lhs) {
      bool found = false;
      for (Contact r in rhs) {
        if (l.id == r.id) {
          found = true;
          break;
        }
      }
      if (!found) {
        removed.add(l);
      }
    }
    return removed;
  }

  List<Contact> _calculateAddedContact(List<Contact> lhs, List<Contact> rhs) {
    var added = <Contact>[];
    for (Contact r in rhs) {
      bool found = false;
      for (Contact l in lhs) {
        if (r.id == l.id) {
          found = true;
        }
      }
      if (!found) {
        added.add(r);
      }
    }
    return added;
  }

  // TODO: Use transaction to resolve database fail.
  Future<void> _saveMoment() async {
    try {
      final now = DateTime
          .now()
          .millisecondsSinceEpoch;
      final moment = Moment();
      moment.sentiment = _selectedSentiment;
      moment.beginTime = getTime(_beginDate, _beginTime);
      moment.endTime = getTime(_endDate, _endTime);
      moment.cost = parseCost(_costController.text);
      moment.details = _feelingsController.text;
      if (_isNewMoment) {
        moment.createTime = now;
      } else {
        moment.id = widget.moment.id;
        moment.createTime = widget.moment.createTime;
        moment.updateTime = now;
      }
      await _saveAction(moment, now);
      await _saveLocation(moment, now);
      // We need save moment first to get Moment.id for later contact progress.
      await _momentRepository.save(moment);
      await _saveContact(moment, now);
    } catch (e) {
      print('MomentEdit._saveMoment failed: ${e.toString()}');
    }
  }

  Future<bool> _onWillPop() async {
    if (!needExitConfirm()) {
      return true;
    }

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                'Are you sure you want to discard this moment?',
                style: dialogTextStyle,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(AppLocalizations.of(context).keepEditing),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text(AppLocalizations.of(context).discard),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  Widget _createLocationField() {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: 16, right: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LabelFormField(
            label: 'Location',
            padding: EdgeInsets.all(0),
          ),
          LocationTextField(
            locationChanged: (Location location) {
              _location = location;
            },
            location: _location,
            addressController: _addressController,
            enabled: !_isReadOnly,
          ),
        ],
      ),
    );
  }

  Widget _selfInputChip() {
    return InputChip(
      padding: EdgeInsets.only(left: 4.0, right: 4.0),
      backgroundColor: Colors.grey[200],
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
    List<Widget> widgets = _contacts.map((contact) {
      return InputChip(
        padding: EdgeInsets.only(left: 4.0, right: 4.0),
        backgroundColor: Colors.grey[200],
        label: Text(contact.name),
        avatar: Icon(Icons.person),
        deleteIcon: Icon(
          Icons.clear,
          size: 20.0,
        ),
        onDeleted: _isReadOnly
            ? () {}
            : () {
                setState(() {
                  _contacts.remove(contact);
                });
                FocusScope.of(context).requestFocus(_contactFocusNode);
              },
        onPressed: _isReadOnly
            ? () {}
            : () {
                setState(() {
                  _contacts.remove(contact);
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
      padding:
          const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
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
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autocorrect: false,
              controller: _contactController,
              focusNode: _contactFocusNode,
              decoration: InputDecoration(
                hintText: "Enter people, delimited by commas",
                border: InputBorder.none,
              ),
              enabled: !_isReadOnly,
              autofocus: !_isReadOnly,
            ),
            suggestionsBoxDecoration: SuggestionsBoxDecoration(),
            suggestionsCallback: (pattern) {
              if (pattern.isEmpty) {
                return _contactRepository.get(startIndex: 0, count: 8);
              } else {
                return _contactRepository.search(pattern, 8);
              }
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

  bool _contactExist(Contact contact, List<Contact> contacts) {
    for (int i = 0; i < contacts.length; i++) {
      if (contact.id != null) {
        if (contact.id == contacts[i].id) {
          return true;
        }
      } else {
        if (contact.name == contacts[i].name) {
          return true;
        }
      }
    }
    return false;
  }

  void _addContact(Contact contact) {
    if (_contactExist(contact, _contacts)) {
      return;
    }
    _contacts.add(contact);
  }

  Widget _createBeginTimeField() {
    return DateTimePicker(
      labelText: AppLocalizations.of(context).begin,
      selectedDate: _beginDate,
      selectedTime: _beginTime,
      selectDate: (value) {
        setState(() {
          _beginDate = value;
        });
      },
      selectTime: (value) {
        setState(() {
          _beginTime = value;
        });
      },
      enabled: !_isReadOnly,
    );
  }

  Widget _createEndTimeField() {
    return DateTimePicker(
      labelText: AppLocalizations.of(context).end,
      selectedDate: _endDate,
      selectedTime: _endTime,
      selectDate: (value) {
        setState(() {
          _endDate = value;
        });
      },
      selectTime: (value) {
        setState(() {
          _endTime = value;
        });
      },
      enabled: !_isReadOnly,
    );
  }

  Widget _createExpendFormField() {
    return Padding(
      padding:
          EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0, bottom: 16.0),
      child: TextInputFormField(
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
        enabled: !_isReadOnly,
      ),
    );
  }

  Widget _createSentimentFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 0, right: 16),
      child: FormField(
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
                state.hasError
                    ? Text(
                        state.errorText,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container(),
              ],
            ),
          );
        },
        validator: (value) {
          if (_selectedSentiment == null) {
            return AppLocalizations.of(context).selectSentiment;
          }
        },
      ),
    );
  }

  Widget _createFeelingsFormField() {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, top: 16.0, right: 16.0, bottom: 16.0),
      child: TextInputFormField(
        labelText: AppLocalizations.of(context).detail,
        hintText: 'Say something ...',
        maxLines: 4,
        controller: _feelingsController,
        enabled: !_isReadOnly,
      ),
    );
  }

  Widget _createActionNameFormField() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, top: 0.0, right: 16.0, bottom: 0.0),
      child: TypeAheadFormField(
        hideOnEmpty: true,
        hideOnLoading: true,
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
          decoration: InputDecoration(
            hintText: 'Enter action',
            border: InputBorder.none,
          ),
          controller: _actionNameController,
          style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
          autofocus: !_isReadOnly,
          enabled: !_isReadOnly,
        ),
        onSuggestionSelected: (Action action) {
          _actionNameController.text = action.name;
          _selectedAction = action;
        },
        itemBuilder: (context, suggestion) {
          final action = suggestion as Action;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
            child: Text(
              action.name,
            ),
          );
        },
        suggestionsCallback: (pattern) {
          _selectedAction = null;
          if (pattern.isEmpty) {
            return _actionRepository.get(startIndex: 0, count: 8);
          } else {
            return _actionRepository.search(pattern);
          }
        },
        validator: (value) {
          if (value.isEmpty) {
            return 'Please enter action';
          }
        },
      ),
    );
  }

  Widget _createEditAction() {
    if (_isReadOnly) {
      return FlatButton(
        onPressed: () {
          setState(() {
            _isReadOnly = false;
          });
        },
        child: Text(
          '修改',
          style:
              Theme.of(context).textTheme.button.copyWith(color: Colors.white),
        ),
      );
    } else {
      return FlatButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            await _saveMoment();
            Navigator.of(context).pop(true);
          }
        },
        child: Text(
          AppLocalizations.of(context).save,
          style:
              Theme.of(context).textTheme.button.copyWith(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.moment?.action?.name ?? 'Moment'),
        actions: <Widget>[
          _createEditAction(),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          onWillPop: _onWillPop,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: <Widget>[
              _createActionNameFormField(),
              Divider(),
              _createLocationField(),
              Divider(),
              _createPeopleFormField(),
              Divider(),
              Padding(
                padding: EdgeInsets.only(
                    left: 16.0, top: 16, right: 16, bottom: 16.0),
                child: FormField(
                  builder: (fieldState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _createBeginTimeField(),
                        _createEndTimeField(),
                        fieldState.hasError
                            ? Text(
                                fieldState.errorText,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            : Container(),
                      ],
                    );
                  },
                  validator: (value) {
                    if (getTime(_beginDate, _beginTime) >
                        getTime(_endDate, _endTime)) {
                      return '结束时间早于开始时间';
                    }
                  },
                ),
              ),
              Divider(),
              _createExpendFormField(),
              Divider(),
              _createSentimentFormField(),
              Divider(),
              _createFeelingsFormField(),
            ],
          ),
        ),
      ),
    );
  }
}
