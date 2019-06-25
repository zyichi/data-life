import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/location.dart';

import 'package:data_life/repositories/location_repository.dart';

abstract class LocationEditEvent {}

abstract class LocationEditState {}

class UpdateLocation extends LocationEditEvent {
  final Location oldLocation;
  final Location newLocation;

  UpdateLocation({@required this.oldLocation, @required this.newLocation})
      : assert(oldLocation != null),
        assert(newLocation != null);
}

class LocationNameUniqueCheck extends LocationEditEvent {
  final String name;

  LocationNameUniqueCheck({this.name}) : assert(name != null);
}

class LocationUninitialized extends LocationEditState {}

class LocationUpdated extends LocationEditState {}

class LocationNameUniqueCheckResult extends LocationEditState {
  final bool isUnique;
  final String text;

  LocationNameUniqueCheckResult({this.isUnique, this.text})
      : assert(isUnique != null),
        assert(text != null);
}

class LocationEditFailed extends LocationEditState {
  final String error;

  LocationEditFailed({this.error}) : assert(error != null);
}

class LocationEditBloc extends Bloc<LocationEditEvent, LocationEditState> {
  final LocationRepository locationRepository;

  LocationEditBloc({@required this.locationRepository})
      : assert(locationRepository != null);

  @override
  LocationEditState get initialState => LocationUninitialized();

  @override
  Stream<LocationEditState> mapEventToState(LocationEditEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is UpdateLocation) {
      final oldLocation = event.oldLocation;
      final newLocation = event.newLocation;
      try {
        newLocation.updateTime = now;
        locationRepository.save(newLocation);
        yield LocationUpdated();
      } catch (e) {
        yield LocationEditFailed(
            error:
                'Update location ${oldLocation.name} failed: ${e.toString()}');
      }
    }
    if (event is LocationNameUniqueCheck) {
      try {
        Location location =
            await locationRepository.getViaName(event.name);
        yield LocationNameUniqueCheckResult(
            isUnique: location == null, text: event.name);
      } catch (e) {
        yield LocationEditFailed(
            error: 'Check if location name unique failed: ${e.toString()}');
      }
    }
  }
}
