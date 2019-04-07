import 'package:data_life/life_db.dart';


enum Sentiment {
  VerySatisfied, Satisfied, Neutral, Dissatisfied, VeryDissatisfied
}


class Event {
  Event();

  int id;
  int activityId;
  String location;
  String people;
  Sentiment sentiment;
  int beginTime;
  int endTime;
  num cost;
  String details;
  int createTime;
  int updateTime;

  Event.fromMap(Map map) {
    id = map[EventTable.columnId] as int;
    activityId = map[EventTable.columnActivityId] as int;
    location = map[EventTable.columnLocation] as String;
    people = map[EventTable.columnPeople] as String;
    sentiment = Sentiment.values[map[EventTable.columnSentiment]];
    beginTime = map[EventTable.columnBeginTime] as int;
    endTime = map[EventTable.columnEndTime] as int;
    cost = map[EventTable.columnCost] as num;
    details= map[EventTable.columnDetails] as String;
    createTime = map[EventTable.columnCreateTime] as int;
    updateTime = map[EventTable.columnUpdateTime] as int;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      EventTable.columnActivityId: activityId,
      EventTable.columnLocation: location,
      EventTable.columnPeople: people,
      EventTable.columnSentiment: sentiment.index,
      EventTable.columnBeginTime: beginTime,
      EventTable.columnEndTime: endTime,
      EventTable.columnCost: cost,
      EventTable.columnDetails: details,
      EventTable.columnCreateTime: createTime,
      EventTable.columnUpdateTime: updateTime,
    };
    if (id != null) {
      map[EventTable.columnId] = id;
    }
    return map;
  }
}
