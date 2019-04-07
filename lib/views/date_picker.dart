import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;
  final EdgeInsets contentPadding;

  const DatePicker(
      {Key key,
        this.selectedDate,
        this.selectDate,
        this.contentPadding,
      })
      : super(key: key);

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1998, 8),
        lastDate: DateTime(2998, 8));
    if (picked != null && picked != selectedDate) {
      selectDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;
    return InkWell(
      child: Padding(
        padding: contentPadding,
        child: Text(
          DateFormat.yMMMEd().format(selectedDate),
          style: valueStyle,
        ),
      ),
      onTap: () {
        _selectDate(context);
      },
    );
  }
}
