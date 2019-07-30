import 'package:flutter/material.dart';


String formFieldEmptyValidator(String text) {
  if (text.isEmpty) {
    return 'Can not be empty';
  } else {
    return null;
  }
}


class LabelFormField extends StatelessWidget {
  final String label;
  final EdgeInsets padding;

  const LabelFormField(
      {Key key,
      this.label,
      this.padding = EdgeInsets.zero})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.caption;
    return Padding(
      padding: padding,
      child: Text(
        label,
        style: labelStyle,
      ),
    );
  }
}


class FormFieldError extends StatelessWidget {
  final String errorText;

  FormFieldError({this.errorText});

  @override
  Widget build(BuildContext context) {
    return _isShowError() ? Text(
      errorText,
      style: TextStyle(
        color: Colors.red,
      ),
    ) : Container();
  }

  bool _isShowError() {
    return errorText != null && errorText.isNotEmpty;
  }
}

class LabeledTextFormField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String initialValue;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final TextInputType inputType;
  final int maxLines;
  final bool enabled;

  LabeledTextFormField({
    Key key,
    this.labelText,
    this.hintText,
    this.initialValue,
    this.controller,
    this.validator,
    this.inputType = TextInputType.text,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
  }) : assert(controller == null || initialValue == null), super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelFormField(
          label: labelText,
          padding: EdgeInsets.zero,
        ),
        TextFormField(
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            isDense: true,
          ),
          maxLines: maxLines,
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          enabled: enabled,
          focusNode: focusNode,
        )
      ],
    );
  }
}
