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

  Future<int> save(Moment moment) async {
    return _momentProvider.save(moment);
  }

  Future<int> delete(Moment moment) async {
    return _momentProvider.delete(moment);
  }

  Future<int> saveMomentContact(MomentContact momentContact) async {
    return _momentProvider.saveMomentContact(momentContact);
  }

  Future<int> deleteMomentContactViaMomentId(int momentId) async {
    return _momentProvider.deleteMomentContactViaMomentId(momentId);
  }

  Future<int> deleteMomentContact(int momentId, int contactId) async {
    return _momentProvider.deleteMomentContact(momentId, contactId);
  }

  Future<int> getLocationLastVisitTime(int locationId, int excludeMomentId) async {
    return _momentProvider.getLocationLastVisitTime(locationId, excludeMomentId);
  }

  Future<int> getActionLastActiveTime(int actionId, int excludeMomentId) async {
    return _momentProvider.getActionLastActiveTime(actionId, excludeMomentId);
  }

  Future<int> getContactLastMeetTime(int contactId, int excludeMomentId) async {
    return _momentProvider.getContactLastMeetTime(contactId, excludeMomentId);
  }

}
