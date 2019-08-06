import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/contact.dart';

import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/repositories/contact_repository.dart';

abstract class ContactEvent {}

abstract class ContactState {}

class UpdateContact extends ContactEvent {
  final Contact oldContact;
  final Contact newContact;

  UpdateContact({@required this.oldContact, @required this.newContact})
      : assert(oldContact != null),
        assert(newContact != null);
}

class ContactNameUniqueCheck extends ContactEvent {
  final String name;

  ContactNameUniqueCheck({this.name})
      : assert(name != null);
}

class ContactUninitialized extends ContactState {}

class ContactUpdated extends ContactState {}

class ContactNameUniqueCheckResult extends ContactState {
  final bool isUnique;
  final String text;

  ContactNameUniqueCheckResult({this.isUnique, this.text})
      : assert(isUnique != null),
        assert(text != null);
}

class ContactFailed extends ContactState {
  final String error;

  ContactFailed({this.error}) : assert(error != null);
}

class ContactBloc extends Bloc<ContactEvent, ContactState> {
  final LocationRepository locationRepository;
  final ContactRepository contactRepository;

  ContactBloc(
      {@required this.locationRepository, @required this.contactRepository})
      : assert(contactRepository != null),
        assert(locationRepository != null);

  @override
  ContactState get initialState => ContactUninitialized();

  @override
  Stream<ContactState> mapEventToState(ContactEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is UpdateContact) {
      final oldContact = event.oldContact;
      final newContact = event.newContact;
      try {
        newContact.updateTime = now;
        contactRepository.save(newContact);
        yield ContactUpdated();
      } catch (e) {
        yield ContactFailed(
            error: 'Update contact ${oldContact.name} failed: ${e.toString()}');
      }
    }
    if (event is ContactNameUniqueCheck) {
      try {
        Contact contact = await contactRepository.getViaName(event.name);
        yield ContactNameUniqueCheckResult(isUnique: contact == null, text: event.name);
      } catch (e) {
        yield ContactFailed(
            error: 'Check if contact name unique failed: ${e.toString()}');
      }
    }
  }
}
