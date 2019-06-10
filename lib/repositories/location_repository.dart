import 'package:data_life/paging/page_repository.dart';

import 'package:data_life/models/location.dart';
import 'package:data_life/repositories/location_provider.dart';


class LocationRepository extends PageRepository<Location> {
  final LocationProvider _locationProvider;

  LocationRepository(this._locationProvider);

  @override
  Future<int> count() async {
    return _locationProvider.count();
  }

  @override
  Future<List<Location>> get({int startIndex, int count}) async {
    return _locationProvider.get(startIndex: startIndex, count: count);
  }

  Future<Location> getViaId(int id) async {
    return _locationProvider.getViaId(id);
  }

  Future<Location> getViaDisplayAddress(String displayAddress) async {
    return _locationProvider.getViaDisplayAddress(displayAddress);
  }

  Future<List<Location>> search(String pattern, int limit) async {
    return _locationProvider.search(pattern, limit);
  }

  Future<int> save(Location location) async {
    return _locationProvider.save(location);
  }
}
