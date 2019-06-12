import 'package:data_life/models/contact.dart';
import 'package:data_life/models/action.dart';
import 'package:data_life/models/location.dart';

enum Sentiment {
  VerySatisfied,
  Satisfied,
  Neutral,
  Dissatisfied,
  VeryDissatisfied
}

class Moment {
  Moment();

  int id;
  int actionId;
  int locationId;
  Sentiment sentiment;
  int beginTime;
  int endTime;
  num cost;
  String details;
  int createTime;
  int updateTime;

  List<Contact> contacts = <Contact>[];
  Action action;
  Location location;

  bool _isContentSameContactList(List<Contact> lhs, List<Contact> rhs) {
    if (lhs.length != rhs.length) return false;
    for (Contact l in lhs) {
      for (Contact r in rhs) {
        if (!l.isContentSameWith(r)) return false;
      }
    }
    return true;
  }
  
  bool _isSameContactList(List<Contact> lhs, List<Contact> rhs) {
    if (lhs.length != rhs.length) return false;
    for (Contact l in lhs) {
      for (Contact r in rhs) {
        if (!l.isSameWith(r)) return false;
      }
    }
    return true;
  }
  
  bool isSameWith(Moment moment) {
    if (id != moment.id) return false;
    if (actionId != moment.actionId) return false;
    if (locationId != moment.locationId) return false;
    if (!isContentSameWith(moment)) return false;
    if (!_isSameContactList(contacts, moment.contacts)) return false;
    return true;
  }

  bool isContentSameWith(Moment moment) {
    if (sentiment != moment.sentiment) return false;
    if (beginTime != moment.beginTime) return false;
    if (endTime != moment.endTime) return false;
    if (cost != moment.cost) return false;
    if (details != moment.details) return false;
    if (createTime != moment.createTime) return false;
    if (updateTime != moment.updateTime) return false;
    if (!action.isContentSameWith(moment.action)) return false;
    if (!location.isContentSameWith(moment.location)) return false;
    if (!_isContentSameContactList(contacts, moment.contacts)) return false;
    return true;
  }

  int durationInHours() {
    return (endTime - beginTime) ~/ 3600000;
  }

  int durationInMinutes() {
    return (endTime - beginTime) ~/ 60000;
  }

  int durationInSeconds() {
    return (endTime - beginTime) ~/ 1000;
  }

  int durationInMillis() {
    return endTime - beginTime;
  }

}
