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


class MyFormFieldLabel extends StatelessWidget {
  final String label;
  final EdgeInsets padding;

  const MyFormFieldLabel(
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

  @override
  void initState() {
    super.initState();

    _valueController.text = widget.initialValue ?? '';

    _valueController.addListener(() {
      widget.valueChanged(_valueController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MyFormFieldLabel(
          label: widget.name,
        ),
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
                keyboardType: TextInputType.number,
                controller: _valueController,
                focusNode: _valueFocusNode,
                autovalidate: true,
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
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 20,
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
