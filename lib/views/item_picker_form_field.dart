import 'package:flutter/material.dart';

import 'package:data_life/views/labeled_text_form_field.dart';
import 'package:data_life/views/simple_list_dialog.dart';

typedef OnItemPicked(String value, int index);

class ItemPicker extends StatefulWidget {
  final String labelText;
  final List<String> items;
  final int defaultPicked;
  final OnItemPicked onItemPicked;

  const ItemPicker(
      {Key key,
      this.labelText,
      this.items,
      this.defaultPicked,
      this.onItemPicked})
      : super(key: key);

  @override
  ItemPickerState createState() {
    return new ItemPickerState();
  }
}

class ItemPickerState extends State<ItemPicker> {
  int _selectedIndex;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.defaultPicked;
  }

  Widget _createSelectedItemField() {
    final textStyle = Theme.of(context).textTheme.subhead;
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return SimpleListDialog(
              items: widget.items,
              onItemSelected: (value, index) {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onItemPicked(value, index);
              },
              selectedIndex: _selectedIndex,
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
            left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
        child: Text(widget.items[_selectedIndex],
          style: textStyle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
