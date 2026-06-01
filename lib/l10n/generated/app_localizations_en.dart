// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Jaapam';

  @override
  String get welcome => 'Welcome';

  @override
  String get tagline => 'Count every jaap. Share every blessing.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get switchLanguage => 'Switch language';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInSubtitle =>
      'Sign in to count your jaaps and share blessings with your community.';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get or => 'OR';

  @override
  String get emailLabel => 'Email address';

  @override
  String get sendMagicLink => 'Email me a sign-in link';

  @override
  String get emailLinkSent =>
      'Sign-in link sent. Check your email and click the link to continue.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get completeProfile => 'Complete your profile';

  @override
  String get profileIntro =>
      'Tell us a little about yourself so your community can recognize you.';

  @override
  String get fullName => 'Full name';

  @override
  String get gotra => 'Gotra';

  @override
  String get gotraHelper => 'Your family lineage (e.g. Kashyap, Bharadwaj).';

  @override
  String get temple => 'Temple';

  @override
  String get templeGyanodaya => 'Shri Gyanodaya Jain Mandir';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get saving => 'Saving…';

  @override
  String get profileSaved => 'Profile saved.';

  @override
  String get signOut => 'Sign out';

  @override
  String get navHome => 'Home';

  @override
  String get navCommunity => 'Community';

  @override
  String get navAdd => 'Add';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get namaste => 'Jai-Jinendra';

  @override
  String get today => 'Today';

  @override
  String get goal => 'Goal';

  @override
  String get personal => 'Personal';

  @override
  String get community => 'Community';

  @override
  String get confirmAddTitle => 'Add to today\'s count?';

  @override
  String confirmAddBody(int n) {
    return 'This will add $n jaap to your personal count for today. Continue?';
  }

  @override
  String confirmAddCampaignBody(int n) {
    return 'This will add $n jaap to your personal count AND contribute to the active community campaign. Continue?';
  }

  @override
  String get confirm => 'Yes, add';

  @override
  String get alsoContributeCampaign => 'Also contribute to active campaign';

  @override
  String get contributedToCampaign => 'Added & contributed to campaign.';

  @override
  String ofGoal(String goal) {
    return 'of $goal goal';
  }

  @override
  String get addCustomCount => 'Add custom count';

  @override
  String get lastSession => 'Last session';

  @override
  String get streak => 'Streak';

  @override
  String get noSessionsYet => 'No sessions yet';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int n) {
    return '${n}m ago';
  }

  @override
  String hoursAgo(int n) {
    return '${n}h ago';
  }

  @override
  String daysAgo(int n) {
    return '${n}d ago';
  }

  @override
  String get daysUnit => 'days';

  @override
  String get viewTarget => 'View monthly target';

  @override
  String get addEntry => 'Add entry';

  @override
  String get manualEntry => 'Manual entry';

  @override
  String get manualEntrySubtitle =>
      'Add your devotional counts for sessions completed away from the app.';

  @override
  String get rounds => 'Rounds';

  @override
  String get roundsHint => '1 round = 108 jaaps';

  @override
  String get dateOfSadhana => 'Date of Sadhana';

  @override
  String get focus => 'Focus';

  @override
  String get mantraNavkar => 'Navkar Mantra';

  @override
  String get mantraLogassa => 'Logassa';

  @override
  String get mantraBhaktamar => 'Bhaktamar';

  @override
  String get mantraUvasaggaharam => 'Uvasaggaharam';

  @override
  String get mantraCustom => 'Custom';

  @override
  String get observationOptional => 'Observation (optional)';

  @override
  String get observationHint => 'e.g. Morning Sadhana in the temple';

  @override
  String get addToHistory => 'Add to history';

  @override
  String get entryAdded => 'Entry added.';

  @override
  String totalAddedHint(int n, int rounds) {
    return 'Total: $n jaaps ($rounds rounds)';
  }

  @override
  String get historyTitle => 'Meditation Journey';

  @override
  String get historySubtitle => 'Your devotional progress over time.';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get customRange => 'Custom Range';

  @override
  String get totalChantCount => 'Total chant count';

  @override
  String get dailyAvg => 'Daily avg';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get recentEntries => 'Recent entries';

  @override
  String get noEntries => 'Your journey starts with the first jaap.';

  @override
  String get delete => 'Delete';

  @override
  String get deleteEntry => 'Delete entry?';

  @override
  String deleteEntryBody(int n, String date) {
    return 'This removes $n jaap from $date.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get profileTitle => 'Profile';

  @override
  String practitionerSince(String date) {
    return 'Practitioner since $date';
  }

  @override
  String get totalMalas => 'Total Malas';

  @override
  String get dailyStreak => 'Daily Streak';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get appLanguage => 'App language';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get dailyGoalLabel => 'Daily Jaap Target';

  @override
  String get editDailyGoal => 'Edit daily jaap target';

  @override
  String get save => 'Save';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get personalTarget => 'Personal Targets';

  @override
  String get monthlyTarget => 'Monthly target';

  @override
  String get editTarget => 'Edit target';

  @override
  String percentComplete(int p) {
    return '$p% complete';
  }

  @override
  String get weeklyDevotion => 'Weekly devotion';

  @override
  String get completedMilestones => 'Completed milestones';

  @override
  String get milestoneFirstMala => 'First 108 Jaaps';

  @override
  String get milestoneFirst1000 => 'First 1,000 Jaaps';

  @override
  String get milestone7DayStreak => '7-Day Streak';

  @override
  String get milestone10000 => '10,000 Jaaps';

  @override
  String get expandPractice => 'Expand your practice';

  @override
  String get expandPracticeBody => 'Guided sessions for deep focus.';

  @override
  String get setMonthlyTarget => 'Set monthly target';

  @override
  String get noTargetSet => 'No target set for this month.';

  @override
  String get communityTitle => 'Community Campaign';

  @override
  String get noActiveCampaign => 'No active campaign';

  @override
  String get noActiveCampaignBody =>
      'Start a temple-wide goal so devotees can chant together.';

  @override
  String get noActiveCampaignForDevotee =>
      'Your temple admin hasn\'t started a campaign yet. Please check back soon.';

  @override
  String get adminOnlyAction => 'Only the temple admin can start a campaign.';

  @override
  String get startCampaign => 'Start a campaign';

  @override
  String get createCampaign => 'Create campaign';

  @override
  String get campaignTitleLabel => 'Campaign title';

  @override
  String get campaignTitleHint => 'e.g. Paryushan 2026 – 1 Million Jaap';

  @override
  String get campaignSubtitleLabel => 'Subtitle (optional)';

  @override
  String get campaignGoalLabel => 'Goal (total jaaps)';

  @override
  String devoteesParticipating(int n) {
    return '$n devotees participating';
  }

  @override
  String ofGoalShort(String goal) {
    return 'of $goal goal';
  }

  @override
  String get contributeNow => 'Contribute now';

  @override
  String get liveActivity => 'Live activity';

  @override
  String get noActivityYet => 'No activity yet. Be the first to chant.';

  @override
  String justAddedJaap(String name, int n) {
    return '$name just added $n jaap';
  }

  @override
  String get myContribution => 'My contribution';

  @override
  String get topContributors => 'Top contributors';

  @override
  String get endCampaign => 'End campaign';

  @override
  String get endCampaignBody =>
      'This will close the active campaign. Continue?';

  @override
  String get welcomeTitle => 'Count Your Blessings,\nConnect with Community';

  @override
  String get welcomeSubtitle =>
      'A sacred space to track your jaap and unite with your temple.';

  @override
  String get getStarted => 'Get started';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get termsNote =>
      'By continuing you agree to our Terms & Privacy Policy.';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get legalUpdated => 'Last updated';

  @override
  String get privacyIntro =>
      'Jaapam stores only the information you provide so we can show your personal devotion count and your contribution to your temple\'s community campaigns.';

  @override
  String get privacyDataCollected => 'Data we store';

  @override
  String get privacyDataCollectedBody =>
      'Your sign-in email, your chosen display name, your selected temple, the count and date of every jaap session you record, and your contribution to any active community campaign.';

  @override
  String get privacyDataNotCollected => 'What we do NOT collect';

  @override
  String get privacyDataNotCollectedBody =>
      'Location, contacts, payment information, or any data outside the app. We do not sell or share your data with third parties.';

  @override
  String get privacyAccess => 'Your rights';

  @override
  String get privacyAccessBody =>
      'You may sign out at any time. To delete your account and all associated data, contact the temple administrator who will erase your records from Firestore.';

  @override
  String get termsIntro =>
      'Jaapam is a devotional tracking tool offered free of charge to the temple community. By using it you accept the following:';

  @override
  String get termsAcceptableUse => 'Acceptable use';

  @override
  String get termsAcceptableUseBody =>
      'Use the app only to record your own genuine devotional practice. Do not impersonate others, do not attempt to manipulate community counts, and do not use the app for any unlawful purpose.';

  @override
  String get termsAvailability => 'Availability';

  @override
  String get termsAvailabilityBody =>
      'The app is provided as-is. While we work to keep it always available, we cannot guarantee uninterrupted service.';

  @override
  String get termsLiability => 'Liability';

  @override
  String get termsLiabilityBody =>
      'The temple and the app maintainers are not liable for any indirect loss arising from use of the app.';
}
