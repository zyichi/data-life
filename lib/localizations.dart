import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'l10n/messages_all.dart';


// flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localizations.dart
// flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localizations.dart lib/l10n/intl_*.arb

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get exercise { return Intl.message('Exercise', name: 'exercise'); }
  String get skill { return Intl.message('Skill', name: 'skill'); }
  String get familyAndFriends { return Intl.message('Family and friends', name: 'familyAndFriends'); }
  String get meTime { return Intl.message('Me time', name: 'meTime'); }
  String get organizeMyLife { return Intl.message('Organize my life', name: 'organizeMyLife'); }
  String get appName { return Intl.message('DataLife', name: 'appName'); }
  String get exerciseCaption { return Intl.message('Run, do yoga, get your body moving', name: 'exerciseCaption'); }
  String get skillCaption { return Intl.message('Lean a language, practice an instrument', name: 'skillCaption'); }
  String get familyAndFriendsCaption { return Intl.message('Make time for those who matter most', name: 'familyAndFriendsCaption'); }
  String get meTimeCaption { return Intl.message('Read, meditate, take care of yourself', name: 'meTimeCaption'); }
  String get organizeMyLifeCaption { return Intl.message('Stay on top of things', name: 'organizeMyLifeCaption'); }
  String get author { return Intl.message('Zhang Yi Chi', name: 'author'); }
  String get workOut { return Intl.message('Work out', name: 'workOut'); }
  String get run { return Intl.message('Run', name: 'run'); }
  String get walk { return Intl.message('Walk', name: 'walk'); }
  String get doYoga { return Intl.message('Do yoga', name: 'doYoga'); }
  String get learnLanguage { return Intl.message('Learn a language', name: 'learnLanguage'); }
  String get learnToCode { return Intl.message('Learn to code', name: 'learnToCode'); }
  String get practiceInstrument { return Intl.message('Practice an instrument', name: 'practiceInstrument'); }
  String get makeArt { return Intl.message('Make art', name: 'makeArt'); }
  String get reachOutToFriend { return Intl.message('Reach out to a friend', name: 'reachOutToFriend'); }
  String get eatWithFamily { return Intl.message('Eat with family', name: 'eatWithFamily'); }
  String get callMom { return Intl.message('Call Mom', name: 'callMom'); }
  String get callDad { return Intl.message('Call Dad', name: 'callDad'); }
  String get read { return Intl.message('Read', name: 'read'); }
  String get meditate { return Intl.message('Meditate', name: 'meditate'); }
  String get personalHobby { return Intl.message('Personal hobby', name: 'personalHobby'); }
  String get planTheDay { return Intl.message('Plan the day', name: 'planTheDay'); }
  String get clean { return Intl.message('Clean', name: 'clean'); }
  String get doChores { return Intl.message('Do chores', name: 'doChores'); }
  String get customActivity { return Intl.message('Custom...', name: 'customActivity'); }
  String get moreOptions { return Intl.message('More options...', name: 'moreOptions'); }
  String get moreOptionsLiteral { return Intl.message('More options', name: 'moreOptionsLiteral'); }
  String get goalSummary { return Intl.message('Goal summary:', name: 'goalSummary'); }
  String get selectGoal { return Intl.message('Select a Goal', name: 'selectGoal'); }
  String get whichExercise { return Intl.message('Which exercise?', name: 'whichExercise'); }
  String get whichSkill { return Intl.message('Which skill?', name: 'whichSkill'); }
  String get whichActivity { return Intl.message('Which activity?', name: 'whichActivity'); }
  String get howOften { return Intl.message('How often?', name: 'howOften'); }
  String get forHowLong { return Intl.message('For how long?', name: 'forHowLong'); }
  String get bestTime { return Intl.message('Best time?', name: 'bestTime'); }
  String get onceMonth { return Intl.message('Once a month', name: 'onceMonth'); }
  String get twiceMonth { return Intl.message('Twice a month', name: 'twiceMonth'); }
  String get onceWeek { return Intl.message('Once a week', name: 'onceWeek'); }
  String get twiceWeek { return Intl.message('Twice a week', name: 'twiceWeek'); }
  String get threeTimesWeek { return Intl.message('3 times a week', name: 'threeTimesWeek'); }
  String get fourTimesWeek { return Intl.message('4 times a week', name: 'fourTimesWeek'); }
  String get fiveTimesWeek { return Intl.message('5 times a week', name: 'fiveTimesWeek'); }
  String get sixTimesWeek { return Intl.message('6 times a week', name: 'sixTimesWeek'); }
  String get everyday { return Intl.message('Every day', name: 'everyday'); }
  String get fifteenMinutes { return Intl.message('15 minutes', name: 'fifteenMinutes'); }
  String get thirtyMinutes { return Intl.message('30 minutes', name: 'thirtyMinutes'); }
  String get oneHour { return Intl.message('1 hour', name: 'oneHour'); }
  String get twoHours { return Intl.message('2 hours', name: 'twoHours'); }
  String get halfDay { return Intl.message('Half day', name: 'halfDay'); }
  String get wholeDay { return Intl.message('Whole day', name: 'wholeDay'); }
  String get morning { return Intl.message('Morning', name: 'morning'); }
  String get afternoon { return Intl.message('Afternoon', name: 'afternoon'); }
  String get evening { return Intl.message('Evening', name: 'evening'); }
  String get anyTime { return Intl.message('Any time', name: 'anyTime'); }
  String get discardNewActivity { return Intl.message('Are you sure you want to discard this activity?', name: 'discardNewActivity'); }
  String get save { return Intl.message('Save', name: 'save'); }
  String get cancel { return Intl.message('Cancel', name: 'cancel'); }
  String get discard { return Intl.message('Discard', name: 'discard'); }
  String get keepEditing { return Intl.message('Keep editing', name: 'keepEditing'); }
  String get createdBy { return Intl.message('Created by', name: 'createdBy'); }
  String get time { return Intl.message('Time', name: 'time'); }

  String get hike { return Intl.message('Hike', name: 'hike'); }
  String get bike { return Intl.message('Bike', name: 'bike'); }
  String get swim { return Intl.message('Swim', name: 'swim'); }
  String get rockClimb { return Intl.message('Rock climb', name: 'rockClimb'); }
  String get playTennis { return Intl.message('Play tennis', name: 'playTennis'); }
  String get playBadminton { return Intl.message('Play badminton', name: 'playBadminton'); }
  String get playBaseball { return Intl.message('Play baseball', name: 'playBaseball'); }
  String get playBasketball { return Intl.message('Play basketball', name: 'playBasketball'); }
  String get playSoccer { return Intl.message('Play soccer', name: 'playSoccer'); }
  String get wiggleEars { return Intl.message('Wiggle ears', name: 'wiggleEars'); }

  String get practicePhotography { return Intl.message('Practice photography', name: 'practicePhotography'); }
  String get honeCarpentrySkills { return Intl.message('Hone carpentry skills', name: 'honeCarpentrySkills'); }
  String get sing { return Intl.message('Sing', name: 'sing'); }
  String get learnKnot { return Intl.message('Learn a knot', name: 'learnKnot'); }
  String get learnNewSoftware { return Intl.message('Learn new software', name: 'learnNewSoftware'); }
  String get cookSomethingNew { return Intl.message('Cook something new', name: 'cookSomethingNew'); }
  String get learnToDrive { return Intl.message('Learn to drive', name: 'learnToDrive'); }
  String get learnToFly { return Intl.message('Learn to fly', name: 'learnToFly'); }

  String get planDate { return Intl.message('Plan a date', name: 'planDate'); }
  String get getDinnerWithFriends { return Intl.message('Get dinner with friends', name: 'getDinnerWithFriends'); }
  String get visitFamily { return Intl.message('Visit family', name: 'visitFamily'); }
  String get haveBBQ { return Intl.message('Have a BBQ', name: 'haveBBQ'); }
  String get playBoardGame { return Intl.message('Play a board game', name: 'playBoardGame'); }
  String get planReunion { return Intl.message('Plan a reunion', name: 'planReunion'); }
  String get planFamilyVacation { return Intl.message('Plan family vacation', name: 'planFamilyVacation'); }
  String get walkTheDog { return Intl.message('Walk the dog', name: 'walkTheDog'); }

  String get cook { return Intl.message('Cook', name: 'cook'); }
  String get journal { return Intl.message('Journal', name: 'journal'); }
  String get pray { return Intl.message('Pray', name: 'pray'); }
  String get watchMovie { return Intl.message('Watch a movie', name: 'watchMovie'); }
  String get takeSnap { return Intl.message('Take a snap', name: 'takeSnap'); }
  String get getMassage { return Intl.message('Get a massage', name: 'getMassage'); }
  String get sitInTheGrass { return Intl.message('Sit in the grass', name: 'sitInTheGrass'); }
  String get takeTheBoatOut { return Intl.message('Take the boat out', name: 'takeTheBoatOut'); }
  String get lieInHammock { return Intl.message('Lie in a hammock', name: 'lieInHammock'); }
  String get takeSelfie { return Intl.message('Take a selfie', name: 'takeSelfie'); }

  String get makeTodoList { return Intl.message('Make a to-do list', name: 'makeTodoList'); }
  String get buyGroceries { return Intl.message('Buy groceries', name: 'buyGroceries'); }
  String get study { return Intl.message('Study', name: 'study'); }
  String get doLaundry { return Intl.message('Do laundry', name: 'doLaundry'); }
  String get doFinances { return Intl.message('Do finances', name: 'doFinances'); }
  String get planTheWeek { return Intl.message('Plan the week', name: 'planTheWeek'); }
  String get clearEmailInbox { return Intl.message('Clear email inbox', name: 'clearEmailInbox'); }
  String get cleanTheHouse { return Intl.message('Clean the house', name: 'cleanTheHouse'); }

  String get totalTime { return Intl.message('Total time', name: 'totalTime'); }

  String get activities { return Intl.message('Activities', name: 'activities'); }
  String get goals { return Intl.message('Goals', name: 'goals'); }
  String get statistics { return Intl.message('Statistics', name: 'statistics'); }

  String get addActivity { return Intl.message('Add activity', name: 'addActivity'); }
  String get activity { return Intl.message('Activity', name: 'activity'); }
  String get timer { return Intl.message('Timer', name: 'timer'); }

  String get addEvent { return Intl.message('Add event...', name: 'addEvent'); }
  String get enterEvent { return Intl.message('Enter event', name: 'enterEvent'); }
  String get event { return Intl.message('Event', name: 'event'); }
  String get pleaseEnterEventName { return Intl.message('Please enter event name', name: 'pleaseEnterEventName'); }
  String get events { return Intl.message('Events', name: 'events'); }
  String get discardNewEvent { return Intl.message('Are you sure you want to discard this event?', name: 'discardNewEvent'); }

  String get detail { return Intl.message('Detail', name: 'detail'); }
  String get sentiment { return Intl.message('Sentiment', name: 'sentiment'); }
  String get eventDetail { return Intl.message('Event detail', name: 'eventDetail'); }
  String get enterEventDetail { return Intl.message('Enter event detail', name: 'enterEventDetail'); }
  String get selectSentiment { return Intl.message('Please select a sentiment', name: 'selectSentiment'); }

  String get from { return Intl.message('From', name: 'from'); }
  String get to { return Intl.message('To', name: 'to'); }
  String get expend { return Intl.message('Expend', name: 'expend'); }
  String get currencySign { return Intl.message('\$', name: 'currencySign'); }
  String get currencyName { return Intl.message('USD', name: 'currencyName'); }

  String get pleaseInputNumbers { return Intl.message('Please input numbers', name: 'pleaseInputNumbers'); }
  String get location { return Intl.message('Location', name: 'location'); }
  String get enterLocation { return Intl.message('Enter location', name: 'enterLocation'); }
  String get enterEventNameOrSelectOne { return Intl.message('Enter event name or select one', name: 'enterEventNameOrSelectOne'); }

  String get people { return Intl.message('People', name: 'people'); }
  String get goal { return Intl.message('Goal', name: 'goal'); }

  String get pleaseEnterEventTitle { return Intl.message('Please enter event title', name: 'pleaseEnterEventTitle'); }
  String get enterTitle { return Intl.message('Enter title', name: 'enterTitle'); }
  String get title { return Intl.message('Title', name: 'title'); }
  String get enterTarget { return Intl.message('Enter target', name: 'enterTarget'); }
  String get target { return Intl.message('Target', name: 'target'); }
  String get enterEventTitleOrSelectOne { return Intl.message('Enter event title or select one', name: 'enterEventTitleOrSelectOne'); }
  String get enterProgress { return Intl.message('Enter progress', name: 'enterProgress'); }
  String get enterCurrentProgress { return Intl.message('Enter current progress', name: 'enterCurrentProgress'); }
  String get progress { return Intl.message('Progress', name: 'progress'); }
  String get setProgress { return Intl.message('Set progress', name: 'setProgress'); }
  String get progressTarget { return Intl.message('Progress/Target', name: 'progressTarget'); }

  String get toDo { return Intl.message('To do', name: 'toDo'); }
  String get alreadyCompleted { return Intl.message('Already completed', name: 'alreadyCompleted'); }
  String get enterAlreadyCompleted { return Intl.message('Enter already completed', name: 'enterAlreadyCompleted'); }
  String get completed { return Intl.message('Completed', name: 'completed'); }
  String get enterCompleted { return Intl.message('Enter completed', name: 'enterCompleted'); }
  String get done { return Intl.message('Done', name: 'done'); }
  String get alreadyDone { return Intl.message('Already done', name: 'alreadyDone'); }
  String get enterDone { return Intl.message('Enter done', name: 'enterDone'); }
  String get enterAlreadyDone { return Intl.message('Enter aready done', name: 'enterAlreadyDone'); }
  String get activityForGoal { return Intl.message('Activity for goal', name: 'activityForGoal'); }

  String get action { return Intl.message('Action', name: 'action'); }
  String get actions { return Intl.message('Actions', name: 'actions'); }
  String get addAction { return Intl.message('Add action', name: 'addAction'); }
  String get actionForGoal { return Intl.message('Action for goal', name: 'actionForGoal'); }
  String get startTime { return Intl.message('Start time', name: 'startTime'); }
  String get finished { return Intl.message('Finished', name: 'finished'); }
  String get enterFinished { return Intl.message('Enter finished', name: 'enterFinished'); }

  String get begin { return Intl.message('Begin', name: 'begin'); }
  String get end { return Intl.message('End', name: 'end'); }
  String get enterSpend { return Intl.message('Enter spend', name: 'enterSpend'); }
  String get enterPeople { return Intl.message('Enter people', name: 'enterPeople'); }
}


class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }

}
