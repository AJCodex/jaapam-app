// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'जाप्यम्';

  @override
  String get welcome => 'स्वागत है';

  @override
  String get tagline => 'हर जाप गिनें। हर आशीर्वाद बाँटें।';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get switchLanguage => 'भाषा बदलें';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get signInSubtitle =>
      'अपने जाप गिनने और अपने समुदाय के साथ आशीर्वाद साझा करने के लिए साइन इन करें।';

  @override
  String get signInWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get or => 'अथवा';

  @override
  String get emailLabel => 'ईमेल पता';

  @override
  String get sendMagicLink => 'मुझे साइन-इन लिंक भेजें';

  @override
  String get emailLinkSent =>
      'साइन-इन लिंक भेज दिया गया है। अपना ईमेल देखें और जारी रखने के लिए लिंक पर क्लिक करें।';

  @override
  String get invalidEmail => 'कृपया एक मान्य ईमेल पता दर्ज करें।';

  @override
  String get completeProfile => 'अपनी प्रोफ़ाइल पूर्ण करें';

  @override
  String get profileIntro =>
      'अपने बारे में थोड़ा बताएँ ताकि आपका समुदाय आपको पहचान सके।';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get gotra => 'गोत्र';

  @override
  String get gotraHelper => 'आपका पारिवारिक वंश (जैसे कश्यप, भारद्वाज)।';

  @override
  String get temple => 'मंदिर';

  @override
  String get templeGyanodaya => 'श्री ज्ञानोदय जैन मंदिर';

  @override
  String get fieldRequired => 'यह जानकारी आवश्यक है।';

  @override
  String get saveAndContinue => 'सहेजें और जारी रखें';

  @override
  String get saving => 'सहेजा जा रहा है…';

  @override
  String get profileSaved => 'प्रोफ़ाइल सहेज ली गई।';

  @override
  String get signOut => 'साइन आउट';
}
