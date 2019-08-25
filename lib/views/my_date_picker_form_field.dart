import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:data_life/views/my_form_field.dart';

const double _kPickerSheetHeight = 216;

class MyDatePickerFormField extends StatefulWidget {
  MyDatePickerFormField({
    @required this.labelName,
    @required this.mutable,
    this.mode = CupertinoDatePickerMode.dateAndTime,
    @required this.onChanged,
    DateTime initialDateTime,
    this.minimumYear = 1,
    this.minimumDate,
    this.use24hFormat = false,
    this.labelPadding = EdgeInsets.zero,
    this.valuePadding = EdgeInsets.zero,
  }) : initialDateTime = initialDateTime ?? DateTime.now();

  final String labelName;
  final bool mutable;
  final CupertinoDatePickerMode mode;
  final ValueChanged<DateTime> onChanged;
  final DateTime initialDateTime;
  final DateTime minimumDate;
  final int minimumYear;
  final bool use24hFormat;
  final EdgeInsets labelPadding;
  final EdgeInsets valuePadding;

  @override
  _MyDatePickerFormFieldState createState() => _MyDatePickerFormFieldState();
}

class _MyDatePickerFormFieldState extends State<MyDatePickerFormField> {
  DateTime _currentDateTime;

  @override
  void initState() {
    super.initState();
    _currentDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return MyFormField(
      label: widget.labelName,
      labelPadding: widget.labelPadding,
      child: InkWell(
        child: Padding(
          padding: widget.valuePadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _formatDateTime(_currentDateTime),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              widget.mutable
                  ? Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    )
                  : Container(),
            ],
          ),
        ),
        onTap: () {
          showCupertinoModalPopup<void>(
              context: context,
              builder: (BuildContext context) {
                return _buildBottomPicker(
                  CupertinoDatePicker(
                    mode: widget.mode,
                    initialDateTime: widget.initialDateTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        _currentDateTime = newDateTime;
                      });
                      widget.onChanged(newDateTime);
                    },
                  ),
                );
              });
        },
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    switch (widget.mode) {
      case CupertinoDatePickerMode.time:
        return DateFormat.jm().format(dateTime);
      case CupertinoDatePickerMode.date:
        return DateFormat.yMMMMd().format(dateTime);
      case CupertinoDatePickerMode.dateAndTime:
        return DateFormat.yMMMd().add_jm().format(dateTime);
    }
    return null;
  }
}
