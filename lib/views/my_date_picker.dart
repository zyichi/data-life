import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class MyDatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;
  final EdgeInsets contentPadding;
  final bool enabled;

  const MyDatePicker({
    Key key,
    this.selectedDate,
    this.selectDate,
    this.contentPadding,
    this.enabled = true,
  }) : super(key: key);

  void _selectDate(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      currentTime: selectedDate,
      showTitleActions: true,
      onConfirm: (value) {
        selectDate(value);
      },
      minTime: DateTime(1898, 8),
      maxTime: DateTime(2998, 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;
    return InkWell(
      child: Padding(
        padding: contentPadding,
        child: Text(
          DateFormat(DateFormat.YEAR_ABBR_MONTH_WEEKDAY_DAY).format(selectedDate),
          style: valueStyle,
        ),
      ),
      onTap: !enabled
          ? null
          : () {
              _selectDate(context);
            },
    );
  }
}
