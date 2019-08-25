import 'package:flutter/material.dart';

class MyFormField extends StatelessWidget {
  MyFormField({Key key,
      @required this.child,
      this.label,
      this.labelPadding = EdgeInsets.zero,
      this.labelStyle = const TextStyle(fontSize: 12, color: Colors.grey)})
      : assert(child != null),
        super(key: key);

  final Widget child;
  final String label;
  final EdgeInsets labelPadding;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildLabel(),
        child,
      ],
    );
  }

  Widget _buildLabel() {
    if (label == null) {
      return Container();
    }
    return Padding(
      padding: labelPadding,
      child: Text(
        label,
        style: labelStyle,
      ),
    );
  }
}
