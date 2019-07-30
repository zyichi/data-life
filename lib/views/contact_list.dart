import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/models/contact.dart';

import 'package:data_life/views/contact_edit.dart';

import 'package:data_life/utils/time_util.dart';

class _ContactListItem extends StatelessWidget {
  final Contact contact;

  _ContactListItem({this.contact});

  @override
  Widget build(BuildContext context) {
    if (contact == null) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 48.0,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                child: ContactEdit(
                  contact: contact,
                ),
                type: PageTransitionType.rightToLeft,
              ));
        },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                contact.name,
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 8),
              _createLastMeetTimeWidget(context),
              SizedBox(height: 8),
              _createTotalTimeTogetherWidget(context),
            ],
          ),
        ),
      );
    }
  }

  Widget _createLastMeetTimeWidget(BuildContext context) {
    String s;
    if (contact.lastMeetTime == null) {
      s = '未见面';
    } else {
      s = TimeUtil.dateStringFromMillis(contact.lastMeetTime) +
          ' ' +
          TimeUtil.timeStringFromMillis(contact.lastMeetTime, context);
    }
    return Text(
      '最近见面: $s',
    );
  }

  Widget _createTotalTimeTogetherWidget(BuildContext context) {
    return Text(
      "共呆一起: ${TimeUtil.formatMillisToDHM(contact.totalTimeTogether, context)}",
      style: Theme.of(context).textTheme.caption,
    );
  }
}

class ContactList extends StatefulWidget {
  final String name;

  ContactList({@required this.name}) : assert(name != null);

  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList>
    with AutomaticKeepAliveClientMixin {
  PageBloc<Contact> _contactListBloc;
  Completer<void> _refreshCompleter;

  @override
  void initState() {
    print('ContactList.initState');
    super.initState();

    _contactListBloc = BlocProvider.of<PageBloc<Contact>>(context);
    _contactListBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    print('ContactList.dispose');
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print('ContactList.build');
    super.build(context);
    return BlocListener(
      bloc: _contactListBloc,
      listener: (context, state) {
        print('ContactList ContactBloc listener');
        if (state is PageLoaded || state is PageError) {
          print('ContactList RefreshIndicator complete');
          _refreshCompleter?.complete();
          _refreshCompleter = null;
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 8),
        child: RefreshIndicator(
          onRefresh: () {
            print('ContactList RefreshIndicator onRefresh');
            _refreshCompleter = Completer<void>();
            _contactListBloc.dispatch(RefreshPage());
            return _refreshCompleter.future;
          },
          child: BlocBuilder(
            bloc: _contactListBloc,
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
                return ListView.separated(
                  key: PageStorageKey<String>(widget.name),
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: pagedList.total,
                  itemBuilder: (context, index) {
                    Contact contact = pagedList.itemAt(index);
                    if (contact == null) {
                      _contactListBloc.getItem(index);
                    }
                    return _ContactListItem(
                      contact: contact,
                    );
                  },
                );
              }
              if (state is PageError) {
                return Center(
                  child: Text('Load contact failed'),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
