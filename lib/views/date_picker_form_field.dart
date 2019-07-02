import 'package:flutter/material.dart';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/date_picker.dart';


class DatePickerFormField extends StatefulWidget {
  final String labelText;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> selectDate;
  final bool enabled;

  const DatePickerFormField(
      {Key key,
        this.labelText,
        this.initialDateTime,
        this.selectDate,
        this.enabled = true})
      : super(key: key);

  @override
  DatePickerFormFieldState createState() {
    return new DatePickerFormFieldState();
  }
}

class DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LabelFormField(label: widget.labelText,
          padding: EdgeInsets.all(0),
        ),
        DatePicker(
          selectedDate: _selectedDate,
          contentPadding: EdgeInsets.only(
              left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
          selectDate: (value) {
            setState(() {
              _selectedDate = value;
            });
            widget.selectDate(_selectedDate);
          },
          enabled: widget.enabled,
        ),
      ],
    );
  }
}
