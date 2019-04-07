import 'package:flutter/material.dart';

import 'package:data_life/life_db.dart';
import 'package:data_life/localizations.dart';
import 'package:data_life/models/activity.dart';


enum GoalType {
  customGoal,
  exercise, skill, familyAndFriends, meTime, organizeMyLife,
}
enum HowOften {
  onceMonth, twiceMonth, onceWeek, twiceWeek, threeTimesWeek, fourTimesWeek,
  fiveTimesWeek, sixTimesWeek, everyday,
}
enum HowLong {
  fifteenMinutes, thirtyMinutes, oneHour, twoHours, halfDay, wholeDay
}
enum BestTime {
  morning, afternoon, evening, anyTime,
}
enum ActivityType {
  customActivity,

  // Exercise
  workOut, run, walk, doYoga,

  // Skill
  learnLanguage, learnToCode, practiceInstrument, makeArt,

  // Family and friends
  reachOutToFriend, eatWithFamily, callMom, callDad,

  // Me time
  read, meditate, personalHobby,

  // Organize my life
  planTheDay, clean, doChores,

  // Exercise
  hike, bike, swim, rockClimb,
  playTennis, playBadminton, playBaseball, playBasketball,
  playSoccer, wiggleEars,

  // Skill
  practicePhotography, honeCarpentrySkills, sing, learnKnot,
  learnNewSoftware, cookSomethingNew, learnToDrive, learnToFly,

  // Family and friends
  planDate, getDinnerWithFriends, visitFamily, haveBBQ,
  playBoardGame, planReunion, planFamilyVacation, walkTheDog,

  // Me time
  cook, journal, pray, watchMovie,
  takeSnap, getMassage, sitInTheGrass, takeTheBoatOut,
  lieInHammock, takeSelfie,

  // Organize my life
  makeTodoList, buyGroceries, study, doLaundry,
  doFinances, planTheWeek, clearEmailInbox, cleanTheHouse,
}


final goalTypes = [
  GoalType.exercise, GoalType.skill, GoalType.familyAndFriends,
  GoalType.meTime, GoalType.organizeMyLife
];


String getHowOftenLiteral(BuildContext context, HowOften howOften) {
  switch (howOften) {
    case HowOften.onceMonth: return AppLocalizations.of(context).onceMonth;
    case HowOften.twiceMonth: return AppLocalizations.of(context).twiceMonth;
    case HowOften.onceWeek: return AppLocalizations.of(context).onceWeek;
    case HowOften.twiceWeek: return AppLocalizations.of(context).twiceWeek;
    case HowOften.threeTimesWeek: return AppLocalizations.of(context).threeTimesWeek;
    case HowOften.fourTimesWeek: return AppLocalizations.of(context).fourTimesWeek;
    case HowOften.fiveTimesWeek: return AppLocalizations.of(context).fiveTimesWeek;
    case HowOften.sixTimesWeek: return AppLocalizations.of(context).sixTimesWeek;
    case HowOften.everyday: return AppLocalizations.of(context).everyday;
    default: return null;
  }
}

String getHowLongLiteral(BuildContext context, HowLong howLong) {
  switch (howLong) {
    case HowLong.fifteenMinutes: return AppLocalizations.of(context).fifteenMinutes;
    case HowLong.thirtyMinutes: return AppLocalizations.of(context).thirtyMinutes;
    case HowLong.oneHour: return AppLocalizations.of(context).oneHour;
    case HowLong.twoHours: return AppLocalizations.of(context).twoHours;
    case HowLong.halfDay: return AppLocalizations.of(context).halfDay;
    case HowLong.wholeDay: return AppLocalizations.of(context).wholeDay;
    default: return null;
  }
}

String getBestTimeLiteral(BuildContext context, BestTime bestTime) {
  switch (bestTime) {
    case BestTime.morning: return AppLocalizations.of(context).morning;
    case BestTime.afternoon: return AppLocalizations.of(context).afternoon;
    case BestTime.evening: return AppLocalizations.of(context).evening;
    case BestTime.anyTime: return AppLocalizations.of(context).anyTime;
    default: return null;
  }
}

