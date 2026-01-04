enum AtributType {
  Benefit,
  Cost;

  /// Nilai string untuk API / database
  String get value {
    switch (this) {
      case AtributType.Benefit:
        return 'Benefit';
      case AtributType.Cost:
        return 'Cost';
    }
  }

  /// Parser jika suatu saat data datang dari backend (String)
  static AtributType fromString(String value) {
    switch (value) {
      case 'Cost':
        return AtributType.Cost;
      case 'Benefit':
      default:
        return AtributType.Benefit;
    }
  }
}
