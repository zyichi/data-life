import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/models/contact.dart';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/date_time_picker_form_field.dart';
import 'package:data_life/views/common_dialog.dart';

import 'package:data_life/utils/time_util.dart';
import 'package:data_life/blocs/contact_edit_bloc.dart';


class ContactEdit extends StatefulWidget {
  final Contact contact;

  ContactEdit({this.contact});

  @override
  _ContactEditState createState() => _ContactEditState();
}

class _ContactEditState extends State<ContactEdit> {
  bool _isReadOnly = true;
  final _formKey = GlobalKey<FormState>();
  Contact _contact;
  ContactEditBloc _contactEditBloc;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _nicknameController;
  TextEditingController _weChatController;
  TextEditingController _phoneNumberController;
  TextEditingController _qqController;
  TextEditingController _firstMeetLocationController;

  @override
  void initState() {
    super.initState();

    _contact = Contact.copyCreate(widget.contact);

    _contactEditBloc = BlocProvider.of<ContactEditBloc>(context);

    _nameController = TextEditingController(text: _contact.name);
    _nicknameController = TextEditingController(text: _contact.nickname);
    _weChatController = TextEditingController(text: _contact.weChatId);
    _phoneNumberController = TextEditingController(text: _contact.phoneNumber);
    _qqController = TextEditingController(text: _contact.qqId);
    _firstMeetLocationController = TextEditingController(text: _contact.firstMeetLocation);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Form(
        key: _formKey,
        onWillPop: _onWillPop,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LabeledTextFormField(
                  labelText: 'Name',
                  hintText: 'Enter name',
                  controller: _nameController,
                  enabled: !_isReadOnly,
                ),
                SizedBox(height: 4.0),
                LabeledTextFormField(
                  labelText: 'Nickanme',
                  hintText: 'Enter nickname',
                  controller: _nicknameController,
                  enabled: !_isReadOnly,
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
                  enabled: !_isReadOnly,
                ),
                SizedBox(height: 4.0),
                LabeledTextFormField(
                  labelText: 'Phone number',
                  hintText: 'Enter phone number',
                  controller: _phoneNumberController,
                  enabled: !_isReadOnly,
                ),
                SizedBox(height: 4.0),
                LabeledTextFormField(
                  labelText: 'QQ',
                  hintText: 'Enter QQ',
                  controller: _qqController,
                  enabled: !_isReadOnly,
                ),
                Divider(),
                SizedBox(height: 8.0),
                DateTimePicker(
                  labelText: 'First meet time',
                  initialDateTime: DateTime.fromMillisecondsSinceEpoch(_contact.firstMeetTime),
                  selectDateTime: (value) {
                    setState(() {
                      _contact.firstMeetTime = value.millisecondsSinceEpoch;
                    });
                  },
                  enabled: !_isReadOnly,
                ),
                SizedBox(height: 4.0),
                DateTimePicker(
                  labelText: 'First known time',
                  initialDateTime: DateTime.fromMillisecondsSinceEpoch(_contact.firstKnowTime),
                  selectDateTime: (value) {
                    setState(() {
                      _contact.firstKnowTime = value.millisecondsSinceEpoch;
                    });
                  },
                  enabled: !_isReadOnly,
                ),
                SizedBox(height: 4.0),
                LabeledTextFormField(
                  labelText: 'First meet location',
                  hintText: 'Enter first meet location',
                  controller: _firstMeetLocationController,
                  enabled: !_isReadOnly,
                ),
              ],
            )
          ],
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
      s = TimeUtil.formatDateForDisplayMillis(_contact.lastMeetTime) +
          ' ' +
          TimeUtil.formatDateTimeForDisplayMillis(
              _contact.lastMeetTime, context);
    }
    return s;
  }

  void _updateContactFromForm() {
    _contact.name = _nameController.text;
    _contact.nickname = _nicknameController.text;
    _contact.weChatId = _weChatController.text;
    _contact.phoneNumber = _phoneNumberController.text;
    _contact.qqId = _qqController.text;
    _contact.firstMeetLocation = _firstMeetLocationController.text;
  }

  void _editContact() {
    _updateContactFromForm();
    _contactEditBloc.dispatch(UpdateContact(newContact: _contact, oldContact: widget.contact));
  }
}