final howOftenOptions = [
  HowOften.onceWeek, HowOften.threeTimesWeek, HowOften.fiveTimesWeek,
  HowOften.everyday,
];
final howOftenAllOptions = [
  HowOften.onceMonth, HowOften.twiceMonth, HowOften.onceWeek, HowOften.twiceWeek,
  HowOften.threeTimesWeek, HowOften.fourTimesWeek, HowOften.fiveTimesWeek,
  HowOften.sixTimesWeek, HowOften.everyday,
];
final howLongOptions = [
  HowLong.fifteenMinutes, HowLong.thirtyMinutes, HowLong.oneHour, HowLong.twoHours,
  HowLong.halfDay, HowLong.wholeDay
];
final bestTimeOptions = [
  BestTime.morning, BestTime.afternoon, BestTime.evening, BestTime.anyTime,
];


String getGoalTypeLiteral(BuildContext context, GoalType goalType) {
  switch (goalType) {
    case GoalType.exercise:
      return AppLocalizations.of(context).exercise;
    case GoalType.skill:
      return AppLocalizations.of(context).skill;
    case GoalType.familyAndFriends:
      return AppLocalizations.of(context).familyAndFriends;
    case GoalType.meTime:
      return AppLocalizations.of(context).meTime;
    case GoalType.organizeMyLife:
      return AppLocalizations.of(context).organizeMyLife;
    default:
      return null;
  }
}

String getGoalTypeCaption(BuildContext context, GoalType goalType) {
  switch (goalType) {
    case GoalType.exercise:
      return AppLocalizations.of(context).exerciseCaption;
    case GoalType.skill:
      return AppLocalizations.of(context).skillCaption;
    case GoalType.familyAndFriends:
      return AppLocalizations.of(context).familyAndFriendsCaption;
    case GoalType.meTime:
      return AppLocalizations.of(context).meTimeCaption;
    case GoalType.organizeMyLife:
      return AppLocalizations.of(context).organizeMyLifeCaption;
    default:
      return null;
  }
}


List<ActivityType> getGoalActivities(GoalType goalType) {
  switch (goalType) {
    case GoalType.exercise:
      return [
        ActivityType.workOut,
        ActivityType.run,
        ActivityType.walk,
        ActivityType.doYoga,
      ];
    case GoalType.skill:
      return [
        ActivityType.learnLanguage,
        ActivityType.learnToCode,
        ActivityType.practiceInstrument,
        ActivityType.makeArt,
      ];
    case GoalType.familyAndFriends:
      return [
        ActivityType.reachOutToFriend,
        ActivityType.eatWithFamily,
        ActivityType.callMom,
        ActivityType.callDad,
      ];
    case GoalType.meTime:
      return [
        ActivityType.read,
        ActivityType.meditate,
        ActivityType.personalHobby,

      ];
    case GoalType.organizeMyLife:
      return [
        ActivityType.planTheDay,
        ActivityType.clean,
        ActivityType.doChores,
      ];
    default:
      return null;
  }
}

// TODO: Use a callback to send back new created goal, solve pop route two times.
// TODO: monitor home page foreground callback and refresh goal/activity list.
List<ActivityType> getGoalExtraActivities(GoalType goalType) {
  switch (goalType) {
    case GoalType.exercise:
      return [
        ActivityType.hike,
        ActivityType.bike,
        ActivityType.swim,
        ActivityType.rockClimb,
        ActivityType.playTennis,
        ActivityType.playBadminton,
        ActivityType.playBaseball,
        ActivityType.playBasketball,
        ActivityType.playSoccer,
        ActivityType.wiggleEars,
      ];
    case GoalType.skill:
      return [
        ActivityType.practicePhotography,
        ActivityType.honeCarpentrySkills,
        ActivityType.sing,
        ActivityType.learnKnot,
        ActivityType.learnNewSoftware,
        ActivityType.cookSomethingNew,
        ActivityType.learnToDrive,
        ActivityType.learnToFly,
      ];
    case GoalType.familyAndFriends:
      return [
        ActivityType.planDate,
        ActivityType.getDinnerWithFriends,
        ActivityType.visitFamily,
        ActivityType.haveBBQ,
        ActivityType.playBoardGame,
        ActivityType.planReunion,
        ActivityType.planFamilyVacation,
        ActivityType.walkTheDog,
      ];
    case GoalType.meTime:
      return [
        ActivityType.cook,
        ActivityType.journal,
        ActivityType.pray,
        ActivityType.watchMovie,
        ActivityType.takeSnap,
        ActivityType.getMassage,
        ActivityType.sitInTheGrass,
        ActivityType.takeTheBoatOut,
        ActivityType.lieInHammock,
        ActivityType.takeSelfie,
      ];
    case GoalType.organizeMyLife:
      return [
        ActivityType.makeTodoList,
        ActivityType.buyGroceries,
        ActivityType.study,
        ActivityType.doLaundry,
        ActivityType.doFinances,
        ActivityType.planTheWeek,
        ActivityType.clearEmailInbox,
        ActivityType.cleanTheHouse,
      ];
    default:
      return null;
  }
}


