import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/location.dart';
import 'package:data_life/models/contact.dart';
import 'package:data_life/models/moment_contact.dart';

import 'package:data_life/repositories/moment_repository.dart';
import 'package:data_life/repositories/action_repository.dart';
import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/repositories/contact_repository.dart';

abstract class MomentEditEvent {}

abstract class MomentEditState {}

class AddMoment extends MomentEditEvent {
  final Moment moment;

  AddMoment({@required this.moment}) : assert(moment != null);
}

class DeleteMoment extends MomentEditEvent {
  final Moment moment;

  DeleteMoment({@required this.moment}) : assert(moment != null);
}

class UpdateMoment extends MomentEditEvent {
  final Moment oldMoment;
  final Moment newMoment;

  UpdateMoment({@required this.oldMoment, @required this.newMoment})
      : assert(oldMoment != null),
        assert(newMoment != null);
}

class MomentUninitialized extends MomentEditState {}

class MomentAdded extends MomentEditState {}

class MomentDeleted extends MomentEditState {
  final Moment moment;

  MomentDeleted({this.moment}) : assert(moment != null);
}

class MomentUpdated extends MomentEditState {}

class MomentEditFailed extends MomentEditState {
  final String error;

  MomentEditFailed({this.error}) : assert(error != null);
}

class MomentEditBloc extends Bloc<MomentEditEvent, MomentEditState> {
  final MomentRepository momentRepository;
  final ActionRepository actionRepository;
  final LocationRepository locationRepository;
  final ContactRepository contactRepository;

  MomentEditBloc(
      {@required this.momentRepository,
      @required this.actionRepository,
      @required this.locationRepository,
      @required this.contactRepository})
      : assert(momentRepository != null),
        assert(actionRepository != null),
        assert(locationRepository != null),
        assert(contactRepository != null) {
    print('MomentEditBloc.MomentEditBloc()');
  }

  @override
  MomentEditState get initialState => MomentUninitialized();

