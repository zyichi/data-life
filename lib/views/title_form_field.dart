import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';


class TitleFormField extends StatefulWidget {
  final ValueChanged<String> titleChanged;

  TitleFormField(this.titleChanged);

  @override
  TitleFormFieldState createState() {
    return new TitleFormFieldState();
  }
}

class TitleFormFieldState extends State<TitleFormField> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.addListener(() {
      widget.titleChanged(_nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: TextFormField(
        maxLines: 1,
        validator: (value) {},
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).enterTitle,
          border: InputBorder.none,
        ),
        controller: _nameController,
        style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 24),
      ),
    );
  }
}
