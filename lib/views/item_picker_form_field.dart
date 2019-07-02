import 'package:flutter/material.dart';
import 'dart:async';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/simple_list_dialog.dart';

typedef OnItemPicked<T> = FutureOr<String> Function(T picked, int index);

class ItemPicker extends StatefulWidget {
  final String labelText;
  final List<dynamic> items;
  final int defaultPicked;
  final OnItemPicked onItemPicked;
  final EdgeInsets padding;
  final bool enabled;

  const ItemPicker({
    Key key,
    this.labelText,
    this.items,
    this.defaultPicked,
    this.onItemPicked,
    this.padding = EdgeInsets.zero,
    this.enabled,
  }) : super(key: key);

  @override
  ItemPickerState createState() {
    return new ItemPickerState();
  }
}

class ItemPickerState extends State<ItemPicker> {
  int _selectedIndex;
  String _selectedItemText;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.defaultPicked;
    _selectedItemText = widget.items[_selectedIndex].toString();
  }

  void _onItemSelected(dynamic value, int index) async {
    setState(() {
      _selectedIndex = index;
    });
    _selectedItemText = await widget.onItemPicked(value, index);
    if (_selectedItemText == null) {
      _selectedItemText = value.toString();
    }
  }

  Widget _createSelectedItemField() {
    final textStyle = Theme.of(context).textTheme.subhead;
    return InkWell(
      onTap: widget.enabled ? () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleListDialog(
              items: widget.items,
              onItemSelected: _onItemSelected,
              selectedIndex: _selectedIndex,
            );
          },
        );
      } : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _selectedItemText,
          style: textStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LabelFormField(label: widget.labelText),
          Row(
            children: <Widget>[
              Expanded(
                child: _createSelectedItemField(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
