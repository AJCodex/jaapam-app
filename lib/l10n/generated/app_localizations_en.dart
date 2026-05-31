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
}
