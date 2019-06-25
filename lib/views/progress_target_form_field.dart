import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';
import 'labeled_text_form_field.dart';

class ProgressTarget extends StatefulWidget {
  final ValueChanged<num> targetChanged;
  final ValueChanged<num> progressChanged;
  final num initialProgress;
  final num initialTarget;
  final EdgeInsets padding;
  final bool enabled;

  const ProgressTarget({
    this.targetChanged,
    this.progressChanged,
    this.initialProgress,
    this.initialTarget,
    this.padding = EdgeInsets.zero,
    this.enabled,
  });

  @override
  ProgressTargetState createState() {
    return new ProgressTargetState();
  }
}

class ProgressTargetState extends State<ProgressTarget> {
  final _targetController = TextEditingController();
  final _progressController = TextEditingController();

  num _progress;
  num _target;
  num _progressRatio;

  @override
  void initState() {
    super.initState();

    _progress = widget.initialProgress;
    _target = widget.initialTarget;
    _progressRatio = _progress / _target;

    _targetController.text = _target.toString();
    _targetController.addListener(() {
      _target = num.tryParse(_targetController.text) ?? 0.0;
      widget.targetChanged(_target);
      setState(() {});
    });

    _progressController.text = _progress.toString();
    _progressController.addListener(() {
      _progress = num.tryParse(_progressController.text) ?? 0.0;
      widget.progressChanged(_progress);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _targetController.dispose();
    _progressController.dispose();

    super.dispose();
  }

  Widget _createTextInput(String hint, String label,
      TextEditingController controller, initialValue) {
    return LabeledTextFormField(
      initialValue: initialValue,
      labelText: label,
      hintText: hint,
      controller: controller,
      inputType: TextInputType.number,
      enabled: widget.enabled,
    );
  }

  Widget _createProgressTargetFormField() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: _createTextInput('Enter progress', 'Current progress',
              _progressController, widget.initialProgress.toString()),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: _createTextInput(
              AppLocalizations.of(context).enterTarget,
              AppLocalizations.of(context).target,
              _targetController,
              widget.initialTarget.toString()),
        ),
      ],
    );
  }

  Widget _createProgressWidget() {
    if (_target == null || _progress == null) {
      _progressRatio = 0.0;
    } else {
      _progressRatio = _progress / _target;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${AppLocalizations.of(context).progress} ${(_progressRatio * 100.0).toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.caption,
        ),
        SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: _progressRatio,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: FormField(
        builder: (fieldState) {
          return Column(
            children: <Widget>[
              _createProgressTargetFormField(),
              _createProgressWidget(),
              fieldState.hasError
                  ? Text(
                      fieldState.errorText,
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )
                  : Container(),
            ],
          );
        },
        validator: (value) {
          if (_progress > _target) {
            return 'Progress must smaller than target';
          }
          return null;
        },
        autovalidate: true,
      ),
    );
  }
}
