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
      List<MomentContact> momentContacts = await getMomentContact(moment.uuid);
      for (MomentContact momentContact in momentContacts) {
        var contact = await _contactProvider.getViaId(momentContact.contactId);
        if (contact != null) {
          moment.contacts.add(contact);
        }
      }
    }
    return moments;
  }

  Future<List<Moment>> getAll() async {
    List<Map> maps = await LifeDb.db.query(
      MomentTable.name,
      columns: [],
    );
    var moments = maps.map((map) {
      return MomentTable.fromMap(map);
    }).toList();
    for (Moment moment in moments) {
      moment.action = await _actionProvider.getViaId(moment.actionId);
      moment.location = await _locationProvider.getViaId(moment.locationId);
      List<MomentContact> momentContacts = await getMomentContact(moment.uuid);
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
        List<MomentContact> momentContacts = await getMomentContact(moment.uuid);
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
    return LifeDb.db.update(MomentTable.name, MomentTable.toMap(moment),
        where: "${MomentTable.columnUuid} = ?", whereArgs: [moment.uuid]);
  }

  Future<int> delete(Moment moment) async {
    return LifeDb.db.delete(
      MomentTable.name,
      where: "${MomentTable.columnUuid} = ?",
      whereArgs: [moment.uuid],
    );
  }

  Future<List<MomentContact>> getMomentContact(String momentUuid) async {
    List<Map> maps = await LifeDb.db.query(
      MomentContactTable.name,
      columns: [],
      where: "${MomentContactTable.columnMomentUuid} = ?",
      whereArgs: [momentUuid],
    );
    return maps.map((map) {
      return MomentContactTable.fromMap(map);
    }).toList();
  }

  Future<int> insertMomentContact(MomentContact momentContact) async {
    return LifeDb.db.insert(
        MomentContactTable.name, MomentContactTable.toMap(momentContact));
  }

  Future<int> deleteMomentContactViaMomentUuid(String momentUuid) async {
    return LifeDb.db.delete(MomentContactTable.name,
        where: "${MomentContactTable.columnMomentUuid} = ?",
        whereArgs: [momentUuid]);
  }

  Future<int> deleteMomentContact(int momentId, int contactId) async {
    return LifeDb.db.delete(MomentContactTable.name,
        where:
            "${MomentContactTable.columnMomentUuid} = ? and ${MomentContactTable.columnContactId} = ?",
        whereArgs: [momentId, contactId]);
  }

  Future<int> addMomentContact(MomentContact momentContact) async {
    return await insertMomentContact(momentContact);
  }

  Future<int> getLocationLastVisitTime(
      int locationId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${MomentTable.columnBeginTime}) from ${MomentTable.name} where ${MomentTable.columnLocationId} = $locationId'));
    return t ?? 0;
  }

  Future<int> getLocationTotalTimeStay(
      int locationId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${MomentTable.columnDuration}) from ${MomentTable.name} where ${MomentTable.columnLocationId} = $locationId'));
    return t ?? 0;
  }

  Future<int> getActionLastActiveTime(int actionId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${MomentTable.columnBeginTime}) from ${MomentTable.name} where ${MomentTable.columnActionId} = $actionId'));
    return t ?? 0;
  }

  Future<int> getContactLastMeetTime(int contactId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${MomentContactTable.columnMomentBeginTime}) from ${MomentContactTable.name} where ${MomentContactTable.columnContactId} = $contactId'));
    return t ?? 0;
  }

  Future<int> getContactTotalTimeTogether(int contactId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${MomentContactTable.columnMomentDuration}) from ${MomentContactTable.name} where ${MomentContactTable.columnContactId} = $contactId'));
    return t ?? 0;
  }

  Future<int> getActionLastActiveTimeBetweenTime(
      int actionId, int startTime, int stopTime) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select max(${MomentTable.columnBeginTime}) from ${MomentTable.name} where ${MomentTable.columnActionId} = $actionId and ${MomentTable.columnBeginTime} >= $startTime and ${MomentTable.columnBeginTime} < $stopTime'));
    return t ?? 0;
  }

  Future<int> getActionTotalTimeTakenBetweenTime(
      int actionId, int startTime, int stopTime) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${MomentTable.columnDuration}) from ${MomentTable.name} where ${MomentTable.columnActionId} = $actionId and ${MomentTable.columnBeginTime} >= $startTime and ${MomentTable.columnBeginTime} < $stopTime'));
    return t ?? 0;
  }

  Future<int> getActionTotalTimeTaken(int actionId) async {
    int t = Sqflite.firstIntValue(await LifeDb.db.rawQuery(
        'select sum(${MomentTable.columnDuration}) from ${MomentTable.name} where ${MomentTable.columnActionId} = $actionId'));
    return t ?? 0;
  }

}
