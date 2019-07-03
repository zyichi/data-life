import 'package:flutter/material.dart';

import 'package:data_life/views/location_list.dart';


class LocationPage extends StatefulWidget {
  static final String routeName = '/location';

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final String _title = 'Location';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: LocationList(name: _title),
    );
  }
}
