import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';
import 'package:data_life/models/moment.dart';
import 'package:data_life/views/moment_edit.dart';

import 'package:data_life/models/contact.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/views/my_color.dart';
import 'package:data_life/utils/time_format.dart';


class _MomentListItem extends StatelessWidget {
  final Moment moment;

  _MomentListItem({this.moment});

  @override
  Widget build(BuildContext context) {
    if (moment == null) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 48.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 0, top: 8.0, bottom: 8.0),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return InkWell(
        onTap: () async {
          var saved = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      MomentEdit(
                        moment: moment,
                      ),
                  fullscreenDialog: true));
          if (saved == true) {
            print('Moment edited, refresh moment/contact/location list');
            BlocProvider.of<PageBloc<Moment>>(context).dispatch(RefreshPage());
            BlocProvider.of<PageBloc<Contact>>(context).dispatch(RefreshPage());
            BlocProvider.of<PageBloc<Location>>(context).dispatch(RefreshPage());
          }
        },
        child: Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 0.0, top: 8.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  moment.action.name,
                  style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 18),
                ),
                SizedBox(height: 8.0,),
                _createTimeWidget(context),
                Text(
                  moment.location.displayAddress,
                ),
                _createContactsWidget(),
                SizedBox(height: 8.0,),
                _createDurationWidget(context),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _createContactsWidget() {
    var names = moment.contacts.map((Contact contact) {
      return contact.name;
    }).toList();
    names.insert(0, 'Me');
    return Text(names.join(', '));
  }

  Widget _createDurationWidget(BuildContext context) {
    List<int> l = dayHourMinuteFromSeconds(moment.durationInSeconds());
    int days = l[0];
    int hours = l[1];
    int minutes = l[2];
    String dayStr = days == 0 ? '' : '$days days';
    String hourStr = hours == 0 ? '' : '$hours hours';
    String minuteStr = minutes == 0 ? '' : '$minutes minutes';
    String s;
    if (dayStr.isEmpty && hourStr.isEmpty && minuteStr.isEmpty) {
      s = '0 minutes';
    } else {
      s = "$dayStr${dayStr.isEmpty ? '' : ' '}$hourStr${hourStr.isEmpty ? '' : ' '}$minuteStr${minuteStr.isEmpty ? '' : ' '}";
    }
    return Text(
      'Duration: $s',
      style: Theme
          .of(context)
          .textTheme
          .caption,
    );
  }

  Widget _createTimeWidget(BuildContext context) {
    String s = formatDateForDisplayMillis(moment.beginTime)
        + ' ' + formatTimeForDisplayMillis(moment.beginTime, context);
    return Text(
      '$s',
    );
  }
}

class MomentList extends StatefulWidget {
  final String name;

  MomentList({@required this.name}) : assert(name != null);

  @override
  _MomentListState createState() => _MomentListState();
}

class _MomentListState extends State<MomentList>
    with AutomaticKeepAliveClientMixin {
  PageBloc<Moment> _momentBloc;

  @override
  void initState() {
    print('MomentList.initState');
    super.initState();

    _momentBloc = BlocProvider.of<PageBloc<Moment>>(context);
    _momentBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    print('MomentList.dispose');
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print('MomentList.build');
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
      child: BlocBuilder(
        bloc: _momentBloc,
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
          if (state is PageLoaded<Moment>) {
            PageList pagedList = state.pageList;
            return ListView.separated(
              key: PageStorageKey<String>(widget.name),
              separatorBuilder: (context, index) {
                return Divider(
                  color: MyColor.greyDivider,
                );
              },
              itemCount: pagedList.total,
              itemBuilder: (context, index) {
                Moment moment = pagedList.itemAt(index);
                if (moment == null) {
                  _momentBloc.getItem(index);
                }
                return _MomentListItem(
                  moment: moment,
                );
              },
            );
          }
          if (state is PageError) {
            return Center(
              child: Text('Load moment failed'),
            );
          }
        },
      ),
    );
  }
}
