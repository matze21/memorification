import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

Future<List<List<dynamic>>> loadCSVtoDB(String filename) async {
  final _rawData = await rootBundle.loadString("assets/" + filename + ".csv");
  return const CsvToListConverter().convert(_rawData);
}
