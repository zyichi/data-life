import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:data_life/views/labeled_text_form_field.dart';


class DateTimePickerFormField extends StatefulWidget {
  final String labelText;
  final DateTime initialDateTime;
  final ValueChanged<DateTime> selectDateTime;
  final bool enabled;

  const DateTimePickerFormField(
      {Key key,
      this.labelText,
      this.initialDateTime,
      this.selectDateTime,
      this.enabled = true})
      : super(key: key);

  @override
  DateTimePickerFormFieldState createState() {
    return new DateTimePickerFormFieldState();
  }
}

class DateTimePickerFormFieldState extends State<DateTimePickerFormField> {
  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelFormField(
          label: widget.labelText,
          padding: EdgeInsets.all(0),
        ),
        InkWell(
          child: Padding(
            padding:
            EdgeInsets.only(left: 0.0, top: 8.0, right: 0.0, bottom: 8.0),
            child: Text(
              DateFormat.yMMMEd().add_Hm().format(widget.initialDateTime),
              style: valueStyle,
            ),
          ),
          onTap: widget.enabled
              ? () {
            DatePicker.showDateTimePicker(
              context,
              showTitleActions: true,
              onConfirm: (time) {
                widget.selectDateTime(time);
              },
              currentTime: widget.initialDateTime,
            );
          } : null,
        ),
      ],
    );
  }
}

