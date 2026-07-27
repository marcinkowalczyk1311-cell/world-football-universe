enum ContinentType { europe, asia, africa, northAmerica, southAmerica, oceania }

extension ContinentTypeData on ContinentType {
  String get displayName {
    switch (this) {
      case ContinentType.europe:
        return 'Europa';
      case ContinentType.southAmerica:
        return 'Ameryka Południowa';
      case ContinentType.northAmerica:
        return 'Ameryka Północna';
      case ContinentType.africa:
        return 'Afryka';
      case ContinentType.asia:
        return 'Azja';
      case ContinentType.oceania:
        return 'Australia i Oceania';
    }
  }
}
