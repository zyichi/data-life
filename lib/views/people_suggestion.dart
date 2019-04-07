import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

const List<String> _peopleList = ['丫宝', '张一驰', '张凌空', '爸爸', '妈妈', '于长旭', '芳芳'];

class PeopleSuggestion extends StatefulWidget {
  @override
  _PeopleSuggestionState createState() => _PeopleSuggestionState();
}

class _PeopleSuggestionState extends State<PeopleSuggestion> {
  final _peopleSet = Set<String>();
  TextEditingController _peopleController;
  TextEditingController _testController;
  var _selectedPeople = List<String>();
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _peopleController = TextEditingController();
    _testController = TextEditingController();
    _focusNode = FocusNode();
    _peopleSet.addAll(_peopleList);
  }

  @override
  void dispose() {
    // _peopleController.dispose();
    _testController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Widget> _selectedPeopleWidget() {
    return _selectedPeople.map((people) {
      return InputChip(
        padding: EdgeInsets.only(left: 4.0, right: 4.0),
        backgroundColor: Colors.grey[200],
        label: Text(people),
        avatar: Icon(Icons.person),
        deleteIcon: Icon(
          Icons.clear,
          size: 20.0,
        ),
        onDeleted: () {
          setState(() {
            _selectedPeople.remove(people);
          });
          FocusScope.of(context).requestFocus(_focusNode);
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Name'),
            _selectedPeople.isEmpty
                ? Container()
                : Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8.0,
                    children: _selectedPeopleWidget(),
                  ),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                autofocus: true,
                controller: _peopleController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              suggestionsBoxDecoration: SuggestionsBoxDecoration(),
              suggestionsCallback: (pattern) {
                if (pattern.isNotEmpty) {
                  return _peopleList.map((name) {
                    return name;
                  }).toList();
                } else {
                  return [];
                }
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(suggestion),
                  dense: true,
                  isThreeLine: false,
                );
              },
              hideOnEmpty: true,
              onSuggestionSelected: (suggestion) {
                setState(() {
                  _selectedPeople.add(suggestion);
                });
                FocusScope.of(context).requestFocus(_focusNode);
                _peopleController.text = '';
              },
            ),
          ],
        ),
      ),
    );
  }
}
