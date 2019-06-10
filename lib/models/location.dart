class Location {
  int id;
  String displayAddress;
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
  int lastVisitTime;
  int createTime;
  int updateTime;

  static bool isSameLocation(Location lhs, Location rhs) {
    if (lhs == null || rhs == null) {
      return false;
    }
    if (lhs.displayAddress == rhs.displayAddress || lhs.id == rhs.id) {
      return true;
    }
    return false;
  }

  void copy(Location l) {
    id = l.id;
    displayAddress = l.displayAddress;
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

}
