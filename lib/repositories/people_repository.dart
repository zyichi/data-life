import 'package:meta/meta.dart';

import 'package:data_life/models/people.dart';


class PeopleRepository {
  PeopleRepository();

  Future<People> getPeople(String name) async {
    return Future.delayed(Duration(seconds: 1), () => null);
  }

  Future<List<People>> searchPeople(String pattern) async {
    return Future.delayed(Duration(seconds: 1), () => []);
  }

  Future<List<People>> getAllPeople() async {
    return Future.delayed(Duration(seconds: 1), () => []);
  }
}
