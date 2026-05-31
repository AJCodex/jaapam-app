import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// Application name shown in app bar and browser title
  ///
  /// In en, this message translates to:
  /// **'Jaapam'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Count every jaap. Share every blessing.'**
  String get tagline;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get switchLanguage;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to count your jaaps and share blessings with your community.'**
  String get signInSubtitle;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @sendMagicLink.
  ///
  /// In en, this message translates to:
  /// **'Email me a sign-in link'**
  String get sendMagicLink;

  /// No description provided for @emailLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Sign-in link sent. Check your email and click the link to continue.'**
  String get emailLinkSent;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfile;

  /// No description provided for @profileIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about yourself so your community can recognize you.'**
  String get profileIntro;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @gotra.
  ///
  /// In en, this message translates to:
  /// **'Gotra'**
  String get gotra;

  /// No description provided for @gotraHelper.
  ///
  /// In en, this message translates to:
  /// **'Your family lineage (e.g. Kashyap, Bharadwaj).'**
  String get gotraHelper;

  /// No description provided for @temple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get temple;

  /// No description provided for @templeGyanodaya.
  ///
  /// In en, this message translates to:
  /// **'Shri Gyanodaya Jain Mandir'**
  String get templeGyanodaya;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved.'**
  String get profileSaved;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @namaste.
  ///
  /// In en, this message translates to:
  /// **'Namaste'**
  String get namaste;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @ofGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal} goal'**
  String ofGoal(String goal);

  /// No description provided for @addCustomCount.
  ///
  /// In en, this message translates to:
  /// **'Add custom count'**
  String get addCustomCount;

  /// No description provided for @lastSession.
  ///
  /// In en, this message translates to:
  /// **'Last session'**
  String get lastSession;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessionsYet;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}m ago'**
  String minutesAgo(int n);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}h ago'**
  String hoursAgo(int n);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{n}d ago'**
  String daysAgo(int n);

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @viewTarget.
  ///
  /// In en, this message translates to:
  /// **'View monthly target'**
  String get viewTarget;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntry;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual entry'**
  String get manualEntry;

  /// No description provided for @manualEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your devotional counts for sessions completed away from the app.'**
  String get manualEntrySubtitle;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @roundsHint.
  ///
  /// In en, this message translates to:
  /// **'1 round = 108 jaaps'**
  String get roundsHint;

  /// No description provided for @dateOfSadhana.
  ///
  /// In en, this message translates to:
  /// **'Date of Sadhana'**
  String get dateOfSadhana;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @mantraNavkar.
  ///
  /// In en, this message translates to:
  /// **'Navkar Mantra'**
  String get mantraNavkar;

  /// No description provided for @mantraLogassa.
  ///
  /// In en, this message translates to:
  /// **'Logassa'**
  String get mantraLogassa;

  /// No description provided for @mantraBhaktamar.
  ///
  /// In en, this message translates to:
  /// **'Bhaktamar'**
  String get mantraBhaktamar;

  /// No description provided for @mantraUvasaggaharam.
  ///
  /// In en, this message translates to:
  /// **'Uvasaggaharam'**
  String get mantraUvasaggaharam;

  /// No description provided for @mantraCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get mantraCustom;

  /// No description provided for @observationOptional.
  ///
  /// In en, this message translates to:
  /// **'Observation (optional)'**
  String get observationOptional;

  /// No description provided for @observationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning Sadhana in the temple'**
  String get observationHint;

  /// No description provided for @addToHistory.
  ///
  /// In en, this message translates to:
  /// **'Add to history'**
  String get addToHistory;

  /// No description provided for @entryAdded.
  ///
  /// In en, this message translates to:
  /// **'Entry added.'**
  String get entryAdded;

  /// No description provided for @totalAddedHint.
  ///
  /// In en, this message translates to:
  /// **'Total: {n} jaaps ({rounds} rounds)'**
  String totalAddedHint(int n, int rounds);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Meditation Journey'**
  String get historyTitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your devotional progress over time.'**
  String get historySubtitle;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @totalChantCount.
  ///
  /// In en, this message translates to:
  /// **'Total chant count'**
  String get totalChantCount;

  /// No description provided for @dailyAvg.
  ///
  /// In en, this message translates to:
  /// **'Daily avg'**
  String get dailyAvg;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @recentEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get recentEntries;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'Your journey starts with the first jaap.'**
  String get noEntries;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get deleteEntry;

  /// No description provided for @deleteEntryBody.
  ///
  /// In en, this message translates to:
  /// **'This removes {n} jaap from {date}.'**
  String deleteEntryBody(int n, String date);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @practitionerSince.
  ///
  /// In en, this message translates to:
  /// **'Practitioner since {date}'**
  String practitionerSince(String date);

  /// No description provided for @totalMalas.
  ///
  /// In en, this message translates to:
  /// **'Total Malas'**
  String get totalMalas;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get dailyStreak;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @dailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoalLabel;

  /// No description provided for @editDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit daily goal'**
  String get editDailyGoal;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @personalTarget.
  ///
  /// In en, this message translates to:
  /// **'Personal Targets'**
  String get personalTarget;

  /// No description provided for @monthlyTarget.
  ///
  /// In en, this message translates to:
  /// **'Monthly target'**
  String get monthlyTarget;

  /// No description provided for @editTarget.
  ///
  /// In en, this message translates to:
  /// **'Edit target'**
  String get editTarget;

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{p}% complete'**
  String percentComplete(int p);

  /// No description provided for @weeklyDevotion.
  ///
  /// In en, this message translates to:
  /// **'Weekly devotion'**
  String get weeklyDevotion;

  /// No description provided for @completedMilestones.
  ///
  /// In en, this message translates to:
  /// **'Completed milestones'**
  String get completedMilestones;

  /// No description provided for @milestoneFirstMala.
  ///
  /// In en, this message translates to:
  /// **'First 108 Jaaps'**
  String get milestoneFirstMala;

  /// No description provided for @milestoneFirst1000.
  ///
  /// In en, this message translates to:
  /// **'First 1,000 Jaaps'**
  String get milestoneFirst1000;

  /// No description provided for @milestone7DayStreak.
  ///
  /// In en, this message translates to:
  /// **'7-Day Streak'**
  String get milestone7DayStreak;

  /// No description provided for @milestone10000.
  ///
  /// In en, this message translates to:
  /// **'10,000 Jaaps'**
  String get milestone10000;

  /// No description provided for @expandPractice.
  ///
  /// In en, this message translates to:
  /// **'Expand your practice'**
  String get expandPractice;

  /// No description provided for @expandPracticeBody.
  ///
  /// In en, this message translates to:
  /// **'Guided sessions for deep focus.'**
  String get expandPracticeBody;

  /// No description provided for @setMonthlyTarget.
  ///
  /// In en, this message translates to:
  /// **'Set monthly target'**
  String get setMonthlyTarget;

  /// No description provided for @noTargetSet.
  ///
  /// In en, this message translates to:
  /// **'No target set for this month.'**
  String get noTargetSet;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community Campaign'**
  String get communityTitle;

  /// No description provided for @communityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Community campaigns arrive in Phase 6.'**
  String get communityComingSoon;

  /// No description provided for @communityComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Soon you\'ll join a temple-wide goal with a live activity feed.'**
  String get communityComingSoonBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
