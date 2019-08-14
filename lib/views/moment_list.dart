import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/views/moment_edit.dart';

import 'package:data_life/models/contact.dart';
import 'package:data_life/models/moment.dart';

import 'package:data_life/utils/time_util.dart';

class _MomentListItem extends StatelessWidget {
  final Moment moment;

  _MomentListItem({this.moment});

  @override
  Widget build(BuildContext context) {
    if (moment == null) {
      return Container(
        alignment: Alignment.center,
        height: 48.0,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8.0, right: 16, bottom: 8.0),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                child: MomentEdit(
                  moment: moment,
                ),
                type: PageTransitionType.rightToLeft,
              ));
        },
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 8.0, bottom: 8.0, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                moment.action.name,
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 8.0),
              _createTimeWidget(context),
              _createDurationWidget(context),
              Text(
                '${moment.location.name}',
              ),
              _createContactsWidget(),
            ],
          ),
        ),
      );
    }
  }

  Widget _createContactsWidget() {
    var names = moment.contacts.map((Contact contact) {
      return contact.name;
    }).toList();
    names.insert(0, '我');
    return Text('${names.join(', ')}');
  }

  Widget _createDurationWidget(BuildContext context) {
    List<int> l = TimeUtil.dayHourMinuteFromSeconds(moment.durationInSeconds());
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
      '$s',
    );
  }

  Widget _createTimeWidget(BuildContext context) {
    String s = TimeUtil.dateStringFromMillis(moment.beginTime) +
        ' ' +
        TimeUtil.timeStringFromMillis(moment.beginTime, context);
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
  PageBloc<Moment> _momentListBloc;

  @override
  void initState() {
    super.initState();

    _momentListBloc = BlocProvider.of<PageBloc<Moment>>(context);
    _momentListBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 8),
      child: BlocBuilder(
        bloc: _momentListBloc,
        builder: (context, state) {
          if (state is PageUninitialized) {
            return _createEmptyResults();
          }
          if (state is PageLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is PageLoaded<Moment>) {
            PageList pagedList = state.pageList;
            if (pagedList.total == 0) {
              return _createEmptyResults();
            }
            return ListView.separated(
              key: PageStorageKey<String>(widget.name),
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: pagedList.total,
              itemBuilder: (context, index) {
                Moment moment = pagedList.itemAt(index);
                if (moment == null) {
                  _momentListBloc.getItem(index);
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
          return null;
        },
      ),
    );
  }

  Widget _createEmptyResults() {
    return Center(
      child: Text('No moments',
        style: Theme.of(context).textTheme.display2,
      ),
    );
  }

}
