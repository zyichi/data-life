import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';

import 'package:data_life/paging/page_bloc.dart';
import 'package:data_life/paging/page_list.dart';

import 'package:data_life/models/location.dart';

import 'package:data_life/views/location_edit.dart';

import 'package:data_life/utils/time_util.dart';

class _LocationListItem extends StatelessWidget {
  final Location location;

  _LocationListItem({this.location});

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return Container(
        alignment: Alignment.centerLeft,
        height: 48.0,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 8.0, bottom: 8.0, right: 16),
          child: Text('Loading ...'),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              PageTransition(
                child: LocationEdit(
                  location: location,
                ),
                type: PageTransitionType.rightToLeft,
              ));
        },
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 8.0, right: 16, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                location.name,
                style: Theme.of(context).textTheme.title,
              ),
              SizedBox(height: 8),
              _createLastActiveTimeWidget(context),
              _createTotalTimeStayWidget(context),
            ],
          ),
        ),
      );
    }
  }

  Widget _createLastActiveTimeWidget(BuildContext context) {
    String s;
    if (location.lastVisitTime == null) {
      s = '未去过';
    } else {
      s = TimeUtil.dateStringFromMillis(location.lastVisitTime) +
          ' ' +
          TimeUtil.timeStringFromMillis(location.lastVisitTime, context);
    }
    return Text(
      '最近停留: $s',
    );
  }

  Widget _createTotalTimeStayWidget(BuildContext context) {
    return Text(
      "总共停留: ${TimeUtil.formatMillisToDHM(location.totalTimeStay, context)}",
    );
  }
}

class LocationList extends StatefulWidget {
  final String name;

  LocationList({@required this.name}) : assert(name != null);

  @override
  _LocationListState createState() => _LocationListState();
}

class _LocationListState extends State<LocationList>
    with AutomaticKeepAliveClientMixin {
  PageBloc<Location> _locationListBloc;

  @override
  void initState() {
    print('LocationList.initState');
    super.initState();

    _locationListBloc = BlocProvider.of<PageBloc<Location>>(context);
    _locationListBloc.dispatch(RefreshPage());
  }

  @override
  void dispose() {
    print('LocationList.dispose');

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    print('LocationList.build');
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(left: 0, top: 8, right: 0, bottom: 8),
      child: BlocBuilder(
        bloc: _locationListBloc,
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
          if (state is PageLoaded<Location>) {
            PageList pagedList = state.pageList;
            return ListView.separated(
              key: PageStorageKey<String>(widget.name),
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: pagedList.total,
              itemBuilder: (context, index) {
                Location location = pagedList.itemAt(index);
                if (location == null) {
                  _locationListBloc.getItem(index);
                }
                return _LocationListItem(
                  location: location,
                );
              },
            );
          }
          if (state is PageError) {
            return Center(
              child: Text('Load location failed'),
            );
          }
          return null;
        },
      ),
    );
  }
}
