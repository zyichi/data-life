import 'package:flutter/material.dart';
import 'dart:async';

import 'package:data_life/views/my_form_text_field.dart';


typedef UniqueValidator<String, bool> = String Function(String text, bool isUnique);
typedef UniqueCheckCallback<bool> = FutureOr<bool> Function(String text);


class UniqueCheckFormField extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final TextEditingController controller;
  final TextStyle textStyle;
  final FocusNode focusNode;
  final ValueChanged<String> textChanged;
  final UniqueValidator<String, bool> validator;
  final UniqueCheckCallback<bool> uniqueCheckCallback;
  final bool enabled;
  final bool mutable;
  final bool autofocus;

  UniqueCheckFormField({
    this.hintText,
    this.initialValue,
    this.textStyle,
    this.controller,
    this.focusNode,
    this.textChanged,
    this.validator,
    this.uniqueCheckCallback,
    this.enabled = true,
    this.mutable = true,
    this.autofocus = false,
  })  : assert(textChanged != null),
        assert(uniqueCheckCallback != null),
        assert(validator != null);

  @override
  _UniqueCheckFormFieldState createState() => _UniqueCheckFormFieldState();
}

class _UniqueCheckFormFieldState extends State<UniqueCheckFormField> {
  bool _isUnique = true;
  bool _isEdited = false;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _controller.text = widget.initialValue;

    _controller.addListener(() async {
      String text = _controller.text;
      if (!_isEdited && text.isNotEmpty) {
        setState(() {
          _isEdited = true;
        });
      }
      if (widget.textChanged != null) {
        widget.textChanged(text);
      }
      if (text.isNotEmpty) {
        bool result = await widget.uniqueCheckCallback(text);
        if (!mounted) return;
        if (text == _controller.text) {
          setState(() {
            _isUnique = result;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyFormTextField(
      valueTextStyle: widget.textStyle,
      controller: _controller,
      focusNode: widget.focusNode,
      validator: (value) {
        return widget.validator(value, _isUnique);
      },
      inputHint: widget.hintText,
      valueEditable: widget.mutable,
      autovalidate: _isEdited,
      autofocus: widget.autofocus,
      valueChanged: widget.textChanged,
    );
  }
}
