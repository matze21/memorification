List<databaseKey> tableNames = [];  // for now only work with one language

class databaseKey {
  final String base;
  final String second;

  const databaseKey(this.base, this.second);

  String getKey(){
    return base + ' ' + second;
  }
}

class WordPairFields {
  static final List<String> values = [
    /// Add all fields
    id, numberSeen, baseWord, translation
  ];

  static final String id = '_id';
  static final String numberSeen = 'numberSeen';
  static final String baseWord = 'baseWord';
  static final String translation = 'translation';
}

class WordPair {
  final int? id;
  final int numberSeen;
  final String baseWord;
  final String translation;

  const WordPair({
    this.id,
    required this.numberSeen,
    required this.baseWord,
    required this.translation,
  });

  WordPair copy({
    int? id,
    int? numberSeen,
    String? baseWord,
    String? translation,
  }) =>
      WordPair(
        id: id ?? this.id,
        numberSeen: numberSeen ?? this.numberSeen,
        baseWord: baseWord ?? this.baseWord,
        translation: translation ?? this.translation,
      );

  static WordPair fromJson(Map<String, Object?> json) => WordPair(
    id: json[WordPairFields.id] as int?,
    numberSeen: json[WordPairFields.numberSeen] as int,
    baseWord: json[WordPairFields.baseWord] as String,
    translation: json[WordPairFields.translation] as String,
  );

  Map<String, Object?> toJson() => {
    WordPairFields.id: id,
    WordPairFields.baseWord: baseWord,
    WordPairFields.numberSeen: numberSeen,
    WordPairFields.translation: translation,
  };
}