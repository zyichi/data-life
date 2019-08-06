import 'package:data_life/models/contact.dart';


class ContactTable {
  static const name = 'contact';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnNickname = 'nickname';
  static const columnKnowVia = 'knowVia';
  static const columnFirstKnowTime = 'firstKnowTime';
  static const columnFirstMeetTime = 'firstMeetTime';
  static const columnFirstMeetLocation = 'firstMeetLocation';
  static const columnTotalTimeTogether = 'totalTimeTogether';
  static const columnLastMeetTime = 'lastMeetTime';
  static const columnWeChatId = 'weChatId';
  static const columnPhoneNumber = 'phoneNumber';
  static const columnQqId = 'qqId';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnName text not null,
  $columnNickname text default null,
  $columnKnowVia text default null,
  $columnFirstKnowTime integer default 0,
  $columnFirstMeetTime integer default 0,
  $columnFirstMeetLocation integer default null,
  $columnTotalTimeTogether integer default 0,
  $columnLastMeetTime integer default 0,
  $columnWeChatId text default null,
  $columnPhoneNumber text default null,
  $columnQqId text default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static const createIndexSql = '''
create unique index contact_name_idx on $name(
  $columnName);
''';

  static List<String> get initSqlList => [createSql, createIndexSql];

  static Contact fromMap(Map map) {
    final contact = Contact();
    contact.id = map[ContactTable.columnId] as int;
    contact.name = map[ContactTable.columnName] as String;
    contact.nickname = map[ContactTable.columnNickname] as String;
    contact.knowVia = map[ContactTable.columnKnowVia] as String;
    contact.firstKnowTime = map[ContactTable.columnFirstKnowTime] as int;
    contact.firstMeetTime = map[ContactTable.columnFirstMeetTime] as int;
    contact.firstMeetLocation = map[ContactTable.columnFirstMeetLocation] as int;
    contact.totalTimeTogether = map[ContactTable.columnTotalTimeTogether] as int;
    contact.lastMeetTime = map[ContactTable.columnLastMeetTime] as int;
    contact.weChatId = map[ContactTable.columnWeChatId] as String;
    contact.phoneNumber = map[ContactTable.columnPhoneNumber] as String;
    contact.qqId = map[ContactTable.columnQqId] as String;
    contact.createTime = map[ContactTable.columnCreateTime] as int;
    contact.updateTime = map[ContactTable.columnUpdateTime] as int;
    return contact;
  }

  static Map<String, dynamic> toMap(Contact contact) {
    var map = <String, dynamic>{
      ContactTable.columnName: contact.name,
      ContactTable.columnNickname: contact.nickname,
      ContactTable.columnKnowVia: contact.knowVia,
      ContactTable.columnFirstKnowTime: contact.firstKnowTime,
      ContactTable.columnFirstMeetTime: contact.firstMeetTime,
      ContactTable.columnFirstMeetLocation: contact.firstMeetLocation,
      ContactTable.columnTotalTimeTogether: contact.totalTimeTogether,
      ContactTable.columnLastMeetTime: contact.lastMeetTime,
      ContactTable.columnWeChatId: contact.weChatId,
      ContactTable.columnPhoneNumber: contact.phoneNumber,
      ContactTable.columnQqId: contact.qqId,
      ContactTable.columnCreateTime: contact.createTime,
      ContactTable.columnUpdateTime: contact.updateTime,
    };
    if (contact.id != null) {
      map[ContactTable.columnId] = contact.id;
    }
    return map;
  }

}
