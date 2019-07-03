import 'package:flutter/material.dart';

import 'package:data_life/views/contact_list.dart';


class ContactPage extends StatefulWidget {
  static final String routeName = '/contacts';

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final String _title = 'Contacts';

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
      body: ContactList(name: _title),
    );
  }
}
