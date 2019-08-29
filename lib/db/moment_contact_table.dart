import 'package:data_life/models/moment_contact.dart';


class MomentContactTable {
  static const name = 'moment_contact';

  static const columnMomentUuid = 'momentUuid';
  static const columnContactId = 'contactId';
  // This field is add for easy fetch Contact.lastMeetTime;
  static const columnMomentBeginTime = 'momentBeginTime';
  static const columnMomentDuration = 'momentDuration';
  static const columnCreateTime = 'createTime';

  static const createSql = '''
create table $name (
  $columnMomentUuid text not null,
  $columnContactId integer not null,
  $columnMomentBeginTime integer not null,
  $columnMomentDuration integer not null,
  $columnCreateTime integer not null,
  primary key ($columnMomentUuid, $columnContactId)
  )
''';

  static List<String> get initSqlList => [createSql, ];

  static MomentContact fromMap(Map map) {
    final momentContact = MomentContact();
    momentContact.momentUuid = map[MomentContactTable.columnMomentUuid];
    momentContact.contactId = map[MomentContactTable.columnContactId] as int;
    momentContact.momentBeginTime = map[MomentContactTable.columnMomentBeginTime] as int;
    momentContact.momentDuration = map[MomentContactTable.columnMomentDuration] as int;
    momentContact.createTime = map[MomentContactTable.columnCreateTime] as int;
    return momentContact;
  }

  static Map<String, dynamic> toMap(MomentContact momentContact) {
    var map = <String, dynamic>{
      MomentContactTable.columnMomentUuid: momentContact.momentUuid,
      MomentContactTable.columnContactId: momentContact.contactId,
      MomentContactTable.columnMomentBeginTime: momentContact.momentBeginTime,
      MomentContactTable.columnMomentDuration: momentContact.momentDuration,
      MomentContactTable.columnCreateTime: momentContact.createTime,
    };
    return map;
  }

}
