List<databaseKey> tableNames = [];  // for now only work with one language

class databaseKeyFields {
  static final List<String> values = [base, second];

  static final String base = 'base';
  static final String second = 'second';
}

class databaseKey {
  final String base;
  final String second;

  const databaseKey({
      required this.base,
      required this.second});

  static databaseKey getDataBaseKeyFromKey(String key){
    int separateIdx = -1;
    for(int i=0; i<key.length; i++) {
        if(key[i] == '_'){
          separateIdx = i;
        }
      }
    String base = key.substring(0, separateIdx);
    String second = key.substring(separateIdx+1, key.length);
    return databaseKey(base: base, second: second);
  }

  String getKey(){
    return base + '_' + second;
  }

  static databaseKey fromJson(Map<String, Object?> json) => databaseKey(
    base: json[databaseKeyFields.base] as String,
    second: json[databaseKeyFields.second] as String,
  );
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