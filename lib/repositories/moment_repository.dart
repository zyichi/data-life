import 'package:data_life/paging/page_repository.dart';
import 'package:data_life/models/moment.dart';
import 'package:data_life/models/moment_contact.dart';

import 'package:data_life/repositories/moment_provider.dart';

class MomentRepository extends PageRepository<Moment> {
  final MomentProvider _momentProvider;

  MomentRepository(this._momentProvider);

  @override
  Future<int> count() async {
    return _momentProvider.count();
  }

  @override
  Future<List<Moment>> get({int startIndex, int count}) async {
    return _momentProvider.get(startIndex: startIndex, count: count);
  }

  Future<List<Moment>> getAfterTime(int timeInMillis, bool rowOnly) async {
    return _momentProvider.getAfterTime(timeInMillis, rowOnly);
  }

  Future<int> save(Moment moment) async {
    return _momentProvider.save(moment);
  }

  Future<int> delete(Moment moment) async {
    return _momentProvider.delete(moment);
  }

  Future<int> saveMomentContact(MomentContact momentContact) async {
    return _momentProvider.saveMomentContact(momentContact);
  }

  Future<int> deleteMomentContactViaMomentId(String momentUuid) async {
    return _momentProvider.deleteMomentContactViaMomentId(momentUuid);
  }

  Future<int> deleteMomentContact(int momentId, int contactId) async {
    return _momentProvider.deleteMomentContact(momentId, contactId);
  }

  Future<int> getLocationLastVisitTime(int locationId) async {
    return _momentProvider.getLocationLastVisitTime(locationId);
  }

  Future<int> getLocationTotalTimeStay(int locationId) async {
    return _momentProvider.getLocationTotalTimeStay(locationId);
  }

  Future<int> getActionLastActiveTime(int actionId) async {
    return _momentProvider.getActionLastActiveTime(actionId);
  }

  Future<int> getContactLastMeetTime(int contactId) async {
    return _momentProvider.getContactLastMeetTime(contactId);
  }

  Future<int> getContactTotalTimeTogether(int contactId) async {
    return _momentProvider.getContactTotalTimeTogether(contactId);
  }

  Future<int> getActionLastActiveTimeBetweenTime(
      int actionId, int startTime, int stopTime) async {
    return _momentProvider.getActionLastActiveTimeBetweenTime(
        actionId, startTime, stopTime);
  }

  Future<int> getActionTotalTimeTakenBetweenTime(
      int actionId, int startTime, int stopTime) async {
    return _momentProvider.getActionTotalTimeTakenBetweenTime(
        actionId, startTime, stopTime);
  }

  Future<int> getActionTotalTimeTaken(int actionId) async {
    return _momentProvider.getActionTotalTimeTaken(actionId);
  }
}
