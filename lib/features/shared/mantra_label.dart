import '../../core/jaap/mantras.dart';
import '../../l10n/generated/app_localizations.dart';

String mantraLabel(Mantra m, AppLocalizations l) {
  switch (m) {
    case Mantra.navkar:
      return l.mantraNavkar;
    case Mantra.logassa:
      return l.mantraLogassa;
    case Mantra.bhaktamar:
      return l.mantraBhaktamar;
    case Mantra.uvasaggaharam:
      return l.mantraUvasaggaharam;
    case Mantra.custom:
      return l.mantraCustom;
  }
}
