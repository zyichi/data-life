import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:data_life/models/time_types.dart';
import 'package:data_life/models/repeat_types.dart';
import 'package:data_life/models/goal_action.dart';
import 'package:data_life/models/goal.dart';

import 'package:data_life/utils/time_util.dart';

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

  static String monthRepeatOnToStr(MonthRepeatOn monthRepeatsOn, BuildContext context) {
    switch (monthRepeatsOn) {
      case MonthRepeatOn.day:
        return 'Day';
      case MonthRepeatOn.week:
        return 'Week';
      default:
        return null;
    }
  }

  static String goalActionStatusToStr(GoalActionStatus status, BuildContext context) {
    switch (status) {
      case GoalActionStatus.ongoing:
        return '正在进行';
      case GoalActionStatus.finished:
        return '已完成';
      default:
        return null;
    }
  }

  static String repeatEveryToStr(RepeatEvery t, BuildContext context) {
    switch (t) {
      case RepeatEvery.day:
        return 'day';
      case RepeatEvery.week:
        return 'week';
      case RepeatEvery.month:
        return 'month';
      case RepeatEvery.year:
        return 'year';
      default:
        return null;
    }
  }

  static String weekdaySeqOfMonthToStr(WeekdaySeqOfMonth seq, context) {
    switch (seq) {
      case WeekdaySeqOfMonth.first:
        return 'First';
      case WeekdaySeqOfMonth.second:
        return 'Second';
      case WeekdaySeqOfMonth.third:
        return 'Third';
      case WeekdaySeqOfMonth.fourth:
        return 'Fourth';
      case WeekdaySeqOfMonth.last:
        return 'Last';
      default:
        return null;
    }
  }

  static String customRepeatToReadableText(Repeat repeat, BuildContext context) {
    if (repeat.every == RepeatEvery.day) {
      String dayText = repeat.everyStep == 1 ? 'day' : '${repeat.everyStep} days';
      return 'every $dayText';
    }
    List<int> repeatOnList = <int>[];
    repeatOnList.addAll(repeat.onList);
    repeatOnList.sort();
    if (repeat.every == RepeatEvery.week) {
      var weekdayTextList = TimeUtil.getWeekdayTextList(Localizations.localeOf(context).toString());
      List<String> weeks = repeatOnList.map((weekday) {
        return weekdayTextList[weekday];
      }).toList();
      String weekText =
      repeat.everyStep == 1 ? 'week' : '${repeat.everyStep} weeks';
      return 'every $weekText on ${weeks.join(', ')}';
    }
    if (repeat.every == RepeatEvery.month) {
      if (repeat.monthRepeatOn == MonthRepeatOn.day) {
        List<String> days = repeatOnList.map((day) {
          return day.toString();
        }).toList();
        String monthText =
        repeat.everyStep == 1 ? 'month' : '${repeat.everyStep} months';
        return 'every $monthText on ${days.join(', ')}';
      } else {
        var weekdayTextList = TimeUtil.getWeekdayTextList(Localizations.localeOf(context).toString());
        List<String> weeks = repeatOnList.map((weekday) {
          return weekdayTextList[weekday];
        }).toList();
        String monthText =
        repeat.everyStep == 1 ? 'month' : '${repeat.everyStep} months';
        String weekdaySeqText =
        weekdaySeqOfMonthToStr(repeat.weekdaySeqOfMonth, context);
        return 'every $monthText on ${weekdaySeqText.toLowerCase()} ${weeks.join(', ')}';
      }
    }
    if (repeat.every == RepeatEvery.year) {
      var monthTextList = TimeUtil.getMonthTextList(Localizations.localeOf(context).toString());
      List<String> years = repeatOnList.map((month) {
        return monthTextList[month];
      }).toList();
      String yearText =
      repeat.everyStep == 1 ? 'year' : '${repeat.everyStep} years';
      return 'every $yearText on ${years.join(', ')} ${repeat.startTime.day}';
    }
    return 'unknown repeat';
  }

  static String repeatToReadableText(Repeat repeat, BuildContext context) {
    switch (repeat.type) {
      case RepeatType.oneTime:
        return 'One-time action';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.mondayToFriday:
        return 'Monday to Friday';
      case RepeatType.weekly:
        return 'Weekly (every ${DateFormat(DateFormat.WEEKDAY).format(repeat.startTime)})';
      case RepeatType.monthlyFirstWeekday:
        return 'Monthly (first ${DateFormat(DateFormat.WEEKDAY).format(repeat.startTime)} of every month)';
      case RepeatType.monthlySameDay:
        return 'Monthly (on the same day each month)';
      case RepeatType.yearly:
        return 'Yearly (every ${DateFormat(DateFormat.MONTH_DAY).format(repeat.startTime)})';
      case RepeatType.custom:
        return customRepeatToReadableText(repeat, context);
      default:
        return null;
    }
  }

  static String goalStatusToStr(GoalStatus status, BuildContext context) {
    switch (status) {
      case GoalStatus.none:
        return '无';
      case GoalStatus.ongoing:
        return '进行中';
      case GoalStatus.finished:
        return '已完成';
      case GoalStatus.expired:
        return '已过期';
      case GoalStatus.paused:
        return '已暂停';
    }
    return 'Unknown';
  }
}
