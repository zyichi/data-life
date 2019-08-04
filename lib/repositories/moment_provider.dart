import 'package:sqflite/sqflite.dart';

import 'package:data_life/models/moment.dart';
import 'package:data_life/models/moment_contact.dart';
import 'package:data_life/db/life_db.dart';
import 'package:data_life/db/moment_table.dart';
import 'package:data_life/db/moment_contact_table.dart';
import 'package:data_life/repositories/action_provider.dart';
import 'package:data_life/repositories/contact_provider.dart';
import 'package:data_life/repositories/location_provider.dart';

class MomentProvider {
  final ActionProvider _actionProvider = ActionProvider();
  final ContactProvider _contactProvider = ContactProvider();
  final LocationProvider _locationProvider = LocationProvider();

  Future<int> count() async {
    return Sqflite.firstIntValue(
        await LifeDb.db.rawQuery('select count(*) from ${MomentTable.name}'));
  }

  Future<List<Moment>> get({int startIndex, int count}) async {
    List<Map> maps = await LifeDb.db.query(
      MomentTable.name,
      columns: [],
      orderBy: '${MomentTable.columnBeginTime} desc',
      limit: count,
      offset: startIndex,
    );
    var moments = maps.map((map) {
      return MomentTable.fromMap(map);
    }).toList();
    for (Moment moment in moments) {
      moment.action = await _actionProvider.getViaId(moment.actionId);
      moment.location = await _locationProvider.getViaId(moment.locationId);
      List<MomentContact> momentContacts = await getMomentContact(moment.id);
      for (MomentContact momentContact in momentContacts) {
        var contact = await _contactProvider.getViaId(momentContact.contactId);
        if (contact != null) {
          moment.contacts.add(contact);
        }
      }
    }
    return moments;
  }

  Future<List<Moment>> getAfterTime(int timeInMillis, bool rowOnly) async {
    List<Map> maps = await LifeDb.db.query(
      MomentTable.name,
      columns: [],
      where: "${MomentTable.columnBeginTime} >= ?",
      whereArgs: [timeInMillis],
    );
    var moments = maps.map((map) {
      return MomentTable.fromMap(map);
    }).toList();
    if (!rowOnly) {
      for (Moment moment in moments) {
        moment.action = await _actionProvider.getViaId(moment.actionId);
        moment.location = await _locationProvider.getViaId(moment.locationId);
        List<MomentContact> momentContacts = await getMomentContact(moment.id);
        for (MomentContact momentContact in momentContacts) {
          var contact = await _contactProvider.getViaId(
              momentContact.contactId);
          if (contact != null) {
            moment.contacts.add(contact);
          }
        }
      }
    }
    return moments;
  }

  Future<int> insert(Moment moment) async {
    return LifeDb.db.insert(MomentTable.name, MomentTable.toMap(moment));
  }

  Future<int> update(Moment moment) async {
    assert(moment.id != null);
    return LifeDb.db.update(MomentTable.name, MomentTable.toMap(moment),
        where: "${MomentTable.columnId} = ?", whereArgs: [moment.id]);
  }

  Future<int> save(Moment moment) async {
    int affected = 0;
    if (moment.id == null) {
      moment.id = await insert(moment);
      affected = 1;
    } else {
      affected = await update(moment);
    }
    return affected;
  }

  Future<int> delete(Moment moment) async {
    return LifeDb.db.delete(
      MomentTable.name,
      where: "${MomentTable.columnId} = ?",
      whereArgs: [moment.id],
    );
  }

  Future<List<MomentContact>> getMomentContact(int momentId) async {
    List<Map> maps = await LifeDb.db.query(
      MomentContactTable.name,
      columns: [],
      where: "${MomentContactTable.columnMomentId} = ?",
      whereArgs: [momentId],
    );
    return maps.map((map) {
      return MomentContactTable.fromMap(map);
    }).toList();
  }

  Future<int> insertMomentContact(MomentContact momentContact) async {
    return LifeDb.db.insert(
        MomentContactTable.name, MomentContactTable.toMap(momentContact));
  }

  Future<int> deleteMomentContactViaMomentId(int momentId) async {
    return LifeDb.db.delete(MomentContactTable.name,
        where: "${MomentContactTable.columnMomentId} = ?",
        whereArgs: [momentId]);
  }

  Future<int> deleteMomentContact(int momentId, int contactId) async {
    return LifeDb.db.delete(MomentContactTable.name,
        where:
            "${MomentContactTable.columnMomentId} = ? and ${MomentContactTable.columnContactId} = ?",
        whereArgs: [momentId, contactId]);
  }

  Future<int> saveMomentContact(MomentContact momentContact) async {
    momentContact.id = await insertMomentContact(momentContact);
    return 1;
  }

  Future<int> getLocationLastVisitTime(
      int locationId, int excludeMomentId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${MomentTable.columnBeginTime}) from ${MomentTable.name} where ${MomentTable.columnLocationId} = $locationId and ${MomentTable.columnId} != $excludeMomentId'));
    return t ?? 0;
  }

  Future<int> getActionLastActiveTime(int actionId, int excludeMomentId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${MomentTable.columnBeginTime}) from ${MomentTable.name} where ${MomentTable.columnActionId} = $actionId and ${MomentTable.columnId} != $excludeMomentId'));
    return t ?? 0;
  }

  Future<int> getContactLastMeetTime(int contactId, int excludeMomentId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${MomentContactTable.columnMomentBeginTime}) from ${MomentContactTable.name} where ${MomentContactTable.columnContactId} = $contactId and ${MomentContactTable.columnMomentId} != $excludeMomentId'));
    return t ?? 0;
  }
}
