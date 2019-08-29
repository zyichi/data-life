import 'package:flutter/material.dart';

import 'package:data_life/views/my_form_field.dart';


const myFormTextFieldValueStyle = TextStyle(
  fontSize: 16,
);


class MyReadOnlyTextField extends StatelessWidget {
  final String name;
  final String value;

  MyReadOnlyTextField({this.name, this.value});

  @override
  Widget build(BuildContext context) {
    return MyFormField(
      label: name,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(value,
          style: myFormTextFieldValueStyle,
        ),
      ),
    );
  }
}

class MyFormTextField extends StatefulWidget {
  final String name;
  final String value;
  final String inputHint;
  final ValueChanged<String> valueChanged;
  final bool valueEditable;
  final FormFieldValidator<String> validator;
  final TextStyle labelTextStyle;
  final TextStyle valueTextStyle;
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool autofocus;
  final bool autovalidate;
  final TextInputType inputType;

  MyFormTextField({
    this.name,
    this.value,
    this.inputHint,
    this.valueChanged,
    this.valueEditable,
    this.validator,
    this.labelTextStyle,
    this.valueTextStyle = myFormTextFieldValueStyle,
    this.focusNode,
    this.controller,
    this.autofocus = false,
    this.autovalidate = false,
    this.inputType = TextInputType.text,
  });

  @override
  _MyFormTextFieldState createState() => _MyFormTextFieldState();

  static Widget buildFieldRemoveButton(VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 36,
        child: Icon(
          Icons.remove_circle_outline,
          color: Colors.red,
          size: 24,
        ),
      ),
      onTap: onTap,
    );
  }

}

class _MyFormTextFieldState extends State<MyFormTextField> {
  TextEditingController _valueController;
  bool _isEdited = false;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _valueController = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.value != null) {
      _valueController.text = widget.value;
    }
    _valueController.addListener(() {
      if (!_isEdited && _valueController.text.isNotEmpty) {
        setState(() {
          _isEdited = true;
        });
      }
      widget.valueChanged(_valueController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyFormField(
      label: widget.name,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: widget.inputHint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(top: 8, bottom: 0),
              ),
              style: widget.valueTextStyle,
              keyboardType: widget.inputType,
              controller: _valueController,
              focusNode: _focusNode,
              autovalidate: _isEdited,
              validator: widget.validator,
              autofocus: widget.autofocus,
              enabled: widget.valueEditable,
            ),
          ),
          widget.valueEditable && _valueController.text.isNotEmpty
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 40,
                    height: 36,
                    child: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  onTap: () {
                    final bool textChanged = _valueController.text.isNotEmpty;
                    _valueController.clear();
                    FocusScope.of(context).requestFocus(_focusNode);
                    if (textChanged && widget.valueChanged != null) {
                      widget.valueChanged(_valueController.text);
                    }
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
