import 'package:flutter/material.dart';
import 'package:data_life/repositories/contact_repository.dart';
import 'package:data_life/repositories/contact_provider.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/paging/page_list.dart';
import 'package:data_life/paging/page_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final ContactRepository _contactRepository =
      ContactRepository(ContactProvider());
  // ContactBloc _contactBloc;
  PageBloc _contactBloc;

  @override
  void initState() {
    super.initState();
    // _contactBloc = ContactBloc(contactRepository: _contactRepository);
    _contactBloc = PageBloc<Contact>(pageRepository: _contactRepository);
    _contactBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    _contactBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, top: 16, right: 8, bottom: 8),
        child: BlocBuilder(
          bloc: _contactBloc,
          builder: (context, state) {
            if (state is PageUninitialized) {
              return Center(
                child: Text('No results'),
              );
            }
            if (state is PageLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is PageLoaded<Contact>) {
              PageList pagedList = state.pageList;
              return ListView.builder(
                itemCount: pagedList.total,
                itemBuilder: (context, index) {
                  var contact = pagedList.itemAt(index);
                  if (contact == null) {
                    _contactBloc.getItem(index);
                    return Container(
                      alignment: Alignment.centerLeft,
                      height: 48.0,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text('Loading ...'),
                      ),
                    );
                  }
                  return Container(
                    height: 48.0,
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        contact.name,
                      ),
                    ),
                  );
                },
              );
            }
            if (state is PageError) {
              return Center(
                child: Text('Load contact failed'),
              );
            }
          },
        ),
      ),
    );
  }
}
