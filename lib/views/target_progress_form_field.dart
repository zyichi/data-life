import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';
import 'labeled_text_form_field.dart';


class TargetProgress extends StatefulWidget {
  final ValueChanged<num> targetChanged;
  final ValueChanged<num> alreadyDoneChanged;

  const TargetProgress(this.targetChanged, this.alreadyDoneChanged);

  @override
  TargetProgressState createState() {
    return new TargetProgressState();
  }
}

class TargetProgressState extends State<TargetProgress> {
  final _targetController = TextEditingController();
  final _alreadyDoneController = TextEditingController();

  var _target;
  var _alreadyDone;
  var _progressValue;

  @override
  void initState() {
    super.initState();

    _targetController.addListener(() {
      _target = num.tryParse(_targetController.text);
      widget.targetChanged(_target);
      setState(() {});
    });

    _alreadyDoneController.addListener(() {
      _alreadyDone = num.tryParse(_alreadyDoneController.text);
      widget.alreadyDoneChanged(_alreadyDone);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _targetController.dispose();
    _alreadyDoneController.dispose();

    super.dispose();
  }

  Widget _createTextInput(
      String hint, String label, TextEditingController controller) {
    return LabeledTextFormField(
      labelText: label,
      hintText: hint,
      controller: controller,
      inputType: TextInputType.number,
    );
  }

  Widget _createTargetFormField() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: _createTextInput(AppLocalizations.of(context).enterTarget,
                AppLocalizations.of(context).target, _targetController),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 5,
            child: _createTextInput(
                AppLocalizations.of(context).enterFinished,
                AppLocalizations.of(context).finished,
                _alreadyDoneController),
          ),
        ],
      ),
    );
  }

  Widget _createProgressWidget() {
    if (_target == null || _alreadyDone == null) {
      _progressValue = 0.0;
    } else {
      _progressValue = _alreadyDone / _target;
    }
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, top: 8.0, right: 16.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${AppLocalizations.of(context).progress} ${(_progressValue * 100.0).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(
            height: 8.0,
          ),
          LinearProgressIndicator(
            value: _progressValue,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _createTargetFormField(),
        _createProgressWidget(),
      ],
    );
  }
}
