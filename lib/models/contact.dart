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
  String weChatId;
  String phoneNumber;
  String qqId;
  int createTime;
  int updateTime;

  @override
  List get props => [name];

  static Contact copyCreate(Contact contact) {
    var newContact = Contact();
    newContact.copy(contact);
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
    weChatId = contact.weChatId;
    phoneNumber = contact.phoneNumber;
    qqId = contact.qqId;
    createTime = contact.createTime;
    updateTime = contact.updateTime;
  }

  bool isSameWith(Contact contact) {
    if (id == contact.id && isContentSameWith(contact)) return true;
    return false;
  }
  bool isContentSameWith(Contact contact) {
    if ((name ?? '') != (contact.name ?? '')) return false;
    if ((nickname ?? '') != (contact.nickname ?? '')) return false;
    if ((knowVia ?? '') != (contact.knowVia ?? '')) return false;
    if (firstKnowTime != contact.firstKnowTime) return false;
    if (firstMeetTime != contact.firstMeetTime) return false;
    if ((firstMeetLocation ?? '') != (contact.firstMeetLocation ?? '')) return false;
    if (totalTimeTogether != contact.totalTimeTogether) return false;
    if (lastMeetTime != contact.lastMeetTime) return false;
    if ((weChatId ?? '') != (contact.weChatId ?? '')) return false;
    if ((phoneNumber ?? '') != (contact.phoneNumber ?? '')) return false;
    if ((qqId ?? '') != (contact.qqId ?? '')) return false;
    if (createTime != contact.createTime) return false;
    if (updateTime != contact.updateTime) return false;
    return true;
  }
}
