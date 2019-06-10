import 'package:flutter/material.dart';

import 'package:data_life/repositories/action_repository.dart';
import 'package:data_life/repositories/contact_repository.dart';
import 'package:data_life/repositories/moment_repository.dart';
import 'package:data_life/repositories/location_repository.dart';


class Repositories extends InheritedWidget {

  final ActionRepository actionRepository;
  final ContactRepository contactRepository;
  final MomentRepository momentRepository;
  final LocationRepository locationRepository;

  Repositories({
    this.actionRepository,
    this.contactRepository,
    this.momentRepository,
    this.locationRepository,
    Key key,
    Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }

  static Repositories of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(Repositories);
  }
}
