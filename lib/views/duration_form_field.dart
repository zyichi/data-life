import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:data_life/models/time_types.dart';

import 'package:data_life/views/simple_list_dialog.dart';
import 'package:data_life/views/type_to_str.dart';
import 'package:data_life/views/labeled_text_form_field.dart';


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
    if (_durationType != DurationType.customTime) {
      _stopDate = _startDate
          .add(Duration(milliseconds: durationTypeInMillis(durationType)));
    } else {
      _stopDate = _startDate.add(Duration(days: days));
    }
  }

  DateTime get stopDate => _stopDate;
  set stopDate(DateTime d) {
    if (_durationType == DurationType.customTime) {
      _stopDate = d;
    }
  }

  DurationType get durationType => _durationType;
  set durationType(DurationType dT) {
    _durationType = dT;
    if (_startDate != null && _durationType != DurationType.customTime) {
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
  List<_DurationPickItem> _durationItemList;
  int _indexPicked;
  String _durationText;

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
      _durationValue.startDate = DateTime.now();
    } else {
      _durationValue = widget.initialDurationValue;
    }

    _indexPicked = _durationItemList
        .indexWhere((item) => item.durationType == _durationValue.durationType);
    _durationText = TypeToStr.myDurationStr(
        _durationItemList[_indexPicked].durationType, context);
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

  FutureOr<void> _onItemPicked(dynamic d, int index) async {
    var value = d as _DurationPickItem;
    if (value.durationType == DurationType.customTime) {
      DatePicker.showDateTimePicker(
        context,
        showTitleActions: true,
        onConfirm: (time) {
          setState(() {
            _durationValue.durationType = value.durationType;
            _durationValue.stopDate = time;
            _indexPicked = index;
            _durationText = '${_durationValue.inDays()} days';
            widget.durationChanged(_durationValue);
          });
        },
        currentTime: _durationValue.stopDate,
      );
    } else {
      _indexPicked = index;
      _durationValue.durationType = value.durationType;
      _durationText =
          TypeToStr.myDurationStr(_durationValue._durationType, context);
      widget.durationChanged(_durationValue);
    }
  }

  Widget _createStartDateWidget() {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LabelFormField(
          label: 'Start time',
        ),
        InkWell(
          child: Padding(
            padding:
                EdgeInsets.only(left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
            child: Text(
              DateFormat.yMMMEd().add_Hm().format(_durationValue.startDate),
              style: valueStyle,
            ),
          ),
          onTap: widget.enabled
              ? () {
                  DatePicker.showDateTimePicker(
                    context,
                    showTitleActions: true,
                    onConfirm: (time) {
                      _durationValue.startDate = time;
                      widget.durationChanged(_durationValue);
                    },
                    currentTime: _durationValue.startDate,
                  );
                }
              : null,
        ),
      ],
    );
  }

  Widget _createSelectedItemField() {
    final textStyle = Theme.of(context).textTheme.subhead;
    return InkWell(
      onTap: widget.enabled
          ? () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleListDialog(
                    items: _durationItemList,
                    onItemSelected: _onItemPicked,
                    selectedIndex: _indexPicked,
                  );
                },
              );
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _durationText,
          style: textStyle,
        ),
      ),
    );
  }

  Widget _createDurationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelFormField(label: 'Duration'),
        Row(
          children: <Widget>[
            Expanded(
              child: _createSelectedItemField(),
            ),
          ],
        ),
      ],
    );
  }
}
