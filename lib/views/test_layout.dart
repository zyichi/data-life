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

  @override
  void initState() {
    super.initState();
    sortedNums = nums.sublist(0, nums.length-2);
    sortedNums.sort((a, b) {return b.compareTo(a);});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('$nums'),
            Text('$sortedNums'),
          ],
        ),
      ),
    );
  }
}