String getActivityLiteral(BuildContext context, ActivityType activityType) {
  switch (activityType) {
    case ActivityType.workOut: return AppLocalizations.of(context).workOut;
    case ActivityType.run: return AppLocalizations.of(context).run;
    case ActivityType.walk: return AppLocalizations.of(context).walk;
    case ActivityType.doYoga: return AppLocalizations.of(context).doYoga;
    case ActivityType.learnLanguage: return AppLocalizations.of(context).learnLanguage;
    case ActivityType.learnToCode: return AppLocalizations.of(context).learnToCode;
    case ActivityType.practiceInstrument: return AppLocalizations.of(context).practiceInstrument;
    case ActivityType.makeArt: return AppLocalizations.of(context).makeArt;
    case ActivityType.reachOutToFriend: return AppLocalizations.of(context).reachOutToFriend;
    case ActivityType.eatWithFamily: return AppLocalizations.of(context).eatWithFamily;
    case ActivityType.callMom: return AppLocalizations.of(context).callMom;
    case ActivityType.callDad: return AppLocalizations.of(context).callDad;
    case ActivityType.read: return AppLocalizations.of(context).read;
    case ActivityType.meditate: return AppLocalizations.of(context).meditate;
    case ActivityType.personalHobby: return AppLocalizations.of(context).personalHobby;
    case ActivityType.planTheDay: return AppLocalizations.of(context).planTheDay;
    case ActivityType.clean: return AppLocalizations.of(context).clean;
    case ActivityType.doChores: return AppLocalizations.of(context).doChores;
    case ActivityType.hike: return AppLocalizations.of(context).hike;
    case ActivityType.bike: return AppLocalizations.of(context).bike;
    case ActivityType.swim: return AppLocalizations.of(context).swim;
    case ActivityType.rockClimb: return AppLocalizations.of(context).rockClimb;
    case ActivityType.playTennis: return AppLocalizations.of(context).playTennis;
    case ActivityType.playBadminton: return AppLocalizations.of(context).playBadminton;
    case ActivityType.playBaseball: return AppLocalizations.of(context).playBaseball;
    case ActivityType.playBasketball: return AppLocalizations.of(context).playBasketball;
    case ActivityType.playSoccer: return AppLocalizations.of(context).playSoccer;
    case ActivityType.wiggleEars: return AppLocalizations.of(context).wiggleEars;
    case ActivityType.practicePhotography: return AppLocalizations.of(context).practicePhotography;
    case ActivityType.honeCarpentrySkills: return AppLocalizations.of(context).honeCarpentrySkills;
    case ActivityType.sing: return AppLocalizations.of(context).sing;
    case ActivityType.learnKnot: return AppLocalizations.of(context).learnKnot;
    case ActivityType.learnNewSoftware: return AppLocalizations.of(context).learnNewSoftware;
    case ActivityType.cookSomethingNew: return AppLocalizations.of(context).cookSomethingNew;
    case ActivityType.learnToDrive: return AppLocalizations.of(context).learnToDrive;
    case ActivityType.learnToFly: return AppLocalizations.of(context).learnToFly;
    case ActivityType.planDate: return AppLocalizations.of(context).planDate;
    case ActivityType.getDinnerWithFriends: return AppLocalizations.of(context).getDinnerWithFriends;
    case ActivityType.visitFamily: return AppLocalizations.of(context).visitFamily;
    case ActivityType.haveBBQ: return AppLocalizations.of(context).haveBBQ;
    case ActivityType.playBoardGame: return AppLocalizations.of(context).playBoardGame;
    case ActivityType.planReunion: return AppLocalizations.of(context).planReunion;
    case ActivityType.planFamilyVacation: return AppLocalizations.of(context).planFamilyVacation;
    case ActivityType.walkTheDog: return AppLocalizations.of(context).walkTheDog;
    case ActivityType.cook: return AppLocalizations.of(context).cook;
    case ActivityType.journal: return AppLocalizations.of(context).journal;
    case ActivityType.pray: return AppLocalizations.of(context).pray;
    case ActivityType.watchMovie: return AppLocalizations.of(context).watchMovie;
    case ActivityType.takeSnap: return AppLocalizations.of(context).takeSnap;
    case ActivityType.getMassage: return AppLocalizations.of(context).getMassage;
    case ActivityType.sitInTheGrass: return AppLocalizations.of(context).sitInTheGrass;
    case ActivityType.takeTheBoatOut: return AppLocalizations.of(context).takeTheBoatOut;
    case ActivityType.lieInHammock: return AppLocalizations.of(context).lieInHammock;
    case ActivityType.takeSelfie: return AppLocalizations.of(context).takeSelfie;
    case ActivityType.makeTodoList: return AppLocalizations.of(context).makeTodoList;
    case ActivityType.buyGroceries: return AppLocalizations.of(context).buyGroceries;
    case ActivityType.study: return AppLocalizations.of(context).study;
    case ActivityType.doLaundry: return AppLocalizations.of(context).doLaundry;
    case ActivityType.doFinances: return AppLocalizations.of(context).doFinances;
    case ActivityType.planTheWeek: return AppLocalizations.of(context).planTheWeek;
    case ActivityType.clearEmailInbox: return AppLocalizations.of(context).clearEmailInbox;
    case ActivityType.cleanTheHouse: return AppLocalizations.of(context).cleanTheHouse;
    case ActivityType.customActivity: return null;
    default: return null;
  }
}


