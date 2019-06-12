import 'package:data_life/models/location.dart';


class LocationTable {
  static const name = 'location';
  static const columnId = '_id';
  static const columnLatitude = 'latitude';
  static const columnLongitude = 'longitude';
  static const columnAddress = 'address';
  static const columnDisplayAddress = 'displayAddress';
  static const columnFormattedAddress = 'formattedAddress';
  static const columnTownship = 'township';
  static const columnDistrict = 'district';
  static const columnCity = 'city';
  static const columnProvince = 'province';
  static const columnCountry = 'country';
  static const columnTotalTimeStay = 'totalTimeStay';
  static const columnLastVisitTime = 'lastVisitTime';
  static const columnCreateTime = 'createTime';
  static const columnUpdateTime = 'updateTime';

  static const createSql = '''
create table $name (
  $columnId integer primary key autoincrement,
  $columnDisplayAddress text not null,
  $columnLatitude real default null,
  $columnLongitude real default null,
  $columnAddress text default null,
  $columnFormattedAddress text default null,
  $columnTownship text default null,
  $columnDistrict text default null,
  $columnCity text default null,
  $columnProvince text default null,
  $columnCountry text default null,
  $columnTotalTimeStay integer default 0,
  $columnLastVisitTime integer default null,
  $columnCreateTime integer not null,
  $columnUpdateTime integer default null)
''';

  static const createIndexSql = '''
create unique index display_address_idx on $name(
  $columnDisplayAddress);
''';

  static List<String> get initSqlList => [createSql, createIndexSql];

  static Location fromMap(Map map) {
    final location = Location();
    location.id = map[LocationTable.columnId] as int;
    location.displayAddress = map[LocationTable.columnDisplayAddress] as String;
    location.latitude = map[LocationTable.columnLatitude] as num;
    location.longitude = map[LocationTable.columnLongitude] as num;
    location.address = map[LocationTable.columnAddress] as String;
    location.formattedAddress = map[LocationTable.columnFormattedAddress] as String;
    location.township = map[LocationTable.columnTownship] as String;
    location.district = map[LocationTable.columnDistrict] as String;
    location.city = map[LocationTable.columnCity] as String;
    location.province = map[LocationTable.columnProvince] as String;
    location.country = map[LocationTable.columnCountry] as String;
    location.totalTimeStay = map[LocationTable.columnTotalTimeStay] as int;
    location.lastVisitTime = map[LocationTable.columnLastVisitTime] as int;
    location.createTime = map[LocationTable.columnCreateTime] as int;
    location.updateTime = map[LocationTable.columnUpdateTime] as int;
    return location;
  }

  static Map<String, dynamic> toMap(Location location) {
    var map = <String, dynamic>{
      LocationTable.columnDisplayAddress: location.displayAddress,
      LocationTable.columnLatitude: location.latitude,
      LocationTable.columnLongitude: location.longitude,
      LocationTable.columnAddress: location.address,
      LocationTable.columnFormattedAddress: location.formattedAddress,
      LocationTable.columnTownship: location.township,
      LocationTable.columnDistrict: location.district,
      LocationTable.columnCity: location.city,
      LocationTable.columnProvince: location.province,
      LocationTable.columnCountry: location.country,
      LocationTable.columnTotalTimeStay: location.totalTimeStay,
      LocationTable.columnLastVisitTime: location.lastVisitTime,
      LocationTable.columnCreateTime: location.createTime,
      LocationTable.columnUpdateTime: location.updateTime,
    };
    if (location.id != null) {
      map[LocationTable.columnId] = location.id;
    }
    return map;
  }

}
