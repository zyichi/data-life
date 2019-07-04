import 'package:flutter/material.dart';

import 'package:data_life/models/time_types.dart';


class TypeToStr {

  static String myDurationStr(DurationType myDuration, BuildContext context) {
    switch (myDuration) {
      case DurationType.oneDay:
        return "One day";
      case DurationType.twoDay:
        return "Tow day";
      case DurationType.threeDay:
        return "Three day";
      case DurationType.oneWeek:
        return "One week";
      case DurationType.halfMonth:
        return "Half month";
      case DurationType.oneMonth:
        return "One month";
      case DurationType.threeMonth:
        return "Three month";
      case DurationType.halfYear:
        return "Half year";
      case DurationType.oneYear:
        return "One year";
      case DurationType.threeYear:
        return "Three year";
      case DurationType.fiveYear:
        return "Five year";
      case DurationType.forever:
        return "Forever";
      case DurationType.customTime:
        return "Custom end time...";
      default:
        return null;
    }
  }

}
