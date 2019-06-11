import 'package:equatable/equatable.dart';


class Contact extends Equatable {
  Contact();

  int id;
  String name;
  String nickname;
  String knowVia;
  int firstKnowTime;
  int firstMeetTime;
  String firstMeetLocation;
  int totalTimeTogether = 0;
  int lastMeetTime;
  int createTime;
  int updateTime;

  @override
  List get props => [name];

  static Contact copyCreate(Contact contact) {
    var newContact = Contact();
    newContact.id = contact.id;
    newContact.name = contact.name;
    newContact.nickname = contact.nickname;
    newContact.knowVia = contact.knowVia;
    newContact.firstKnowTime = contact.firstKnowTime;
    newContact.firstMeetTime = contact.firstMeetTime;
    newContact.firstMeetLocation = contact.firstMeetLocation;
    newContact.totalTimeTogether = contact.totalTimeTogether;
    newContact.lastMeetTime = contact.lastMeetTime;
    newContact.createTime = contact.createTime;
    newContact.updateTime = contact.updateTime;
    return newContact;
  }

  void copy(Contact contact) {
    id = contact.id;
    name = contact.name;
    nickname = contact.nickname;
    knowVia = contact.knowVia;
    firstKnowTime = contact.firstKnowTime;
    firstMeetTime = contact.firstMeetTime;
    firstMeetLocation = contact.firstMeetLocation;
    totalTimeTogether = contact.totalTimeTogether;
    lastMeetTime = contact.lastMeetTime;
    createTime = contact.createTime;
    updateTime = contact.updateTime;
  }
}
