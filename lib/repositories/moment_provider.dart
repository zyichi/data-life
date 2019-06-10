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
    for (int i = 0; i < moments.length; i++) {
      var moment = moments[i];
      moment.action = await _actionProvider.getViaId(moment.actionId);
      moment.actionId = moment.action?.id;
      moment.location = await _locationProvider.getViaId(moment.locationId);
      moment.locationId = moment.location?.id;
      List<MomentContact> momentContacts = await getMomentContact(moment.id);
      for (int j = 0; j < momentContacts.length; j++) {
        var contact = await _contactProvider.getViaId(momentContacts[j].contactId);
        if (contact != null) {
          moment.contacts.add(contact);
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
    return LifeDb.db.delete(
      MomentContactTable.name,
      where: "${MomentContactTable.columnMomentId} = ?",
      whereArgs: [momentId]
    );
  }

  Future<int> deleteMomentContact(int momentId, int contactId) async {
    return LifeDb.db.delete(
      MomentContactTable.name,
      where: "${MomentContactTable.columnMomentId} = ? and ${MomentContactTable.columnContactId} = ?",
      whereArgs: [momentId, contactId]
    );
  }

  Future<int> saveMomentContact(MomentContact momentContact) async {
    momentContact.id = await insertMomentContact(momentContact);
    return 1;
  }

  Future<int> getLocationLastVisitTime(int locationId, int momentId) async {
    List<Map> maps = await LifeDb.db.query(
      MomentTable.name,
      columns: [],
      where: "${MomentTable.columnLocationId} = ? and ${MomentTable.columnId} != ?",
      whereArgs: [locationId, momentId],
      orderBy: '${MomentTable.columnBeginTime} desc',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      Moment moment = MomentTable.fromMap(maps[0]);
      return moment.beginTime;
    }
    return null;
  }

  Future<int> getActionLastActiveTime(int actionId, int momentId) async {
    List<Map> maps = await LifeDb.db.query(
      MomentTable.name,
      columns: [],
      where: "${MomentTable.columnActionId} = ? and ${MomentTable.columnId} != ?",
      whereArgs: [actionId, momentId],
      orderBy: '${MomentTable.columnBeginTime} desc',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      Moment moment = MomentTable.fromMap(maps[0]);
      return moment.beginTime;
    }
    return null;
  }

  Future<int> getContactLastMeetTime(int contactId, int momentId) async {
    List<Map> maps = await LifeDb.db.query(
      MomentContactTable.name,
      columns: [],
      where: "${MomentContactTable.columnContactId} = ? and ${MomentContactTable.columnMomentId} != ?",
      whereArgs: [contactId, momentId],
      orderBy: '${MomentContactTable.columnMomentBeginTime} desc',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      MomentContact momentContact = MomentContactTable.fromMap(maps[0]);
      return momentContact.momentBeginTime;
    }
    return null;
  }

}
