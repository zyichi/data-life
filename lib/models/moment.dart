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

  Action _action;
  Location _location;
  List<Contact> contacts = <Contact>[];

  Action get action => _action;
  set action(Action a) {
    _action = a;
    actionId = a?.id;
  }
  Location get location => _location;
  set location(Location l) {
    _location = l;
    locationId = l?.id;
  }

  bool _isContentSameContactList(List<Contact> lhs, List<Contact> rhs) {
    if (lhs.length != rhs.length) return false;
    for (Contact l in lhs) {
      bool founded = false;
      for (Contact r in rhs) {
        if (l.isContentSameWith(r)) {
          founded = true;
          break;
        }
      }
      if (!founded) return false;
    }
    return true;
  }
  
  bool _isSameContactList(List<Contact> lhs, List<Contact> rhs) {
    if (lhs.length != rhs.length) return false;
    for (Contact l in lhs) {
      bool founded = false;
      for (Contact r in rhs) {
        if (l.isSameWith(r)) {
          founded = true;
          break;
        }
      }
      if (!founded) return false;
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
    if ((details ?? '') != (moment.details ?? '')) return false;
    if (createTime != moment.createTime) return false;
    if (updateTime != moment.updateTime) return false;
    if (!action.isContentSameWith(moment.action)) return false;
    if (!location.isContentSameWith(moment.location)) return false;
    if (!_isContentSameContactList(contacts, moment.contacts)) return false;
    return true;
  }

  int durationInHours() {
    return Duration(milliseconds: (endTime - beginTime)).inHours;
  }

  int durationInMinutes() {
    return Duration(milliseconds: (endTime - beginTime)).inMinutes;
  }

  int durationInSeconds() {
    return Duration(milliseconds: (endTime - beginTime)).inSeconds;
  }

  int durationInMillis() {
    return endTime - beginTime;
  }

  void copy(Moment moment) {
    id = moment.id;
    actionId = moment.actionId;
    locationId = moment.locationId;
    sentiment = moment.sentiment;
    beginTime = moment.beginTime;
    endTime = moment.endTime;
    cost = moment.cost;
    details = moment.details;
    createTime = moment.createTime;
    updateTime = moment.updateTime;
    action = moment.action;
    location = moment.location;
    contacts = moment.contacts;
  }
}
