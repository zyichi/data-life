import 'package:flutter/material.dart';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/simple_list_dialog.dart';

typedef OnItemPicked<T>(T picked, int index);

class ItemPicker<T> extends StatefulWidget {
  final String labelText;
  final List<T> items;
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
  ItemPickerState<T> createState() {
    return new ItemPickerState<T>();
  }
}

class ItemPickerState<T> extends State<ItemPicker> {
  int _selectedIndex;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.defaultPicked;
  }

  void _onItemSelected<T>(T value, int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemPicked(value, index);
  }

  Widget _createSelectedItemField() {
    final textStyle = Theme.of(context).textTheme.subhead;
    return InkWell(
      onTap: widget.enabled ? () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleListDialog<T>(
              items: widget.items,
              onItemSelected: _onItemSelected,
              selectedIndex: _selectedIndex,
            );
          },
        );
      } : () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          widget.items[_selectedIndex].toString(),
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
