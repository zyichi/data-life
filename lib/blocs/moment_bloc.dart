import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'dart:math';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/todo.dart';
import 'package:data_life/models/moment_contact.dart';

import 'package:data_life/repositories/moment_repository.dart';
import 'package:data_life/repositories/action_repository.dart';
import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/repositories/contact_repository.dart';
import 'package:data_life/repositories/todo_repository.dart';
import 'package:data_life/repositories/goal_repository.dart';

abstract class MomentEvent {}

abstract class MomentState {}

class AddMoment extends MomentEvent {
  final Moment moment;
  final Todo todo;

  AddMoment({@required this.moment, this.todo}) : assert(moment != null);
}

class DeleteMoment extends MomentEvent {
  final Moment moment;

  DeleteMoment({@required this.moment}) : assert(moment != null);
}

class UpdateMoment extends MomentEvent {
  final Moment oldMoment;
  final Moment newMoment;

  UpdateMoment({@required this.oldMoment, @required this.newMoment})
      : assert(oldMoment != null),
        assert(newMoment != null);
}

class MomentUninitialized extends MomentState {}

class MomentAdded extends MomentState {
  final Moment moment;
  MomentAdded({this.moment}) : assert(moment != null);
}

class MomentDeleted extends MomentState {
  final Moment moment;
  MomentDeleted({this.moment}) : assert(moment != null);
}

class MomentUpdated extends MomentState {
  final Moment newMoment;
  final Moment oldMoment;
  MomentUpdated({this.newMoment, this.oldMoment});
}

class MomentFailed extends MomentState {
  final String error;

  MomentFailed({this.error}) : assert(error != null);
}

class MomentBloc extends Bloc<MomentEvent, MomentState> {
  final MomentRepository momentRepository;
  final ActionRepository actionRepository;
  final LocationRepository locationRepository;
  final ContactRepository contactRepository;
  final TodoRepository todoRepository;
  final GoalRepository goalRepository;

  MomentBloc(
      {@required this.momentRepository,
      @required this.actionRepository,
      @required this.locationRepository,
      @required this.contactRepository,
      @required this.goalRepository,
      @required this.todoRepository})
      : assert(momentRepository != null),
        assert(actionRepository != null),
        assert(locationRepository != null),
        assert(contactRepository != null),
        assert(goalRepository != null),
        assert(todoRepository != null);

  @override
  MomentState get initialState => MomentUninitialized();

  @override
  Stream<MomentState> mapEventToState(MomentEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is AddMoment) {
      final Moment moment = event.moment;
      try {
        await _addMoment(moment, now);
        yield MomentAdded(moment: moment);
      } catch (e) {
        var error = 'Add moment ${moment.action.name} failed: ${e.toString()}';
        print(error);
        yield MomentFailed(error: error);
      }
    }
    if (event is UpdateMoment) {
      final oldMoment = event.oldMoment;
      final newMoment = event.newMoment;
      try {
        await _deleteMoment(oldMoment, now);
        await _addMoment(newMoment, now);
        yield MomentUpdated(newMoment: newMoment, oldMoment: oldMoment);
      } catch (e) {
        var error =
            'Update moment ${oldMoment.action.name} failed: ${e.toString()}';
        print(error);
        yield MomentFailed(error: error);
      }
    }
    if (event is DeleteMoment) {
      Moment moment = event.moment;
      try {
        await _deleteMoment(moment, now);
        yield MomentDeleted(moment: moment);
      } catch (e) {
        var error =
            'Delete moment ${moment.action.name} failed: ${e.toString()}';
        print(error);
        yield MomentFailed(error: error);
      }
    }
  }

  Future<void> _addMoment(Moment moment, int now) async {
    moment.createTime = now;
    var action = moment.action;
    MyAction dbAction = await actionRepository.getViaName(action.name);
    if (dbAction != null) {
      action.copy(dbAction);
      action.updateTime = now;
      action.lastActiveTime = max(action.lastActiveTime, moment.beginTime);
    } else {
      action.createTime = now;
      action.lastActiveTime = moment.beginTime;
    }
    action.totalTimeTaken += moment.duration;
    await actionRepository.save(action);
    moment.actionId = action.id;
    // Process location.
    var location = moment.location;
    Location dbLocation = await locationRepository.getViaName(location.name);
    if (dbLocation != null) {
      location.copy(dbLocation);
      location.updateTime = now;
      location.lastVisitTime = max(location.lastVisitTime, moment.beginTime);
    } else {
      location.createTime = now;
      location.lastVisitTime = moment.beginTime;
    }
    location.totalTimeStay += moment.duration;
    await locationRepository.save(location);
    moment.locationId = location.id;

    if (moment.createTime != null) {
      moment.updateTime = now;
    } else {
      moment.createTime = now;
    }
    await momentRepository.add(moment);

    // Process contact.
    for (Contact contact in moment.contacts) {
      var dbContact = await contactRepository.getViaName(contact.name);
      if (dbContact != null) {
        contact.copy(dbContact);
        contact.updateTime = now;
      } else {
        contact.createTime = now;
        contact.lastMeetTime = moment.beginTime;
        contact.firstMeetTime = moment.beginTime;
        contact.firstKnowTime = moment.beginTime;
        contact.firstMeetLocation = moment.location.id;
      }
      contact.totalTimeTogether += moment.duration;
      contact.lastMeetTime = max(contact.lastMeetTime, moment.beginTime);
      await contactRepository.save(contact);
      var momentContact = MomentContact();
      momentContact.momentUuid = moment.uuid;
      momentContact.contactId = contact.id;
      momentContact.momentBeginTime = moment.beginTime;
      momentContact.momentDuration = moment.duration;
      momentContact.createTime = now;
      await momentRepository.saveMomentContact(momentContact);
    }
  }

  Future<void> _deleteMoment(Moment moment, int now) async {
    await momentRepository.delete(moment);

    // Update action.
    var action = moment.action;
    action.lastActiveTime =
        await momentRepository.getActionLastActiveTime(action.id);
    action.totalTimeTaken =
        await momentRepository.getActionTotalTimeTaken(action.id);
    action.updateTime = now;
    await actionRepository.save(action);

    // Update location.
    var location = moment.location;
    location.lastVisitTime =
        await momentRepository.getLocationLastVisitTime(location.id);
    location.totalTimeStay =
        await momentRepository.getLocationTotalTimeStay(location.id);
    location.updateTime = now;
    await locationRepository.save(location);

    // Update contacts.
    await momentRepository.deleteMomentContactViaMomentUuid(moment.uuid);
    for (Contact contact in moment.contacts) {
      contact.lastMeetTime =
          await momentRepository.getContactLastMeetTime(contact.id);
      contact.totalTimeTogether =
          await momentRepository.getContactTotalTimeTogether(contact.id);
      contact.updateTime = now;
      await contactRepository.save(contact);
    }
  }

  Future<List<Contact>> getContactSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return contactRepository.get(startIndex: 0, count: 8);
    } else {
      return contactRepository.search(pattern, 8);
    }
  }

  Future<List<MyAction>> getActionSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return actionRepository.get(startIndex: 0, count: 8);
    } else {
      return actionRepository.search(pattern);
    }
  }
}
