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

  static bool _isSameContacts(List<Contact> lhs, List<Contact> rhs) {
    if (lhs.length != rhs.length) {
      return false;
    }
    for (int i = 0; i < lhs.length; ++i) {
      if (lhs[i].id != rhs[i].id) {
        return false;
      }
    }
    return true;
  }

  static bool isSameMoment(Moment lhs, Moment rhs) {
    if (Action.isSameAction(lhs.action, rhs.action) &&
        Location.isSameLocation(lhs.location, rhs.location) &&
        lhs.sentiment == rhs.sentiment &&
        lhs.beginTime == rhs.beginTime &&
        lhs.endTime == rhs.endTime &&
        lhs.cost == rhs.cost &&
        lhs.details == rhs.details &&
        _isSameContacts(lhs.contacts, rhs.contacts)) {
      return true;
    }
    return false;
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
