import 'package:flutter/material.dart';

class NoteFormWidget extends StatelessWidget {
  final int? numberSeen;
  final String? baseWord;
  final String? translation;
  final ValueChanged<int> onChangedNumberSeen;
  final ValueChanged<String> onChangedBaseWord;
  final ValueChanged<String> onChangedTranslation;

  const NoteFormWidget({
    Key? key,
    this.numberSeen = 0,
    this.baseWord = '',
    this.translation = '',

    required this.onChangedNumberSeen,
    required this.onChangedBaseWord,
    required this.onChangedTranslation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTitle(),
          SizedBox(height: 8),
          buildDescription(),
          SizedBox(height: 16),
        ],
      ),
    ),
  );

  Widget buildTitle() => TextFormField(
    maxLines: 1,
    initialValue: baseWord,
    style: TextStyle(
      color: Colors.white70,
      fontSize: 24,
    ),
    decoration: InputDecoration(
      border: InputBorder.none,
      hintText: 'Spanish',
      hintStyle: TextStyle(color: Colors.white70),
    ),
    validator: (title) =>
    title != null && title.isEmpty ? 'The title cannot be empty' : null,
    onChanged: onChangedBaseWord,
  );

  Widget buildDescription() => TextFormField(
    maxLines: 1,
    initialValue: translation,
    style: TextStyle(color: Colors.white70, fontSize: 24),
    decoration: InputDecoration(
      border: InputBorder.none,
      hintText: 'English',
      hintStyle: TextStyle(color: Colors.white70),
    ),
    validator: (title) => title != null && title.isEmpty
        ? 'The description cannot be empty'
        : null,
    onChanged: onChangedTranslation,
  );
}