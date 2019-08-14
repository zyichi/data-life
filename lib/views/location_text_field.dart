import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:amap/amap.dart';

import 'package:data_life/models/location.dart';
import 'package:data_life/repositories/location_repository.dart';
import 'package:data_life/repositories/location_provider.dart';


enum _LocationType {
  TypeMyLocation,
  TypeHistory,
  TypeTip,
  TypeNearby,
}

class _SuggestionItem {
  final String keyword;
  final Location location;
  final _LocationType locationType;
  IconData iconData;
  _SuggestionItem(this.keyword, this.location, this.locationType, this.iconData);
}

class LocationTextField extends StatefulWidget {
  final ValueChanged<Location> locationChanged;
  final Location location;
  final TextEditingController addressController;
  final bool enabled;
  final FocusNode focusNode;
  final SuggestionsBoxController suggestionsBoxController;

  LocationTextField(
      {this.locationChanged,
      this.location,
      this.addressController,
      this.enabled,
      this.focusNode,
      this.suggestionsBoxController});

  @override
  _LocationTextFieldState createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> {
  FocusNode _addressFocusNode;
  Location _selectedLocation;
  AMapLocation _aMapLocation;
  AMapReGeocodeAddress _aMapReGeocodeAddress;
  LocationRepository _locationRepository =
      LocationRepository(LocationProvider());
  TextEditingController _addressController;
  String _currentKeyword;

  @override
  void initState() {
    super.initState();

    _addressFocusNode = widget.focusNode;

    _addressController = widget.addressController ?? TextEditingController();
    if (widget.location != null) {
      _selectedLocation = widget.location;
      _addressController.text = _selectedLocation.name;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Location>> _recentLocation(String pattern) async {
    List<Location> locationList = <Location>[];
    if (pattern.isEmpty) {
      List<Location> items =
          await _locationRepository.get(startIndex: 0, count: 4);
      items.forEach((item) {
        locationList.add(item);
      });
    } else {
      List<Location> items = await _locationRepository.search(pattern, 4);
      items.forEach((item) {
        locationList.add(item);
      });
    }
    return locationList;
  }

  Future<List<Location>> _locationTips(String pattern) async {
    List<Location> locationList = <Location>[];
    if (_aMapReGeocodeAddress?.city != null) {
      List<AMapInputTip> inputTips = await AMap().inputTipsSearch(
        text: pattern,
        city: _aMapReGeocodeAddress.city,
        latitude: _aMapReGeocodeAddress.latitude,
        longitude: _aMapReGeocodeAddress.longitude,
      );
      for (AMapInputTip tip in inputTips) {
        Location location = Location();
        location.name = tip.name;
        location.address = tip.address;
        location.latitude = tip.latitude;
        location.longitude = tip.longitude;
        location.district = tip.district;
        locationList.add(location);
      }
    }

    // Search within country when result is empty.
    if (locationList.isEmpty) {
      List<AMapInputTip> inputTips = await AMap().inputTipsSearch(
        text: pattern,
        city: "",
        latitude: _aMapReGeocodeAddress.latitude,
        longitude: _aMapReGeocodeAddress.longitude,
      );
      for (AMapInputTip tip in inputTips) {
        Location location = Location();
        location.name = tip.name;
        location.address = tip.address;
        location.latitude = tip.latitude;
        location.longitude = tip.longitude;
        location.district = tip.district;
        locationList.add(location);
      }
    }
    return locationList;
  }

  List<Location> _nearbyLocation(AMapReGeocodeAddress reGeocodeAddress) {
    List<Location> locationList = <Location>[];
    for (AMapPoi poi in reGeocodeAddress.poiList) {
      Location location = Location();
      location.name = poi.name;
      location.address = poi.address;
      location.latitude = poi.latitude;
      location.longitude = poi.longitude;
      location.city = poi.city;
      location.province = poi.province;
      locationList.add(location);
    }
    return locationList;
  }

  String _getDisplayAddress(AMapReGeocodeAddress reGeocodeAddress) {
    String displayAddress = reGeocodeAddress.building;
    if (displayAddress == null || displayAddress.isEmpty) {
      displayAddress = reGeocodeAddress.neighborhood;
    }
    if (displayAddress == null || displayAddress.isEmpty) {
      if (reGeocodeAddress.aoiList.isNotEmpty) {
        displayAddress = reGeocodeAddress.aoiList[0].name;
        print("${reGeocodeAddress.aoiList[0].name}");
      }
    }
    if (displayAddress == null || displayAddress.isEmpty) {
      displayAddress = reGeocodeAddress.city ??
          "" + reGeocodeAddress.district ??
          "" + reGeocodeAddress.township ??
          "" + (reGeocodeAddress.neighborhood ?? reGeocodeAddress.building) ??
          "";
    }
    return displayAddress;
  }

  Location _myLocation(AMapReGeocodeAddress reGeocodeAddress) {
    var location = Location();
    location.address = reGeocodeAddress.formattedAddress;
    location.formattedAddress = reGeocodeAddress.formattedAddress;
    location.name = _getDisplayAddress(reGeocodeAddress);
    location.latitude = reGeocodeAddress.latitude;
    location.longitude = reGeocodeAddress.longitude;
    location.township = reGeocodeAddress.township;
    location.district = reGeocodeAddress.district;
    location.city = reGeocodeAddress.city;
    location.province = reGeocodeAddress.province;
    location.country = reGeocodeAddress.country;
    return location;
  }

  Future<List<_SuggestionItem>> _getSuggestion(String pattern) async {
    try {
      if (_aMapLocation == null) {
        _aMapLocation = await AMap().onLocationChanged.first;
        if (_aMapLocation != null) {
          _aMapReGeocodeAddress = await AMap().reGeocodeSearch(
            latitude: _aMapLocation.latitude,
            longitude: _aMapLocation.longitude,
            radius: 300,
          );
        }
      }
      List<_SuggestionItem> locationList = <_SuggestionItem>[];
      var recentLocationList = await _recentLocation(pattern);
      if (pattern.isEmpty) {
        // Return nearby POI.
        if (_aMapReGeocodeAddress != null) {
          var myLocation = _myLocation(_aMapReGeocodeAddress);
          locationList.add(_SuggestionItem(
              pattern, myLocation, _LocationType.TypeMyLocation, Icons.my_location));
        }
        locationList.addAll(recentLocationList.map((l) {
          return _SuggestionItem(pattern, l, _LocationType.TypeHistory, Icons.history);
        }));
        if (_aMapReGeocodeAddress != null) {
          var nearbyLocationList = _nearbyLocation(_aMapReGeocodeAddress);
          locationList.addAll(nearbyLocationList.map((l) {
            return _SuggestionItem(pattern, l, _LocationType.TypeNearby, Icons.near_me);
          }));
        }
      } else {
        locationList.addAll(recentLocationList.map((l) {
          return _SuggestionItem(pattern, l, _LocationType.TypeHistory, Icons.history);
        }));
        var locationTips = await _locationTips(pattern);
        locationList.addAll(locationTips.map((l) {
          return _SuggestionItem(pattern, l, _LocationType.TypeTip, Icons.near_me);
        }));
      }
      return locationList;
    } catch (e) {
      print('Get location suggestion failed: ${e.toString()}');
      return <_SuggestionItem>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadFormField(
      suggestionsBoxController: widget.suggestionsBoxController,
      textFieldConfiguration: TextFieldConfiguration(
        autocorrect: false,
        enabled: widget.enabled,
        focusNode: _addressFocusNode,
        controller: _addressController,
        decoration: InputDecoration(
          hintText: 'Enter location',
          border: InputBorder.none,
        ),
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter location';
        }
        return null;
      },
      getImmediateSuggestions: true,
      hideOnEmpty: true,
      hideOnLoading: true,
      onSuggestionSelected: (_SuggestionItem suggest) {
        if (!mounted) return;
        Location location = suggest.location;
        setState(() {
          _addressController.text = location.name;
        });
        _selectedLocation = location;
        widget.locationChanged(location);
      },
      itemBuilder: (BuildContext context, _SuggestionItem suggestion) {
        Location location = suggestion.location;
        return Padding(
          padding: const EdgeInsets.only(left: 4.0, top: 4.0, bottom: 4.0),
          child: Row(
            children: <Widget>[
              Icon(
                suggestion.iconData,
                size: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        location.name,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      Text(
                        location.address ?? '',
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: Theme.of(context)
                            .textTheme
                            .display1
                            .copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      suggestionsCallback: (String pattern) async {
        _currentKeyword = pattern;
        List<_SuggestionItem> result = await _getSuggestion(pattern);
        // TODO: do we really need this?
        if (result.isNotEmpty && result.elementAt(0).keyword == _currentKeyword) {
          return result;
        } else {
          return <_SuggestionItem>[];
        }
      },
    );
  }
}
