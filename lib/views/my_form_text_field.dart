import 'package:flutter/material.dart';


class MyImmutableFormTextField extends StatelessWidget {
  final String name;
  final String value;

  MyImmutableFormTextField({this.name, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            name,
            style: Theme.of(context).textTheme.caption,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(value),
          )
        ],
      ),
    );
  }
}


class MyFormFieldLabel extends StatefulWidget {
  final String label;
  final EdgeInsets padding;
  final TextStyle textStyle;

  const MyFormFieldLabel(
      {Key key,
        this.label,
        this.textStyle,
        this.padding = EdgeInsets.zero})
      : super(key: key);

  @override
  _MyFormFieldLabelState createState() => _MyFormFieldLabelState();
}

class _MyFormFieldLabelState extends State<MyFormFieldLabel> {
  TextStyle _textStyle;

  @override
  void initState() {
    super.initState();

    _textStyle = widget.textStyle;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.textStyle == null) {
      _textStyle = Theme.of(context).textTheme.caption;
    }
    return Padding(
      padding: widget.padding,
      child: Text(
        widget.label,
        style: _textStyle,
      ),
    );
  }
}


class MyFormTextField extends StatefulWidget {
  final String name;
  final String initialValue;
  final String inputHint;
  final ValueChanged<String> valueChanged;
  final bool valueMutable;
  final FormFieldValidator<String> validator;
  final bool isShowLabel;
  final TextStyle labelTextStyle;
  final TextStyle valueTextStyle;
  final FocusNode focusNode;
  final TextEditingController controller;
  final bool autofocus;
  final bool autovalidate;

  MyFormTextField({
    this.name,
    this.initialValue,
    this.inputHint,
    this.valueChanged,
    this.valueMutable,
    this.validator,
    this.isShowLabel = true,
    this.labelTextStyle,
    this.valueTextStyle,
    this.focusNode,
    this.controller,
    this.autofocus = false,
    this.autovalidate = false,
  });

  @override
  _MyFormTextFieldState createState() => _MyFormTextFieldState();
}

class _MyFormTextFieldState extends State<MyFormTextField> {
  TextEditingController _valueController;
  FocusNode _valueFocusNode;
  bool _isEdited = false;
  TextStyle _labelTextStyle;
  TextStyle _valueTextStyle;

  @override
  void initState() {
    super.initState();

    _labelTextStyle = widget.labelTextStyle;
    _valueTextStyle = widget.valueTextStyle;

    _valueFocusNode = widget.focusNode;

    _valueController = widget.controller;
    if (_valueController == null) {
      _valueController = TextEditingController();
    }
    if (widget.initialValue != null) {
      _valueController.text = widget.initialValue;
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
    if (_labelTextStyle == null) {
      _labelTextStyle = Theme.of(context).textTheme.caption;
    }
    if (_valueTextStyle == null) {
      _valueTextStyle = Theme.of(context).textTheme.body1.copyWith(
        fontSize: 16,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.isShowLabel ? MyFormFieldLabel(
          textStyle: _labelTextStyle,
          label: widget.name,
        ) : Container(),
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: widget.inputHint,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 8, bottom: 0),
                ),
                style: _valueTextStyle,
                keyboardType: TextInputType.number,
                controller: _valueController,
                focusNode: _valueFocusNode,
                autovalidate: _isEdited,
                validator: widget.validator,
              ),
            ),
            widget.valueMutable && _valueController.text.isNotEmpty
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
                      if (textChanged && widget.valueChanged != null) {
                        widget.valueChanged(_valueController.text);
                      }
                    },
                  ) : Container(),
          ],
        )
      ],
    );
  }
}
