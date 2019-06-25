import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/location.dart';
import 'package:data_life/models/contact.dart';

import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/repositories/contact_repository.dart';

abstract class ContactEditEvent {}

abstract class ContactEditState {}

class UpdateContact extends ContactEditEvent {
  final Contact oldContact;
  final Contact newContact;

  UpdateContact({@required this.oldContact, @required this.newContact})
      : assert(oldContact != null),
        assert(newContact != null);
}

class ContactNameUniqueCheck extends ContactEditEvent {
  final String name;

  ContactNameUniqueCheck({this.name})
      : assert(name != null);
}

class ContactUninitialized extends ContactEditState {}

class ContactUpdated extends ContactEditState {}

class ContactNameUniqueCheckResult extends ContactEditState {
  final bool isUnique;
  final String text;

  ContactNameUniqueCheckResult({this.isUnique, this.text})
      : assert(isUnique != null),
        assert(text != null);
}

class ContactEditFailed extends ContactEditState {
  final String error;

  ContactEditFailed({this.error}) : assert(error != null);
}

class ContactEditBloc extends Bloc<ContactEditEvent, ContactEditState> {
  final LocationRepository locationRepository;
  final ContactRepository contactRepository;

  ContactEditBloc(
      {@required this.locationRepository, @required this.contactRepository})
      : assert(contactRepository != null),
        assert(locationRepository != null);

  @override
  ContactEditState get initialState => ContactUninitialized();

  @override
  Stream<ContactEditState> mapEventToState(ContactEditEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is UpdateContact) {
      final oldContact = event.oldContact;
      final newContact = event.newContact;
      try {
        newContact.updateTime = now;
        contactRepository.save(newContact);
        yield ContactUpdated();
      } catch (e) {
        yield ContactEditFailed(
            error: 'Update contact ${oldContact.name} failed: ${e.toString()}');
      }
    }
    if (event is ContactNameUniqueCheck) {
      try {
        Contact contact = await contactRepository.getViaName(event.name);
        yield ContactNameUniqueCheckResult(isUnique: contact == null, text: event.name);
      } catch (e) {
        yield ContactEditFailed(
            error: 'Check if contact name unique failed: ${e.toString()}');
      }
    }
  }
}
