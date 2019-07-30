enum RepeatEvery {
  day,
  week,
  month,
  year,
}
enum MonthRepeatOn {
  day,
  week,
}
enum WeekdaySeqOfMonth {
  first,
  second,
  third,
  fourth,
  last,
}

enum RepeatType {
  custom,
  oneTime,
  daily,
  mondayToFriday,
  weekly,
  monthlyFirstWeekday,
  monthlySameDay,
  yearly,
}


class Repeat {
  RepeatType type;
  DateTime startTime;
  RepeatEvery every;
  int everyStep;
  MonthRepeatOn monthRepeatOn;
  WeekdaySeqOfMonth weekdaySeqOfMonth;
  List<int> onList = <int>[];

  static Repeat buildRepeat(RepeatType repeatType, DateTime time) {
    switch (repeatType) {
      case RepeatType.custom:
        return null;
      case RepeatType.oneTime:
        return oneTime(time);
      case RepeatType.daily:
        return daily(time);
      case RepeatType.mondayToFriday:
        return mondayToFriday(time);
      case RepeatType.weekly:
        return weekly(time);
      case RepeatType.monthlyFirstWeekday:
        return monthlyFirstWeekday(time);
      case RepeatType.monthlySameDay:
        return monthlySameDay(time);
      case RepeatType.yearly:
        return yearly(time);
      default:
        return null;
    }
  }

  static Repeat oneTime(DateTime time) {
    var repeat = Repeat();
    repeat.type = RepeatType.oneTime;
    repeat.every = RepeatEvery.day;
    repeat.everyStep = 1;
    repeat.startTime = time;
    return repeat;
  }

  static Repeat daily(DateTime time) {
    var repeat = Repeat();
    repeat.type = RepeatType.daily;
    repeat.startTime = time;
    repeat.every = RepeatEvery.day;
    repeat.everyStep = 1;
    return repeat;
  }

  static Repeat mondayToFriday(DateTime time) {
    var repeat = Repeat();
    repeat.type = RepeatType.mondayToFriday;
    repeat.startTime = time;
    repeat.every = RepeatEvery.week;
    repeat.everyStep = 1;
    repeat.onList = [1, 2, 3, 4, 5];
    return repeat;
  }

  static Repeat weekly(DateTime time) {
    var repeat = Repeat();
    repeat.type = RepeatType.weekly;
    repeat.startTime = time;
    repeat.every = RepeatEvery.week;
    repeat.everyStep = 1;
    repeat.onList = [time.weekday];
    return repeat;
  }

  static Repeat monthlyFirstWeekday(DateTime time) {
    var repeat = Repeat();
    repeat.type = RepeatType.monthlyFirstWeekday;
    repeat.startTime = time;
    repeat.monthRepeatOn = MonthRepeatOn.week;
    repeat.every = RepeatEvery.month;
    repeat.weekdaySeqOfMonth = WeekdaySeqOfMonth.first;
    repeat.everyStep = 1;
    repeat.onList = [time.weekday];
    return repeat;
  }

  static Repeat monthlySameDay(DateTime time) {
    var repeat = Repeat();
    repeat.type = RepeatType.monthlySameDay;
    repeat.startTime = time;
    repeat.every = RepeatEvery.month;
    repeat.everyStep = 1;
    repeat.monthRepeatOn = MonthRepeatOn.day;
    repeat.onList = [time.day];
    return repeat;
  }

  static Repeat yearly(DateTime time) {
    var repeat = Repeat();
    repeat.type = RepeatType.yearly;
    repeat.startTime = time;
    repeat.every = RepeatEvery.year;
    repeat.everyStep = 1;
    repeat.onList = [time.month];
    return repeat;
  }

}
