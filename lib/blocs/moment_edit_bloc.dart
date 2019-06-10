import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/moment.dart';

import 'package:data_life/repositories/moment_provider.dart';
import 'package:data_life/repositories/moment_repository.dart';


abstract class MomentEditEvent {}

abstract class MomentEditState {}

class AddMoment extends MomentEditEvent {
  final Moment moment;

  AddMoment({@required this.moment}) : assert(moment != null);
}

class DeleteMoment extends MomentEditEvent {
  final Moment moment;

  DeleteMoment({@required this.moment}) : assert(moment != null);
}

class UpdateMoment extends MomentEditEvent {
  final Moment moment;
  final Moment newMoment;

  UpdateMoment({@required this.moment, @required this.newMoment})
      : assert(moment != null),
        assert(newMoment != null);
}


class MomentAdded extends MomentEditState {}
class MomentDeleted extends MomentEditState {}
class MomentUpdated extends MomentEditState {}


class MomentEditBloc extends Bloc<MomentEditEvent, MomentEditState> {
  MomentRepository _momentRepository;

  MomentEditBloc() {
    _momentRepository = MomentRepository(MomentProvider());
  }

  @override
  MomentEditState get initialState => null;

  @override
  Stream<MomentEditState> mapEventToState(MomentEditEvent event) async* {
    if (event is AddMoment) {
      _momentRepository.save(event.moment);
    }
  }

}
