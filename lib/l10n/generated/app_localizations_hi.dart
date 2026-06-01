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

  @override
  String get navHome => 'होम';

  @override
  String get navCommunity => 'समुदाय';

  @override
  String get navAdd => 'जोड़ें';

  @override
  String get navHistory => 'इतिहास';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get namaste => 'जय जिनेन्द्र';

  @override
  String get today => 'आज';

  @override
  String get goal => 'लक्ष्य';

  @override
  String get personal => 'व्यक्तिगत';

  @override
  String get community => 'समुदाय';

  @override
  String get confirmAddTitle => 'आज की गणना में जोड़ें?';

  @override
  String confirmAddBody(int n) {
    return 'यह आज की आपकी व्यक्तिगत गणना में $n जाप जोड़ेगा। जारी रखें?';
  }

  @override
  String confirmAddCampaignBody(int n) {
    return 'यह आज की व्यक्तिगत गणना में $n जाप जोड़ेगा और सक्रिय अभियान में भी योगदान देगा। जारी रखें?';
  }

  @override
  String get confirm => 'हाँ, जोड़ें';

  @override
  String get alsoContributeCampaign => 'सक्रिय अभियान में भी योगदान दें';

  @override
  String get contributedToCampaign => 'जोड़ा गया और अभियान में योगदान दिया।';

  @override
  String ofGoal(String goal) {
    return '$goal के लक्ष्य का';
  }

  @override
  String get addCustomCount => 'कस्टम गणना जोड़ें';

  @override
  String get lastSession => 'अंतिम सत्र';

  @override
  String get streak => 'सिलसिला';

  @override
  String get noSessionsYet => 'अभी कोई सत्र नहीं';

  @override
  String get justNow => 'अभी-अभी';

  @override
  String minutesAgo(int n) {
    return '$n मिनट पहले';
  }

  @override
  String hoursAgo(int n) {
    return '$n घंटे पहले';
  }

  @override
  String daysAgo(int n) {
    return '$n दिन पहले';
  }

  @override
  String get daysUnit => 'दिन';

  @override
  String get viewTarget => 'मासिक लक्ष्य देखें';

  @override
  String get addEntry => 'प्रविष्टि जोड़ें';

  @override
  String get manualEntry => 'मैनुअल प्रविष्टि';

  @override
  String get manualEntrySubtitle =>
      'ऐप के बाहर पूरे किए गए सत्रों की गणना यहाँ जोड़ें।';

  @override
  String get rounds => 'माला';

  @override
  String get roundsHint => '1 माला = 108 जाप';

  @override
  String get dateOfSadhana => 'साधना की तिथि';

  @override
  String get focus => 'केंद्र';

  @override
  String get mantraNavkar => 'णमोकार मंत्र';

  @override
  String get mantraLogassa => 'लोगस्स';

  @override
  String get mantraBhaktamar => 'भक्तामर';

  @override
  String get mantraUvasaggaharam => 'उवसग्गहरं';

  @override
  String get mantraCustom => 'अन्य';

  @override
  String get observationOptional => 'टिप्पणी (वैकल्पिक)';

  @override
  String get observationHint => 'जैसे: मंदिर में प्रातः साधना';

  @override
  String get addToHistory => 'इतिहास में जोड़ें';

  @override
  String get entryAdded => 'प्रविष्टि जुड़ गई।';

  @override
  String totalAddedHint(int n, int rounds) {
    return 'कुल: $n जाप ($rounds माला)';
  }

  @override
  String get historyTitle => 'साधना यात्रा';

  @override
  String get historySubtitle => 'समय के साथ आपकी आध्यात्मिक प्रगति।';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get thisMonth => 'इस माह';

  @override
  String get customRange => 'कस्टम अवधि';

  @override
  String get totalChantCount => 'कुल जाप गणना';

  @override
  String get dailyAvg => 'दैनिक औसत';

  @override
  String get currentStreak => 'वर्तमान सिलसिला';

  @override
  String get recentEntries => 'हाल की प्रविष्टियाँ';

  @override
  String get noEntries => 'आपकी यात्रा पहले जाप से प्रारंभ होती है।';

  @override
  String get delete => 'हटाएँ';

  @override
  String get deleteEntry => 'प्रविष्टि हटाएँ?';

  @override
  String deleteEntryBody(int n, String date) {
    return 'इससे $date की $n जाप हट जाएगी।';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get profileTitle => 'प्रोफ़ाइल';

  @override
  String practitionerSince(String date) {
    return '$date से साधक';
  }

  @override
  String get totalMalas => 'कुल माला';

  @override
  String get dailyStreak => 'दैनिक सिलसिला';

  @override
  String get preferences => 'वरीयताएँ';

  @override
  String get notifications => 'सूचनाएँ';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get appLanguage => 'ऐप भाषा';

  @override
  String get privacySecurity => 'गोपनीयता और सुरक्षा';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get dailyGoalLabel => 'दैनिक लक्ष्य';

  @override
  String get editDailyGoal => 'दैनिक लक्ष्य संपादित करें';

  @override
  String get save => 'सहेजें';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get personalTarget => 'व्यक्तिगत लक्ष्य';

  @override
  String get monthlyTarget => 'मासिक लक्ष्य';

  @override
  String get editTarget => 'लक्ष्य संपादित करें';

  @override
  String percentComplete(int p) {
    return '$p% पूर्ण';
  }

  @override
  String get weeklyDevotion => 'साप्ताहिक साधना';

  @override
  String get completedMilestones => 'पूरे किए गए पड़ाव';

  @override
  String get milestoneFirstMala => 'पहली 108 जाप';

  @override
  String get milestoneFirst1000 => 'पहली 1,000 जाप';

  @override
  String get milestone7DayStreak => '7-दिन का सिलसिला';

  @override
  String get milestone10000 => '10,000 जाप';

  @override
  String get expandPractice => 'अपनी साधना का विस्तार करें';

  @override
  String get expandPracticeBody => 'गहरी एकाग्रता हेतु मार्गदर्शित सत्र।';

  @override
  String get setMonthlyTarget => 'मासिक लक्ष्य निर्धारित करें';

  @override
  String get noTargetSet => 'इस माह के लिए कोई लक्ष्य निर्धारित नहीं है।';

  @override
  String get communityTitle => 'सामुदायिक अभियान';

  @override
  String get noActiveCampaign => 'कोई सक्रिय अभियान नहीं';

  @override
  String get noActiveCampaignBody =>
      'मंदिर-व्यापी लक्ष्य प्रारंभ करें ताकि भक्तजन साथ मिलकर जाप कर सकें।';

  @override
  String get noActiveCampaignForDevotee =>
      'आपके मंदिर के व्यवस्थापक ने अभी कोई अभियान प्रारंभ नहीं किया है। कृपया कुछ समय बाद देखें।';

  @override
  String get adminOnlyAction =>
      'केवल मंदिर का व्यवस्थापक ही अभियान प्रारंभ कर सकता है।';

  @override
  String get startCampaign => 'अभियान प्रारंभ करें';

  @override
  String get createCampaign => 'अभियान बनाएँ';

  @override
  String get campaignTitleLabel => 'अभियान शीर्षक';

  @override
  String get campaignTitleHint => 'जैसे: पर्युषण 2026 – 10 लाख जाप';

  @override
  String get campaignSubtitleLabel => 'उपशीर्षक (वैकल्पिक)';

  @override
  String get campaignGoalLabel => 'लक्ष्य (कुल जाप)';

  @override
  String devoteesParticipating(int n) {
    return '$n भक्त भाग ले रहे हैं';
  }

  @override
  String ofGoalShort(String goal) {
    return '$goal के लक्ष्य का';
  }

  @override
  String get contributeNow => 'अभी योगदान दें';

  @override
  String get liveActivity => 'लाइव गतिविधि';

  @override
  String get noActivityYet => 'अभी कोई गतिविधि नहीं। पहले जाप कर्ता बनें।';

  @override
  String justAddedJaap(String name, int n) {
    return '$name ने अभी $n जाप जोड़े';
  }

  @override
  String get myContribution => 'मेरा योगदान';

  @override
  String get topContributors => 'शीर्ष योगदानकर्ता';

  @override
  String get endCampaign => 'अभियान समाप्त करें';

  @override
  String get endCampaignBody => 'यह सक्रिय अभियान को बंद कर देगा। जारी रखें?';

  @override
  String get welcomeTitle => 'अपने आशीर्वाद गिनें,\nसमुदाय से जुड़ें';

  @override
  String get welcomeSubtitle =>
      'आपके जाप को ट्रैक करने और अपने मंदिर से जुड़ने का पवित्र स्थान।';

  @override
  String get getStarted => 'प्रारंभ करें';

  @override
  String get alreadyHaveAccount => 'मेरे पास पहले से खाता है';

  @override
  String get termsNote =>
      'जारी रखने पर आप हमारी सेवा शर्तों और गोपनीयता नीति से सहमत होते हैं।';
}
