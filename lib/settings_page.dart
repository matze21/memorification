import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int snotificationNr = 1;
int sstartTime = 6;
int sendTime = 22;

class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  _MyPage2State createState() => _MyPage2State();

  static int getNotificationNr() { return _MyPage2State().dropdownvalue;}
  static int getStartTime() { return _MyPage2State().startTime; }
  static int getEndTime() { return _MyPage2State().endTime; }
}

class _MyPage2State extends State<Page2> {
  // Initial Selected Value
  int dropdownvalue = 1;
  List<int> hours = [ 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];
  int startTime = 6;
  int endTime   = 22;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: new Table(
        columnWidths: {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(1),
        },
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
                value: snotificationNr,
                items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,15,16,17,18,19,20].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                    );
                  }).toList(),
                onChanged: (newVal) {
                  setState(() {
                    snotificationNr = newVal!;
                    });
                  }
                  )]
              )
            ]
          ),
          TableRow(
              children: [Column(
                children: [Text('Earliest notification you would like to receive'
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
                          value: sstartTime,
                          items: hours.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text((value).toString() + ':00'),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              sstartTime = (newVal!);
                            });
                          }
                      )]
                )
              ]
          ),
          TableRow(
              children: [Column(
                children: [Text('Latest notification you would like to receive'
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
                          value: sendTime,
                          items: hours.map((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text((value).toString() + ':00'),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              sendTime = newVal!;
                            });
                          }
                      )]
                )
              ]
          ),
          // TableRow(
          //   children: [
          //     Column(
          //       children: [
          //         ElevatedButton(
          //             onPressed: onPressed,
          //             child: Text('Test Notifications'))
          //       ],
          //     )
          //   ]
          // )
        ],
      ))
    );
  }
}