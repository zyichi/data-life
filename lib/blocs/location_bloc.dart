import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'package:data_life/models/location.dart';

import 'package:data_life/repositories/location_repository.dart';

abstract class LocationEvent {}

abstract class LocationState {}

class UpdateLocation extends LocationEvent {
  final Location oldLocation;
  final Location newLocation;

  UpdateLocation({@required this.oldLocation, @required this.newLocation})
      : assert(oldLocation != null),
        assert(newLocation != null);
}

class LocationNameUniqueCheck extends LocationEvent {
  final String name;

  LocationNameUniqueCheck({this.name}) : assert(name != null);
}

class LocationUninitialized extends LocationState {}

class LocationUpdated extends LocationState {}

class LocationNameUniqueCheckResult extends LocationState {
  final bool isUnique;
  final String text;

  LocationNameUniqueCheckResult({this.isUnique, this.text})
      : assert(isUnique != null),
        assert(text != null);
}

class LocationFailed extends LocationState {
  final String error;

  LocationFailed({this.error}) : assert(error != null);
}

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository locationRepository;

  LocationBloc({@required this.locationRepository})
      : assert(locationRepository != null);

  @override
  LocationState get initialState => LocationUninitialized();

  @override
  Stream<LocationState> mapEventToState(LocationEvent event) async* {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (event is UpdateLocation) {
      final oldLocation = event.oldLocation;
      final newLocation = event.newLocation;
      try {
        newLocation.updateTime = now;
        locationRepository.save(newLocation);
        yield LocationUpdated();
      } catch (e) {
        yield LocationFailed(
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
        yield LocationFailed(
            error: 'Check if location name unique failed: ${e.toString()}');
      }
    }
  }
}
