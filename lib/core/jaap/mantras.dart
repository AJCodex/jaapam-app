/// Mantras a member can attribute a jaap session to.
enum Mantra {
  navkar,
  logassa,
  uvasaggaharam,
  bhaktamar,
  custom,
}

extension MantraX on Mantra {
  String get key => name;

  static Mantra fromKey(String? k) {
    return Mantra.values.firstWhere(
      (m) => m.name == k,
      orElse: () => Mantra.navkar,
    );
  }
}
