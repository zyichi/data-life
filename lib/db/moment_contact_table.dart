import 'package:data_life/models/moment_contact.dart';


class MomentContactTable {
  static const name = 'moment_contact';

  static const columnId = '_id';
  static const columnMomentId = 'momentId';
  static const columnContactId = 'contactId';
  // This field is add for easy fetch Contact.lastMeetTime;
  static const columnMomentBeginTime = 'momentBeginTime';
  static const columnCreateTime = 'createTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnMomentId integer not null,
  $columnContactId integer not null,
  $columnMomentBeginTime integer not null,
  $columnCreateTime integer not null)
''';

  static const createIndexSql = '''
create unique index moment_contact_idx on $name(
  $columnMomentId, $columnContactId);
''';

  static List<String> get initSqlList => [createSql, createIndexSql];

  static MomentContact fromMap(Map map) {
    final momentContact = MomentContact();
    momentContact.id = map[MomentContactTable.columnId] as int;
    momentContact.momentId = map[MomentContactTable.columnMomentId] as int;
    momentContact.contactId = map[MomentContactTable.columnContactId] as int;
    momentContact.momentBeginTime = map[MomentContactTable.columnMomentBeginTime] as int;
    momentContact.createTime = map[MomentContactTable.columnCreateTime] as int;
    return momentContact;
  }

  static Map<String, dynamic> toMap(MomentContact momentContact) {
    var map = <String, dynamic>{
      MomentContactTable.columnMomentId: momentContact.momentId,
      MomentContactTable.columnContactId: momentContact.contactId,
      MomentContactTable.columnMomentBeginTime: momentContact.momentBeginTime,
      MomentContactTable.columnCreateTime: momentContact.createTime,
    };
    if (momentContact.id != null) {
      map[MomentContactTable.columnId] = momentContact.id;
    }
    return map;
  }

}
