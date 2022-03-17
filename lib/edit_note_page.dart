import 'package:flutter/material.dart';
import './notes_database.dart';
import './model.dart';
import './note_from_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final List<WordPair>? wordPairList;

  const AddEditNotePage({
    Key? key,
    this.wordPairList,
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late int numberSeen ;
  late String baseWord;
  late String translation;
  late List<WordPair> wordPairList;

  @override
  void initState() {
    super.initState();

    numberSeen  = 0;
    baseWord    = '';
    translation = '';

    if(widget.wordPairList == null)
      {
        wordPairList = [new WordPair
          (numberSeen: numberSeen, baseWord: baseWord, translation: translation)
        ];
      }
    else
      {
        wordPairList = widget.wordPairList!;
        wordPairList.add(new WordPair(
            numberSeen: numberSeen, baseWord: baseWord, translation: translation)
        );
      }
    wordPairList = widget.wordPairList ?? []; //init word pair list if new, otherwise use pointer
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: NoteFormWidget(
        numberSeen: numberSeen,
        baseWord: baseWord,
        translation: translation,

        onChangedNumberSeen: (numberSeen) => setState(() => this.numberSeen = numberSeen),
        onChangedBaseWord: (baseWord) => setState(() => this.baseWord = baseWord),
        onChangedTranslation: (translation) =>
            setState(() => this.translation = translation),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = baseWord.isNotEmpty && translation.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNote,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.wordPairList != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = new WordPair(
        numberSeen: numberSeen, baseWord: baseWord, translation: translation);

    await NotesDatabase.instance.addWordPair(note);
  }

  Future addNote() async {
    final wordPair = WordPair(
      baseWord: baseWord,
      numberSeen: numberSeen,
      translation: translation,
    );

    await NotesDatabase.instance.addWordPair(wordPair);
  }
}