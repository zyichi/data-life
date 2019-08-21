import 'package:flutter/material.dart';

class ListDialogItem<T> extends StatelessWidget {
  ListDialogItem({
    Key key,
    this.value,
    @required this.child
  }) : assert(child != null),
        super(key: key);

  final T value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}


class ListDialog<T> extends StatefulWidget {
  ListDialog({
    Key key,
    @required this.items,
    this.value,
    @required this.onChanged,
    this.contentPadding = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
    this.itemPadding = const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 16.0),
  }) : assert(items == null || items.isEmpty || value == null || items.where((ListDialogItem<T> item) => item.value == value).length == 1),
       super(key: key);

  final List<ListDialogItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry itemPadding;

  @override
  _ListDialogState<T> createState() => _ListDialogState<T>();
}

class _ListDialogState<T> extends State<ListDialog<T>> {
  @override
  Widget build(BuildContext context) {
    List<Widget> itemList = widget.items.map((ListDialogItem<T> item) {
       return InkWell(
         child: Padding(
           padding: widget.itemPadding,
           child: item,
         ),
         onTap: () {
           Navigator.of(context).pop();
           widget.onChanged(item.value);
         },
       );
    }).toList();
    return Dialog(
      child: SingleChildScrollView(
        padding: widget.contentPadding,
        child: ListBody(children: itemList,),
      ),
    );
  }
}
