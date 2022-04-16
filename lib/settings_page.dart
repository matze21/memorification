import 'package:flutter/material.dart';

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  _MyPage2State createState() => _MyPage2State();
}

class _MyPage2State extends State<Page2> {
  // Initial Selected Value
  int dropdownvalue = 1;

  // List of items in our dropdown menu
  var items = [1, 2, 3, 4, 5,6 ,7,8,9,10,11,12,13,14,15,16,17,18,19,20];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: new Table(
        children: [
          TableRow(
            children: [Column(
              children: [Text('How many notifications per day would you like to receive'
                , style: TextStyle(color: Colors.white, fontSize: 18)
              ),],
            ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              DropdownButton<int>(
                dropdownColor: Colors.black,
                style: TextStyle(color: Colors.white, fontSize: 18),
                hint: Text("Pick"),
                icon: const Icon(Icons.keyboard_arrow_down),
                value: dropdownvalue,
                items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                    );
                  }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    dropdownvalue = newVal!;
                    });
                  }
                  )]
              )
            ]
          )
        ],
      ))
    );
  }
}