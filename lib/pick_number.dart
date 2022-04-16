// import 'package:flutter/material.dart';
// import 'package:numberpicker/numberpicker.dart';
//
// class NumberPickerDemo extends StatefulWidget {
//   @override
//   _NumberPickerDemoState createState() => _NumberPickerDemoState();
// }
//
// class _NumberPickerDemoState extends State<NumberPickerDemo> {
//   int _currentIntValue = 10;
//   double _currentDoubleValue = 3.0;
//   late NumberPicker integerNumberPicker;
//   late NumberPicker decimalNumberPicker;
//
//   _handleValueChanged(var value) {
//     if (value != null) {
//       if (value is int) {
//         setState(() => _currentIntValue = value);
//       } else {
//         setState(() => _currentDoubleValue = value);
//       }
//     }
//   }
//
//   _handleValueChangedExternally(var value) {
//     if (value != null) {
//       if (value is int) {
//         setState(() => _currentIntValue = value);
//         //integerNumberPicker.animateInt(value);
//       } else {
//         setState(() => _currentDoubleValue = value);
//         //decimalNumberPicker.animateDecimalAndInteger(value);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     integerNumberPicker = new NumberPicker.integer(
//       initialValue: _currentIntValue,
//       minValue: 0,
//       maxValue: 100,
//       step: 10,
//       onChanged: _handleValueChanged,
//     );
//     //build number picker for decimal values
//     decimalNumberPicker = new NumberPicker.decimal(
//         initialValue: _currentDoubleValue,
//         minValue: 1,
//         maxValue: 5,
//         decimalPlaces: 2,
//         onChanged: _handleValueChanged);
//     //scaffold the full homepage
//     return new Scaffold(
//         appBar: new AppBar(
//           title: new Text('Number Picker Demo'),
//           centerTitle:true,
//         ),
//         body: new Center(
//           child: new Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               integerNumberPicker,
//               ElevatedButton(
//                 onPressed: () => _showIntegerDialog(),
//                 child: new Text("Int Value: $_currentIntValue"),
//               ),
//               decimalNumberPicker,
//               ElevatedButton(
//                 onPressed: () => _showDoubleDialog(),
//                 child: new Text("Decimal Value: $_currentDoubleValue"),
//               ),
//             ],
//           ),
//         ));
//   }
//   Future _showIntegerDialog() async {
//     await showDialog<int>(
//       context: context,
//       builder: (BuildContext context) {
//         return new NumberPickerDialog.integer(
//           minValue: 0,
//           maxValue: 100,
//           step: 10,
//           initialIntegerValue: _currentIntValue,
//           title: new Text("Pick a int value"),
//         );
//       },
//     ).then(_handleValueChangedExternally);
//   }
//   Future _showDoubleDialog() async {
//     await showDialog<double>(
//       context: context,
//       builder: (BuildContext context) {
//         return new NumberPickerDialog.decimal(
//           minValue: 1,
//           maxValue: 5,
//           decimalPlaces: 2,
//           initialDoubleValue: _currentDoubleValue,
//           title: new Text("Pick a decimal value"),
//         );
//       },
//     ).then(_handleValueChangedExternally);
//   }
// }

// List<DropdownMenuItem> listStatusMenuItems = <DropdownMenuItem>[];
//
// StatusComboView _currentStatusComboView;
//
// _loadStatusCombo() {
//   Provider.of<Api>(context, listen: false)
//       .getYourClassViews()
//       .then((listView) {
//     setState(() {
//       listStatusMenuItems =
//           listView?.map<DropdownMenuItem<YourClassView>>((item) {
//             return DropdownMenuItem<StatusComboView>(
//                 value: item, child: Text(item.displayValue));
//           }).toList();
//     });
//   });
//
//   @override
//   void initState() {
//     super.initState();
//     _loadStatusCombo();
//   }
//
//   DropdownButtonFormField<YourClassView>(
//       decoration: InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: const BorderRadius.all(
//               const Radius.circular(5.0),
//             ),
//           ),
//           filled: true,
//           hintStyle:
//           TextStyle(color: Colors.grey[800]),
//           hintText: "Select a Value",
//           fillColor: Colors.orange),
//       items: listStatusMenuItems,
//       isDense: true,
//       isExpanded: true,
//       value: this._currentStatusComboView,
//       validator: (value) =>
//       value == null ? 'field required' : null,
//       onChanged: (StatusComboView value) {
//         setState(() {
//           this._currentStatusComboView = value;
//         });
//       }),