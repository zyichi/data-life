import 'package:flutter/material.dart';


class TimePicker extends StatelessWidget {
  final EdgeInsets contentPadding;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> selectTime;
  final bool enabled;

  const TimePicker(
      {Key key,
        this.selectedTime,
        this.selectTime,
        this.contentPadding,
        this.enabled = true,
      })
      : super(key: key);

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked =
    await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) {
      selectTime(picked);
    }
  }


  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.subhead;
    return InkWell(
      child: Padding(
        padding: contentPadding,
        child: Text(
          selectedTime.format(context),
          style: valueStyle,
        ),
      ),
      onTap: !enabled ? () {} : () {
        _selectTime(context);
      },
    );
  }
}
