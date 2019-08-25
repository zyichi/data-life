import 'package:data_life/models/moment.dart';


class MomentTable {
  static const name = 'moment';
  static const columnUuid = 'uuid';
  static const columnActionId = 'actionId';
  static const columnLocationId = 'locationId';
  static const columnSentiment = 'sentiment';
  static const columnBeginTime = 'beginTime';
  static const columnEndTime = 'endTime';
  static const columnDuration = 'duration';
  static const columnCost = 'cost';
  static const columnDetails = 'details';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnUuid text primary key,
  $columnActionId integer defalut null,
  $columnLocationId integer defalut null,
  $columnSentiment integer not null,
  $columnBeginTime integer not null,
  $columnEndTime integer not null,
  $columnDuration integer not null,
  $columnCost real default 0.0,
  $columnDetails text default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static List<String> get initSqlList => [createSql];

  static Moment fromMap(Map map) {
    final moment = Moment();
    moment.uuid = map[MomentTable.columnUuid];
    moment.actionId = map[MomentTable.columnActionId] as int;
    moment.locationId = map[MomentTable.columnLocationId] as int;
    moment.sentiment = Sentiment.values[map[MomentTable.columnSentiment]];
    moment.beginTime = map[MomentTable.columnBeginTime] as int;
    moment.endTime = map[MomentTable.columnEndTime] as int;
    moment.duration = map[MomentTable.columnDuration] as int;
    moment.cost = map[MomentTable.columnCost] as num;
    moment.details= map[MomentTable.columnDetails] as String;
    moment.createTime = map[MomentTable.columnCreateTime] as int;
    moment.updateTime = map[MomentTable.columnUpdateTime] as int;
    return moment;
  }

  static Map<String, dynamic> toMap(Moment moment) {
    var map = <String, dynamic>{
      MomentTable.columnUuid: moment.uuid,
      MomentTable.columnActionId: moment.actionId,
      MomentTable.columnLocationId: moment.locationId,
      MomentTable.columnSentiment: moment.sentiment.index,
      MomentTable.columnBeginTime: moment.beginTime,
      MomentTable.columnEndTime: moment.endTime,
      MomentTable.columnDuration: moment.duration,
      MomentTable.columnCost: moment.cost,
      MomentTable.columnDetails: moment.details,
      MomentTable.columnCreateTime: moment.createTime,
      MomentTable.columnUpdateTime: moment.updateTime,
    };
    return map;
  }

}
