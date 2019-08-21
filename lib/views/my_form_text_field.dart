import 'package:flutter/material.dart';

Color mutableFieldColor(bool valueMutable, BuildContext context) {
  if (valueMutable) {
    return Colors.black;
  } else {
    return captionColor(context);
  }
}

TextStyle fieldNameTextStyle() {
  return TextStyle(
    fontSize: 16,
  );
}

TextStyle fieldValueTextStyle(bool valueMutable, BuildContext context) {
  return TextStyle(
    fontSize: 16,
    color: mutableFieldColor(valueMutable, context),
  );
}

Color captionColor(BuildContext context) {
  return Theme.of(context).textTheme.caption.color;
}

class MyImmutableFormTextField extends StatelessWidget {
  final String name;
  final String value;

  MyImmutableFormTextField({this.name, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
              flex: 2,
              child: Text(
                name,
                style: fieldNameTextStyle(),
              )),
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: fieldValueTextStyle(false, context),
                  ),
                ),
              ],
            ),
          )
        ],
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

  MyFormTextField({
    this.name,
    this.initialValue,
    this.inputHint,
    this.valueChanged,
    this.valueMutable,
    this.validator,
  });

  @override
  _MyFormTextFieldState createState() => _MyFormTextFieldState();
}

class _MyFormTextFieldState extends State<MyFormTextField> {
  TextEditingController _valueController = TextEditingController();
  FocusNode _valueFocusNode = FocusNode();
  String _value;
  String _error;

  @override
  void initState() {
    super.initState();

    _value = widget.initialValue ?? '';
    _valueController.text = _value;

    _valueController.addListener(() {
      setState(() {
        _value = _valueController.text;
        _error = widget.validator(_value);
      });
      widget.valueChanged(_value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                flex: 2,
                child: Text(
                  widget.name,
                  style: fieldNameTextStyle(),
                )),
            Expanded(
              flex: 3,
              child: Container(
                color: widget.valueMutable ? Colors.grey[100] : Colors.white,
                padding: EdgeInsets.only(left: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: widget.inputHint,
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(signed: true),
                        textAlign: widget.valueMutable
                            ? TextAlign.left
                            : TextAlign.right,
                        style:
                            fieldValueTextStyle(widget.valueMutable, context),
                        controller: _valueController,
                        focusNode: _valueFocusNode,
                      ),
                    ),
                    GestureDetector(
                      child: widget.valueMutable &&
                              _value.isNotEmpty &&
                              _valueFocusNode.hasFocus
                          ? Container(
                              color: Colors.grey[100],
                              width: 32,
                              height: 32,
                              child: Center(
                                child: Icon(
                                  Icons.clear,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Container(),
                      onTap: () {
                        setState(() {
                          _value = '';
                          _valueController.text = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        _showError(_error),
      ],
    );
  }

  Widget _showError(String error) {
    if (error != null) {
      return Text(
        error,
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }
    return Container();
  }
}
