import 'package:data_life/models/time_types.dart';


const maxInt = 0x7FFFFFFF;

List<DurationType> defaultDurationList = [
  DurationType.oneDay,
  DurationType.twoDay,
  DurationType.threeDay,
  DurationType.oneWeek,
  DurationType.halfMonth,
  DurationType.oneMonth,
  DurationType.threeMonth,
  DurationType.halfYear,
  DurationType.oneYear,
  DurationType.threeYear,
  DurationType.fiveYear,
  DurationType.forever,
  DurationType.customTime,
];

List<DurationType> goalDurationList = [
  DurationType.oneWeek,
  DurationType.oneMonth,
  DurationType.threeMonth,
  DurationType.oneYear,
  DurationType.forever,
  DurationType.customTime,
];


List<DurationType> goalActionDurationList = [
  DurationType.oneWeek,
  DurationType.oneMonth,
  DurationType.threeMonth,
  DurationType.oneYear,
  DurationType.forever,
  DurationType.customTime,
];