  @override
  Stream<MomentEditState> mapEventToState(MomentEditEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is AddMoment) {
      final Moment moment = event.moment;
      try {
        moment.createTime = now;
        moment.action.totalTimeTaken += moment.durationInMillis();
        // Process action
        await _updateMomentActionInfo(moment, now);
        await actionRepository.save(moment.action);
        moment.actionId = moment.action.id;
        // Process location.
        await _updateMomentLocationInfo(moment, now);
        moment.location.totalTimeStay += moment.durationInMillis();
        await locationRepository.save(moment.location);
        moment.locationId = moment.location.id;

        await momentRepository.save(moment);
        // Process contact.
        await _updateMomentContactInfo(moment, now);
        for (Contact contact in moment.contacts) {
          contact.totalTimeTogether += moment.durationInMillis();
          await contactRepository.save(contact);
          var momentContact = MomentContact();
          momentContact.momentId = moment.id;
          momentContact.contactId = contact.id;
          momentContact.momentBeginTime = moment.beginTime;
          momentContact.createTime = now;
          await momentRepository.saveMomentContact(momentContact);
        }
        yield MomentAdded();
      } catch (e) {
        yield MomentEditFailed(
            error: 'Add moment ${moment.action.name} failed: ${e.toString()}');
      }
    }
    if (event is UpdateMoment) {
      final oldMoment = event.oldMoment;
      final newMoment = event.newMoment;
      try {
        newMoment.id = oldMoment.id;
        newMoment.createTime = oldMoment.createTime;
        newMoment.updateTime = now;
        // Process action.
        await _updateMomentActionInfo(newMoment, now);
        if (newMoment.action.id == oldMoment.action.id) {
          // Action not change.
          newMoment.action.totalTimeTaken = newMoment.action.totalTimeTaken -
              oldMoment.durationInMillis() +
              newMoment.durationInMillis();
        } else {
          // Action changed.
          newMoment.action.totalTimeTaken += newMoment.durationInMillis();
          oldMoment.action.totalTimeTaken -= oldMoment.durationInMillis();
          oldMoment.action.lastActiveTime = await momentRepository
              .getActionLastActiveTime(oldMoment.action.id, oldMoment.id);
          await actionRepository.save(oldMoment.action);
        }
        await actionRepository.save(newMoment.action);
        newMoment.actionId = newMoment.action.id;
        // Process location.
        await _updateMomentLocationInfo(newMoment, now);
        if (newMoment.location.id == oldMoment.location.id) {
          // Location not change
          newMoment.location.totalTimeStay = newMoment.location.totalTimeStay -
              oldMoment.durationInMillis() +
              newMoment.durationInMillis();
        } else {
          // Location changed
          newMoment.location.totalTimeStay += newMoment.durationInMillis();
          oldMoment.location.totalTimeStay -= oldMoment.durationInMillis();
          oldMoment.location.lastVisitTime = await momentRepository
              .getLocationLastVisitTime(oldMoment.location.id, oldMoment.id);
          await locationRepository.save(oldMoment.location);
        }
        await locationRepository.save(newMoment.location);
        newMoment.locationId = newMoment.location.id;

        await momentRepository.save(newMoment);

        // Process contact.
        _updateMomentContactInfo(newMoment, now);
        for (Contact contact in newMoment.contacts) {
          if (oldMoment.contacts.contains(contact)) {
            // Contact in both old moment and new moment.
            print('Contact ${contact.name} in both old moment and new moment');
            contact.totalTimeTogether = contact.totalTimeTogether -
                oldMoment.durationInMillis() +
                newMoment.durationInMillis();
            await contactRepository.save(contact);
          } else {
            // Contact newly added to new moment.
            print('Contact ${contact.name} newly added to new moment');
            contact.totalTimeTogether += newMoment.durationInMillis();
            await contactRepository.save(contact);
            var momentContact = MomentContact();
            momentContact.momentId = newMoment.id;
            momentContact.contactId = contact.id;
            momentContact.momentBeginTime = newMoment.beginTime;
            momentContact.createTime = now;
            await momentRepository.saveMomentContact(momentContact);
          }
        }
        for (Contact contact in oldMoment.contacts) {
          if (!newMoment.contacts.contains(contact)) {
            // Contacts removed from old moment.
            print('Contact ${contact.name} removed from old moment');
            contact.totalTimeTogether -= oldMoment.durationInMillis();
            await momentRepository.deleteMomentContact(
                oldMoment.id, contact.id);
            contact.lastMeetTime = await momentRepository
                .getContactLastMeetTime(contact.id, oldMoment.id);
            await contactRepository.save(contact);
          }
        }
        yield MomentUpdated();
      } catch (e) {
        yield MomentEditFailed(
            error:
                'Update moment ${oldMoment.action.name} failed: ${e.toString()}');
      }
    }
    if (event is DeleteMoment) {
      Moment moment = event.moment;
      try {
        // Update action.
        moment.action.lastActiveTime = await momentRepository
            .getActionLastActiveTime(moment.action.id, moment.id);
        moment.action.totalTimeTaken -= moment.durationInMillis();
        await actionRepository.save(moment.action);
        // Update location.
        moment.location.lastVisitTime = await momentRepository
            .getLocationLastVisitTime(moment.location.id, moment.id);
        moment.location.totalTimeStay -= moment.durationInMillis();
        await locationRepository.save(moment.location);
        // Update contacts.
        for (Contact contact in moment.contacts) {
          contact.lastMeetTime = await momentRepository.getContactLastMeetTime(
              contact.id, moment.id);
          contact.totalTimeTogether -= moment.durationInMillis();
          await momentRepository.deleteMomentContactViaMomentId(moment.id);
          await contactRepository.save(contact);
        }
        // Finally delete moment.
        await momentRepository.delete(moment);
        yield MomentDeleted(moment: moment);
      } catch (e) {
        yield MomentEditFailed(
            error:
                'Delete moment ${moment.action.name} failed: ${e.toString()}');
      }
    }
  }

  Future<void> _updateMomentActionInfo(Moment moment, int now) async {
    Action action = moment.action;
    if (action.id == null) {
      Action dbAction = await actionRepository.getViaName(action.name);
      if (dbAction != null) {
        action.copy(dbAction);
      }
    }
    if (action.id == null) {
      action.createTime = now;
      action.lastActiveTime = moment.beginTime;
    } else {
      action.updateTime = now;
      if (action.lastActiveTime == null) {
        action.lastActiveTime = moment.beginTime;
      } else {
        if (action.lastActiveTime < moment.beginTime) {
          action.lastActiveTime = moment.beginTime;
        }
      }
    }
  }

  Future<void> _updateMomentLocationInfo(Moment moment, int now) async {
    Location location = moment.location;
    if (location.id == null) {
      Location dbLocation = await locationRepository
          .getViaName(location.name);
      if (dbLocation != null) {
        location.copy(dbLocation);
      }
    }
    if (location.id == null) {
      location.createTime = now;
      location.lastVisitTime = moment.beginTime;
    } else {
      location.updateTime = now;
      if (location.lastVisitTime == null) {
        location.lastVisitTime = moment.beginTime;
      } else {
        if (location.lastVisitTime < moment.beginTime) {
          location.lastVisitTime = moment.beginTime;
        }
      }
    }
  }

  Future<void> _updateMomentContactInfo(Moment moment, int now) async {
    for (Contact contact in moment.contacts) {
      Contact dbContact;
      if (contact.id == null) {
        dbContact = await contactRepository.getViaName(contact.name);
        if (dbContact != null) {
          contact.copy(dbContact);
        }
      }
      if (contact.id != null) {
        // Existed contact
        contact.updateTime = now;
        if (contact.lastMeetTime == null) {
          contact.lastMeetTime = moment.beginTime;
        } else {
          if (contact.lastMeetTime < moment.beginTime) {
            contact.lastMeetTime = moment.beginTime;
          }
        }
      } else {
        // New contact
        contact.createTime = now;
        contact.lastMeetTime = moment.beginTime;
        contact.firstMeetTime = moment.beginTime;
        contact.firstKnowTime = moment.beginTime;
        // TODO: Change firstMeetLocation type from String to Location.
        contact.firstMeetLocation = moment.location.address;
      }
    }
  }

  Future<List<Contact>> getContactSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return contactRepository.get(startIndex: 0, count: 8);
    } else {
      return contactRepository.search(pattern, 8);
    }
  }
  Future<List<Action>> getActionSuggestions(String pattern) async {
    if (pattern.isEmpty) {
      return actionRepository.get(startIndex: 0, count: 8);
    } else {
      return actionRepository.search(pattern);
    }
  }


}
