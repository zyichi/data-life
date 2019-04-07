import 'package:flutter/material.dart';

import 'package:data_life/localizations.dart';
import 'package:data_life/utils/time_format.dart';
import 'package:data_life/blocs/event_bloc.dart';
import 'package:data_life/blocs/event_slice.dart';


class EventList extends StatefulWidget {
  @override
  EventListState createState() {
    return new EventListState();
  }
}

class EventListState extends State<EventList> {
  bool _initEventStream = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final eventBloc = EventProvider.of(context);
    if (_initEventStream) {
      _initEventStream = false;
      eventBloc.invalid.add(true);
    }

    return Scrollbar(
      child: StreamBuilder(
        stream: eventBloc.slice,
        initialData: eventBloc.slice.value,
        builder: (context, snapshot) => ListView.builder(
              key: PageStorageKey('tabEvents'),
              itemCount: snapshot.data.totalCount,
              itemBuilder: (context, index) =>
                  _createEventTile(index, snapshot.data, eventBloc),
            ),
      ),
    );
  }

  Widget _createEventTile(
      int index, EventSlice slice, EventBloc eventBloc) {
    eventBloc.index.add(index);

    final event = slice.elementAt(index);

    if (event == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListTile(
      title: Text('Event of activity ${event.activityId}'),
      subtitle: Text(
        '${AppLocalizations.of(context).time}: ${formatTime(event.beginTime)}',
      ),
    );
  }
}
