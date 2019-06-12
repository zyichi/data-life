import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';


class CommonDialog {

  static Future<bool> showEditExitConfirmDialog(BuildContext context, String text) async {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
    theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            text,
            style: dialogTextStyle,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).keepEditing),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).discard),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      },
    ) ??
        false;
  }

}