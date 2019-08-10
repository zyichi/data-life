import 'package:flutter/material.dart';

import 'package:data_life/views/tap_only_text_field.dart';
import 'package:data_life/views/my_bottom_sheet.dart';
import 'package:data_life/views/goal_edit.dart';
import 'package:data_life/views/moment_edit.dart';


class _BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() {
    return new _BottomBarState();
  }
}

class _BottomBarState extends State<_BottomBar> {
  void addMomentOnTap() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MomentEdit(),
          fullscreenDialog: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16.0,
      child: Padding(
        padding:
        const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TapOnlyTextField(
                onTap: addMomentOnTap,
                hintText: 'Add moment',
              ),
            ),
            IconButton(
              icon: Icon(Icons.outlined_flag),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => GoalEdit(),
                    fullscreenDialog: true,
                    settings: RouteSettings(name: GoalEdit.routeName),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return MyBottomSheet();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
