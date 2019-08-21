import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/blocs/moment_bloc.dart';

import 'package:data_life/views/moment_edit.dart';

import 'package:data_life/models/contact.dart';
import 'package:data_life/models/moment.dart';

import 'package:data_life/utils/time_util.dart';

class _MomentListItem extends StatelessWidget {
  final Moment moment;
  final MomentBloc momentBloc;

  _MomentListItem({this.moment, this.momentBloc});

  @override
  Widget build(BuildContext context) {
    if (moment == null) {
      return Container(
        alignment: Alignment.center,
        height: 48.0,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 8.0, right: 16, bottom: 8.0),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, top: 8, right: 0, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        moment.action.name,
                        style: Theme.of(context).textTheme.title,
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert,
                          color: _captionColor(context),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            momentBloc.dispatch(DeleteMoment(moment: moment));
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.delete,
                                    color: _captionColor(context),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: _captionColor(context)),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, top: 8, right: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _createTimeWidget(context, '开始时间', moment.beginTime),
                      Divider(),
                      _createTimeWidget(context, '结束时间', moment.endTime),
                      Divider(),
                      _createDurationWidget(context),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('地点'),
                          Text(
                            '${moment.location.name}',
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      Divider(),
                      _createContactsWidget(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Color _captionColor(BuildContext context) {
    return Theme.of(context).textTheme.caption.color;
  }

  Widget _createContactsWidget(BuildContext context) {
    var names = moment.contacts.map((Contact contact) {
      return contact.name;
    }).toList();
    names.insert(0, '我');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('参加的人'),
        Text(
          '${names.join(', ')}',
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _createDurationWidget(BuildContext context) {
    List<int> l = TimeUtil.dayHourMinuteFromSeconds(moment.durationInSeconds());
    int days = l[0];
    int hours = l[1];
    int minutes = l[2];
    String dayStr = days == 0 ? '' : '$days 天';
    String hourStr = hours == 0 ? '' : '$hours 小时';
    String minuteStr = minutes == 0 ? '' : '$minutes 分钟';
    String s;
    if (dayStr.isEmpty && hourStr.isEmpty && minuteStr.isEmpty) {
      s = '0 分钟';
    } else {
      s = "$dayStr${dayStr.isEmpty ? '' : ' '}$hourStr${hourStr.isEmpty ? '' : ' '}$minuteStr${minuteStr.isEmpty ? '' : ' '}";
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('用时'),
        Text(
          '$s',
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  Widget _createTimeWidget(BuildContext context, String label, int t) {
    String s = TimeUtil.dateStringFromMillis(t) +
        ' ' +
        TimeUtil.timeStringFromMillis(t, context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label),
        Text(
          '$s',
          style: Theme.of(context).textTheme.caption.copyWith(fontSize: 14),
        ),
      ],
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
  MomentBloc _momentBloc;

  @override
  void initState() {
    super.initState();

    _momentListBloc = BlocProvider.of<PageBloc<Moment>>(context);
    _momentListBloc.dispatch(RefreshPage());

    _momentBloc = BlocProvider.of<MomentBloc>(context);
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
    return Container(
      color: Colors.grey[200],
      child: Padding(
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
              return ListView.builder(
                key: PageStorageKey<String>(widget.name),
                itemCount: pagedList.total,
                itemBuilder: (context, index) {
                  Moment moment = pagedList.itemAt(index);
                  if (moment == null) {
                    _momentListBloc.getItem(index);
                  }
                  return _MomentListItem(
                    moment: moment,
                    momentBloc: _momentBloc,
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
      ),
    );
  }

  Widget _createEmptyResults() {
    return Center(
      child: Text(
        'No moments',
        style: Theme.of(context).textTheme.display2,
      ),
    );
  }
}
