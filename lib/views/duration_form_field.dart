import 'package:flutter/material.dart';
import 'dart:async';

import 'package:data_life/models/time_types.dart';

import 'package:data_life/views/date_picker_form_field.dart';
import 'package:data_life/views/item_picker_form_field.dart';
import 'package:data_life/views/type_to_str.dart';

import 'package:data_life/utils/time_util.dart';

typedef DurationValidator = String Function(DurationValue durationValue);

class _DurationPickItem {
  final DurationType durationType;
  String caption;
  _DurationPickItem({this.durationType, this.caption});

  @override
  String toString() {
    return caption;
  }
}

class DurationValue {
  DurationType _durationType;
  DateTime _startDate;
  DateTime _stopDate;

  DateTime get startDate => _startDate;
  set startDate(DateTime d) {
    int days = inDays();
    _startDate = d;
    if (_durationType != DurationType.userSelectTime) {
      _stopDate = _startDate
          .add(Duration(milliseconds: durationTypeInMillis(durationType)));
    } else {
      _stopDate = _startDate.add(Duration(days: days));
    }
  }

  DateTime get stopDate => _stopDate;
  set stopDate(DateTime d) {
    if (_durationType == DurationType.userSelectTime) {
      _stopDate = d;
    }
  }

  DurationType get durationType => _durationType;
  set durationType(DurationType dT) {
    _durationType = dT;
    if (_startDate != null && _durationType != DurationType.userSelectTime) {
      _stopDate = _startDate
          .add(Duration(milliseconds: durationTypeInMillis(_durationType)));
    }
  }

  DurationValue(DurationType durationType) {
    _durationType = durationType;
  }

  int inDays() {
    if (_stopDate == null || _startDate == null) {
      return 0;
    }
    return _stopDate.difference(_startDate).inDays;
  }
}

class DurationFormField extends StatefulWidget {
  final bool enabled;
  final List<DurationType> durationTypeList;
  final ValueChanged<DurationValue> durationChanged;
  final DurationValue initialDurationValue;
  final DurationValidator durationValidator;

  DurationFormField({
    this.enabled = true,
    this.durationTypeList,
    this.durationChanged,
    this.initialDurationValue,
    this.durationValidator,
  })  : assert(durationTypeList != null),
        assert(durationChanged != null),
        assert(durationValidator != null);

  @override
  _DurationFormFieldState createState() => _DurationFormFieldState();
}

class _DurationFormFieldState extends State<DurationFormField> {
  DurationValue _durationValue;
  int _indexPicked;
  List<_DurationPickItem> _durationItemList;

  @override
  void initState() {
    super.initState();

    _durationItemList = widget.durationTypeList.map((t) {
      _DurationPickItem item = _DurationPickItem(
        caption: TypeToStr.myDurationStr(t, context),
        durationType: t,
      );
      return item;
    }).toList();
    if (widget.initialDurationValue == null) {
      _durationValue = DurationValue(widget.durationTypeList[0]);
      _durationValue.startDate =
          TimeUtil.getDate(DateTime.now().millisecondsSinceEpoch);
    } else {
      _durationValue = widget.initialDurationValue;
    }

    _indexPicked = _durationItemList
        .indexWhere((item) => item.durationType == _durationValue.durationType);
  }

  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _createStartDateWidget(),
            _createDurationWidget(),
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
        return widget.durationValidator(_durationValue);
      },
      autovalidate: true,
    );
  }

  FutureOr<String> _onItemPicked(dynamic d, int index) async {
    var value = d as _DurationPickItem;
    _durationValue.durationType = value.durationType;
    if (value.durationType == DurationType.userSelectTime) {
      final DateTime picked = await showDatePicker(
          context: context,
          initialDate: _durationValue.stopDate,
          firstDate: DateTime(1998, 1, 1),
          lastDate: DateTime(3998, 1, 1));
      if (picked != null) {
        _durationValue.stopDate = picked;
        return '${_durationValue.inDays()} days';
      } else {
        return '${_durationValue.inDays()} days';
      }
    }
    widget.durationChanged(_durationValue);
    return null;
  }

  Widget _createStartDateWidget() {
    return DatePickerFormField(
      labelText: 'Start date',
      initialDateTime:
          TimeUtil.getDate(_durationValue.startDate.millisecondsSinceEpoch),
      selectDate: (value) {
        _durationValue.startDate = value;
        widget.durationChanged(_durationValue);
      },
      enabled: widget.enabled,
    );
  }

  Widget _createDurationWidget() {
    return ItemPicker(
      labelText: 'Duration',
      items: _durationItemList,
      defaultPicked: _indexPicked,
      onItemPicked: _onItemPicked,
      enabled: widget.enabled,
    );
  }
}
