import 'package:flutter/material.dart';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/date_picker.dart';
import 'package:data_life/views/time_picker.dart';


class DateTimePicker extends StatefulWidget {
  final String labelText;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> selectDateTime;
  final bool enabled;

  const DateTimePicker(
      {Key key,
        this.labelText,
        this.initialDateTime,
        this.selectDateTime,
        this.enabled = true})
      : super(key: key);

  @override
  DateTimePickerState createState() {
    return new DateTimePickerState();
  }
}

class DateTimePickerState extends State<DateTimePicker> {
  DateTime _selectedDate;
  TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.initialDateTime;
    _selectedTime = TimeOfDay.fromDateTime(widget.initialDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelFormField(label: widget.labelText,
          padding: EdgeInsets.all(0),
        ),
        Row(
          children: <Widget>[
            DatePicker(
              selectedDate: _selectedDate,
              contentPadding: EdgeInsets.only(
                  left: 0.0, top: 8.0, right: 16.0, bottom: 8.0),
              selectDate: (value) {
                setState(() {
                  _selectedDate = value;
                });
                widget.selectDateTime(value);
              },
              enabled: widget.enabled,
            ),
            Expanded(
              child: TimePicker(
                selectedTime: _selectedTime,
                contentPadding:
                EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                selectTime: (value) {
                  setState(() {
                    _selectedTime = value;
                  });
                  widget.selectDateTime(DateTime(
                    _selectedDate.year, _selectedDate.month, _selectedDate.day,
                    _selectedTime.hour, _selectedTime.minute
                  ));
                },
                enabled: widget.enabled,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