class Goal {
  Goal();

  int id;
  String name;
  num target;
  int progress;
  int lastActiveTime;
  int createTime;

  List<Activity> toDoList;

  static dynamic keyFromValue(Map map, dynamic value) {
    for (var k in map.keys) {
      var v = map[k];
      if (v == value) {
        return k;
      }
    }
    return null;
  }

  Goal.fromMap(Map map) {
    id = map[GoalTable.columnId] as int;
    name = map[GoalTable.columnTarget] as String;
    target = map[GoalTable.columnTarget] as num;
    progress = map[GoalTable.columnAlreadyDone] as int;
    lastActiveTime = map[GoalTable.columnLastActiveTime] as int;
    createTime = map[GoalTable.columnCreateTime] as int;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      GoalTable.columnName: name,
      GoalTable.columnTarget: target,
      GoalTable.columnAlreadyDone: progress,
      GoalTable.columnLastActiveTime: lastActiveTime,
      GoalTable.columnCreateTime: createTime,
    };
    if (id != null) {
      map[GoalTable.columnId] = id;
    }
    return map;
  }

}


class OldGoal {
  OldGoal();

  int id;
  GoalType type;
  ActivityType activityType;
  String activityName;
  int progress;
  HowOften howOften;
  HowLong howLong;
  BestTime bestTime;
  int timeSpent;
  int lastActiveTime;
  int createTime;

  static dynamic keyFromValue(Map map, dynamic value) {
    for (var k in map.keys) {
      var v = map[k];
      if (v == value) {
        return k;
      }
    }
    return null;
  }

  OldGoal.fromMap(Map map) {
    id = map[OldGoalTable.columnId] as int;
    type = GoalType.values[map[OldGoalTable.columnType]];
    activityType = ActivityType.values[map[OldGoalTable.columnActivityType]];
    activityName = map[OldGoalTable.columnActivity] as String;
    progress = map[OldGoalTable.columnProgress] as int;
    howOften = HowOften.values[map[OldGoalTable.columnHowOften]];
    howLong = HowLong.values[map[OldGoalTable.columnHowLong]];
    bestTime = BestTime.values[map[OldGoalTable.columnBestTime]];
    timeSpent = map[OldGoalTable.columnTimeSpent];
    lastActiveTime = map[OldGoalTable.columnLastActiveTime] as int;
    createTime = map[OldGoalTable.columnCreateTime] as int;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      OldGoalTable.columnType: type.index,
      OldGoalTable.columnActivityType: activityType.index,
      OldGoalTable.columnActivity: activityName,
      OldGoalTable.columnProgress: progress,
      OldGoalTable.columnHowOften: howOften.index,
      OldGoalTable.columnHowLong: howLong.index,
      OldGoalTable.columnBestTime: bestTime.index,
      OldGoalTable.columnTimeSpent: timeSpent,
      OldGoalTable.columnLastActiveTime: lastActiveTime,
      OldGoalTable.columnCreateTime: createTime,
    };
    if (id != null) {
      map[OldGoalTable.columnId] = id;
    }
    return map;
  }
}
