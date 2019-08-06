class Location {
  int id;
  String name;
  double latitude;
  double longitude;
  String address;
  String formattedAddress;
  String township;
  String district;
  String city;
  String province;
  String country;
  int totalTimeStay = 0;
  int lastVisitTime = 0;
  int createTime;
  int updateTime;

  void copy(Location l) {
    id = l.id;
    name = l.name;
    latitude = l.latitude;
    longitude = l.longitude;
    address = l.address;
    formattedAddress = l.formattedAddress;
    township = l.township;
    district = l.district;
    city = l.city;
    province = l.province;
    country = l.country;
    totalTimeStay = l.totalTimeStay;
    lastVisitTime = l.lastVisitTime;
    createTime = l.createTime;
    updateTime = l.updateTime;
  }

  static Location copyCreate(Location l) {
    Location location = Location();
    location.copy(l);
    return location;
  }

  bool isSameWith(Location location) {
    if (id == location.id && isContentSameWith(location)) return true;
    return false;
  }

  bool isContentSameWith(Location location) {
    if ((name ?? '') != (location.name ?? '')) return false;
    if (latitude != location.latitude) return false;
    if (longitude != location.longitude) return false;
    if ((address ?? '') != (location.address ?? '')) return false;
    if ((formattedAddress ?? '') != (location.formattedAddress ?? '')) return false;
    if ((township ?? '') != (location.township ?? '')) return false;
    if ((district ?? '') != (location.district ?? '')) return false;
    if ((city ?? '') != (location.city ?? '')) return false;
    if ((province ?? '') != (location.province ?? '')) return false;
    if ((country ?? '') != (location.country ?? '')) return false;
    if (totalTimeStay != location.totalTimeStay) return false;
    if (lastVisitTime != location.lastVisitTime) return false;
    if (createTime != location.createTime) return false;
    if (updateTime != location.updateTime) return false;
    return true;
  }

}
