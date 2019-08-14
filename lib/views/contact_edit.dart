import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/models/contact.dart';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/common_dialog.dart';

import 'package:data_life/utils/time_util.dart';
import 'package:data_life/blocs/contact_bloc.dart';

class ContactEdit extends StatefulWidget {
  final Contact contact;

  ContactEdit({this.contact});

  @override
  _ContactEditState createState() => _ContactEditState();
}

class _ContactEditState extends State<ContactEdit> {
  bool _isReadOnly = true;
  bool _isNameUnique = true;
  final _formKey = GlobalKey<FormState>();
  Contact _contact;
  ContactBloc _contactEditBloc;
  FocusNode _nameFocusNode;
  TextEditingController _nameController;
  TextEditingController _nicknameController;
  TextEditingController _weChatController;
  TextEditingController _phoneNumberController;
  TextEditingController _qqController;
  TextEditingController _firstMeetLocationController;

  @override
  void initState() {
    super.initState();

    _contact = Contact.copyCreate(widget.contact);

    _contactEditBloc = BlocProvider.of<ContactBloc>(context);

    _nameFocusNode = FocusNode();
    _nameController = TextEditingController(text: _contact.name);
    _nicknameController = TextEditingController(text: _contact.nickname);
    _weChatController = TextEditingController(text: _contact.weChatId);
    _phoneNumberController = TextEditingController(text: _contact.phoneNumber);
    _qqController = TextEditingController(text: _contact.qqId);
    _firstMeetLocationController =
        TextEditingController(text: _contact.location?.address ?? '');

    _nameController.addListener(() {
      String newName = _nameController.text;
      if (newName.isNotEmpty && newName != widget.contact.name) {
        _contactEditBloc.dispatch(
            ContactNameUniqueCheck(name: _nameController.text));
      }
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();

    _nameController.dispose();
    _nicknameController.dispose();
    _weChatController.dispose();
    _phoneNumberController.dispose();
    _qqController.dispose();
    _firstMeetLocationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactBloc, ContactState>(
      bloc: _contactEditBloc,
      listener: (context, state) {
        if (state is ContactNameUniqueCheckResult) {
          if (state.text == _nameController.text) {
            setState(() {
              _isNameUnique = state.isUnique;
            });
          }
        }
        if (state is ContactFailed) {
          print('Contact edit bloc failed state: ${state.error}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.contact.name),
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
                        _editContact();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _isReadOnly,
          child: Form(
            key: _formKey,
            onWillPop: _onWillPop,
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _createNameField(context),
                    SizedBox(height: 4.0),
                    LabeledTextFormField(
                      labelText: 'Nickanme',
                      hintText: 'Enter nickname',
                      controller: _nicknameController,
                    ),
                    SizedBox(height: 4.0),
                    LabeledTextFormField(
                      labelText: '最近见面 (不可修改)',
                      controller: TextEditingController(
                          text: _getLastMeetTimeString(context)),
                      enabled: false,
                    ),
                    SizedBox(height: 4.0),
                    LabeledTextFormField(
                      labelText: '共呆一起 (不可修改)',
                      controller: TextEditingController(
                          text: TimeUtil.formatMillisToDHM(
                              _contact.totalTimeTogether, context)),
                      enabled: false,
                    ),
                    Divider(),
                    SizedBox(height: 8.0),
                    LabeledTextFormField(
                      labelText: 'WeChat',
                      hintText: 'Enter WeChat',
                      controller: _weChatController,
                    ),
                    SizedBox(height: 4.0),
                    LabeledTextFormField(
                      labelText: 'Phone number',
                      hintText: 'Enter phone number',
                      controller: _phoneNumberController,
                    ),
                    SizedBox(height: 4.0),
                    LabeledTextFormField(
                      labelText: 'QQ',
                      hintText: 'Enter QQ',
                      controller: _qqController,
                    ),
                    Divider(),
                    SizedBox(height: 8.0),
                    DateTimePickerFormField(
                      labelText: 'First meet time',
                      initialDateTime: DateTime.fromMillisecondsSinceEpoch(
                          _contact.firstMeetTime),
                      selectDateTime: (value) {
                        setState(() {
                          _contact.firstMeetTime = value.millisecondsSinceEpoch;
                        });
                      },
                    ),
                    SizedBox(height: 4.0),
                    DateTimePickerFormField(
                      labelText: 'First known time',
                      initialDateTime: DateTime.fromMillisecondsSinceEpoch(
                          _contact.firstKnowTime),
                      selectDateTime: (value) {
                        setState(() {
                          _contact.firstKnowTime = value.millisecondsSinceEpoch;
                        });
                      },
                    ),
                    SizedBox(height: 4.0),
                    LabeledTextFormField(
                      labelText: 'First meet location',
                      hintText: 'Enter first meet location',
                      controller: _firstMeetLocationController,
                      maxLines: null,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isReadOnly) {
      return true;
    }

    _updateContactFromForm();
    if (_contact.isContentSameWith(widget.contact)) {
      return true;
    }

    return await CommonDialog.showEditExitConfirmDialog(context,
        'Are you sure you want to discard your changes to the contact?');
  }

  String _getLastMeetTimeString(BuildContext context) {
    String s;
    if (_contact.lastMeetTime == null) {
      s = '未见面';
    } else {
      s = TimeUtil.dateStringFromMillis(_contact.lastMeetTime) +
          ' ' +
          TimeUtil.timeStringFromMillis(_contact.lastMeetTime, context);
    }
    return s;
  }

  void _updateContactFromForm() {
    _contact.name = _nameController.text;
    _contact.nickname = _nicknameController.text;
    _contact.weChatId = _weChatController.text;
    _contact.phoneNumber = _phoneNumberController.text;
    _contact.qqId = _qqController.text;
    _contact.firstMeetLocation = -1;
  }

  void _editContact() {
    _updateContactFromForm();
    _contactEditBloc.dispatch(
        UpdateContact(newContact: _contact, oldContact: widget.contact));
  }

  Widget _createNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelFormField(
          label: 'Name',
        ),
        TextFormField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          validator: (value) {
            if (value.isEmpty) {
              return 'Contact name can not empty';
            }
            if (!_isNameUnique) {
              return 'Contact name already exist';
            }
            return null;
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter name',
            isDense: true,
          ),
          autovalidate: true,
        ),
      ],
    );
  }
}
