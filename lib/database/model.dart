class databaseKeyFields {
  static final List<String> values = [base, second, addition];

  static final String base = 'base';
  static final String second = 'second';
  static final String addition = 'addition';
}

class databaseKey {
  final String base;
  final String second;
  String? addition;

  databaseKey({
      required this.base,
      required this.second,
      this.addition});

  static databaseKey getDataBaseKeyFromKey(String key){
    int separateIdx1 = -1;
    int separateIdx2 = -1;
    for(int i=0; i<key.length; i++) {
        if((key[i] == '_') && (separateIdx2 == -1) && (separateIdx1 != -1)){
          separateIdx2 = i;
        }
        if((key[i] == '_') && (separateIdx1 == -1)){
          separateIdx1= i;
        }
      }
    String base = key.substring(0, separateIdx1);
    if(separateIdx2 != -1) {
      String second   = key.substring(separateIdx1+1, separateIdx2);
      String addition = key.substring(separateIdx2+1, key.length);
      return databaseKey(base: base, second: second, addition: addition);
    } else {
      String second = key.substring(separateIdx1+1, key.length);
      return databaseKey(base: base, second: second);
    }

  }

  String getKey({String space = '_'}){
    if(addition == null) {
      return base + space + second;
    } else {
      return base + space + second + space + addition!;
    }
  }

  static databaseKey fromJson(Map<String, Object?> json) => databaseKey(
    base: json[databaseKeyFields.base] as String,
    second: json[databaseKeyFields.second] as String,
    addition: (json[databaseKeyFields.addition] != null) ? json[databaseKeyFields.second] as String : null);
}

final int DEFAULT_MAX_NR_NOTIF = 10;

class WordPairFields {
  static final List<String> values = [
    /// Add all fields
    id, numberSeen, baseWord, translation, maxNumber
  ];

  static final String id = '_id';
  static final String numberSeen = 'numberSeen';
  static final String baseWord = 'baseWord';
  static final String translation = 'translation';
  static final String maxNumber = 'maxNumber';
}

class WordPair {
  final int? id;
  int numberSeen;
  int maxNumber = DEFAULT_MAX_NR_NOTIF;
  String baseWord;
  String translation;

  WordPair({
    this.id,
    required this.numberSeen,
    required this.baseWord,
    required this.translation,
    required this.maxNumber,
  });

  void updateBase(String newBase) {this.baseWord = newBase;}
  void updateTranslation(String newTrans) {this.translation = newTrans;}
  void iterateNumSeen() {this.numberSeen += 1;}

  WordPair copy({
    int? id,
    int? numberSeen,
    String? baseWord,
    String? translation,
    int? maxNumber
  }) =>
      WordPair(
        id: id ?? this.id,
        numberSeen: numberSeen ?? this.numberSeen,
        baseWord: baseWord ?? this.baseWord,
        translation: translation ?? this.translation,
        maxNumber: maxNumber ?? this.maxNumber,
      );

  static WordPair fromJson(Map<String, Object?> json) => WordPair(
    id: json[WordPairFields.id] as int?,
    numberSeen: json[WordPairFields.numberSeen] as int,
    baseWord: json[WordPairFields.baseWord] as String,
    translation: json[WordPairFields.translation] as String,
    maxNumber: json[WordPairFields.maxNumber] as int,
  );

  Map<String, Object?> toJson() => {
    WordPairFields.id: id,
    WordPairFields.numberSeen: numberSeen,
    WordPairFields.baseWord: baseWord,
    WordPairFields.translation: translation,
    WordPairFields.maxNumber: maxNumber,
  };
}