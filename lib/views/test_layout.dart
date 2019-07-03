import 'package:flutter/material.dart';

class TestLayout extends StatefulWidget {
  static String routeName = 'TestLayout';

  @override
  TestLayoutState createState() {
    return new TestLayoutState();
  }
}

class TestLayoutState extends State<TestLayout> {
  // final nums = [3, 1, 2, -8, -12, 10, 4, 3, 5, 1];
  final nums = List.generate(8, (i) => i);
  List<int> sortedNums;
  bool _switchValue = false;

  @override
  void initState() {
    super.initState();
    sortedNums = nums.sublist(0, nums.length - 2);
    sortedNums.sort((a, b) {
      return b.compareTo(a);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('TestLayoutState.build');
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('$nums'),
            Text('$sortedNums'),
            Switch.adaptive(
                value: _switchValue,
                onChanged: (value) {
                  print(value);
                  setState(() {
                    _switchValue = value;
                  });
                }),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, top: 0, right: 16, bottom: 8),
              child: Row(
                children: <Widget>[
                  Icon(Icons.lock),
                  SizedBox(width: 16),
                  Text('Privacy mode'),
                  Spacer(flex: 2),
                  Switch.adaptive(
                    value: _switchValue,
                    onChanged: (value) {
                      setState(() {
                        print('Privacy mode: $value');
                        _switchValue = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
