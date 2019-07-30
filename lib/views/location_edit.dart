import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/models/location.dart';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/common_dialog.dart';

import 'package:data_life/utils/time_util.dart';
import 'package:data_life/blocs/location_edit_bloc.dart';

class LocationEdit extends StatefulWidget {
  final Location location;

  LocationEdit({this.location});

  @override
  _LocationEditState createState() => _LocationEditState();
}

class _LocationEditState extends State<LocationEdit> {
  bool _isReadOnly = true;
  bool _isNameUnique = true;
  final _formKey = GlobalKey<FormState>();
  Location _location;
  LocationEditBloc _locationEditBloc;
  FocusNode _nameFocusNode;
  TextEditingController _nameController;
  TextEditingController _addressController;
  TextEditingController _townshipController;
  TextEditingController _districtController;
  TextEditingController _cityController;
  TextEditingController _provinceController;
  TextEditingController _countryController;

  @override
  void initState() {
    super.initState();

    _location = Location.copyCreate(widget.location);

    _locationEditBloc = BlocProvider.of<LocationEditBloc>(context);

    _nameFocusNode = FocusNode();
    _nameController = TextEditingController(text: _location.name);
    _addressController = TextEditingController(text: _location.address);
    _townshipController = TextEditingController(text: _location.township);
    _districtController = TextEditingController(text: _location.district);
    _cityController = TextEditingController(text: _location.city);
    _provinceController = TextEditingController(text: _location.province);
    _countryController = TextEditingController(text: _location.country);

    _nameController.addListener(() {
      String newName = _nameController.text;
      if (newName.isNotEmpty && newName != widget.location.name) {
        _locationEditBloc
            .dispatch(LocationNameUniqueCheck(name: _nameController.text));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _townshipController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _countryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationEditBloc, LocationEditState>(
      bloc: _locationEditBloc,
      listener: (context, state) {
        if (state is LocationNameUniqueCheckResult) {
          if (state.text == _nameController.text) {
            setState(() {
              _isNameUnique = state.isUnique;
            });
          }
        }
        if (state is LocationEditFailed) {
          print('Location edit bloc failed state: ${state.error}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.location.name),
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
                        _editLocation();
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
                  _createNameField(context),
                  SizedBox(height: 4.0),
                  LabeledTextFormField(
                    labelText: 'Address',
                    controller: _addressController,
                    maxLines: null,
                    enabled: !_isReadOnly,
                  ),
                  LabeledTextFormField(
                    labelText: '最近停留 (不可修改)',
                    controller: TextEditingController(
                        text: _getLastVisitTimeString(context)),
                    enabled: false,
                  ),
                  SizedBox(height: 4.0),
                  LabeledTextFormField(
                    labelText: '总共停留 (不可修改)',
                    controller: TextEditingController(
                        text: TimeUtil.formatMillisToDHM(
                            _location.totalTimeStay, context)),
                    enabled: false,
                  ),
                  Divider(),
                  SizedBox(height: 8.0),
                  LabeledTextFormField(
                    labelText: 'Country',
                    hintText: 'Enter country',
                    controller: _countryController,
                    enabled: !_isReadOnly,
                  ),
                  SizedBox(height: 4.0),
                  LabeledTextFormField(
                    labelText: 'Province',
                    hintText: 'Enter province',
                    controller: _provinceController,
                    enabled: !_isReadOnly,
                  ),
                  SizedBox(height: 4.0),
                  LabeledTextFormField(
                    labelText: 'City',
                    hintText: 'Enter city',
                    controller: _cityController,
                    enabled: !_isReadOnly,
                  ),
                  SizedBox(height: 4.0),
                  LabeledTextFormField(
                    labelText: 'District',
                    hintText: 'Enter district',
                    controller: _districtController,
                    enabled: !_isReadOnly,
                  ),
                  SizedBox(height: 4.0),
                  LabeledTextFormField(
                    labelText: 'Township',
                    hintText: 'Enter township',
                    controller: _townshipController,
                    enabled: !_isReadOnly,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isReadOnly) {
      return true;
    }

    _updateLocationFromForm();
    if (_location.isContentSameWith(widget.location)) {
      return true;
    }

    return await CommonDialog.showEditExitConfirmDialog(context,
        'Are you sure you want to discard your changes to the location?');
  }

  String _getLastVisitTimeString(BuildContext context) {
    String s;
    if (_location.lastVisitTime == null) {
      s = '未见面';
    } else {
      s = TimeUtil.dateStringFromMillis(_location.lastVisitTime) +
          ' ' +
          TimeUtil.timeStringFromMillis(_location.lastVisitTime, context);
    }
    return s;
  }

  void _updateLocationFromForm() {
    _location.name = _nameController.text;
  }

  void _editLocation() {
    _updateLocationFromForm();
    _locationEditBloc.dispatch(
        UpdateLocation(newLocation: _location, oldLocation: widget.location));
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
              return 'Location name can not empty';
            }
            if (!_isNameUnique) {
              return 'Location name already exist';
            }
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Enter name',
            isDense: true,
          ),
          enabled: !_isReadOnly,
          autovalidate: true,
        ),
      ],
    );
  }
}
