import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CounterPage(title: '選擇行員數'),
      debugShowCheckedModeBanner: false,
    );
  }
}

//counter page
class CounterPage extends StatefulWidget {
  const CounterPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<CounterPage> createState() => _CounterState();
}

class _CounterState extends State<CounterPage> {
  int _staff = 1;

  void _incrementStaff() {
    setState(() {
      _staff++;
    });
  }

  void _decrementStaff() {
    setState(() {
      if (_staff > 1) {
        _staff--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Expanded(flex: 5, child: SizedBox(height: 100.0)),
            Center(
              child: SizedBox(
                  width: 150.0,
                  child: Row(
                    children: [
                      GestureDetector(
                          child: const CircleAvatar(
                            child: Icon(Icons.remove),
                            backgroundColor: Colors.blue,
                          ),
                          onTap: () => _decrementStaff() //初始化
                          ),
                      SizedBox(
                        width: 70.0,
                        child: Center(child: Text('$_staff')),
                      ),
                      GestureDetector(
                          child: const CircleAvatar(
                            child: Icon(Icons.add),
                            backgroundColor: Colors.blue,
                          ),
                          onTap: () => _incrementStaff() //初始化
                          ),
                    ],
                  )),
            ),
            const Expanded(flex: 1, child: SizedBox(height: 20.0)),
            Expanded(
                flex: 2,
                child: Row(children: <Widget>[
                  const Expanded(flex: 1, child: SizedBox()),
                  Expanded(
                      flex: 6,
                      child: SizedBox(
                          width: 200.0,
                          height: 80.0,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BankCounter(staff: _staff)));
                              },
                              child: const Text(
                                '確定',
                                style: TextStyle(
                                  //fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              )))),
                  const Expanded(flex: 1, child: SizedBox()),
                ])),
            const Expanded(flex: 1, child: SizedBox(height: 20.0)),
          ],
        ),
      )),
    );
  }
}

//bank page
class BankCounter extends StatefulWidget {
  final int staff;
  const BankCounter({Key? key, required this.staff}) : super(key: key);
  @override
  State<BankCounter> createState() => _MyHomePage2State();
}

class _MyHomePage2State extends State<BankCounter> {
  int _waiting = 0; // 等待人數
  int _counter = 0; // 增加人數
  List waitingPeople = []; //等待序列
  List processPeople = []; //各櫃台處理名單
  int _nownumber = 0; //當前人員
  int _nowstaff = 0; //當前櫃檯
  List<List<String>> finishList = []; //各櫃台處理完畢名單

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.staff; i++) {
      processPeople.add('idle');
      finishList.add([]);
    }
  }

//抽號
  void _incrementNumber() async {
    setState(() {
      _waiting++;
      _counter++;
      waitingPeople.add(_counter);
    });
  }

//叫號 & 處理
  void _callNumber(int _staffId, int _seconds) async {
    if (_waiting != 0 && processPeople[_staffId] == 'idle') {
      setState(() {
        _nowstaff = _staffId + 1;
        _nownumber = waitingPeople[0];
        processPeople[_staffId] = _nownumber.toString();
        waitingPeople.removeAt(0);
        _waiting--;
      });
      Future.delayed(Duration(milliseconds: _seconds), () {
        _done(
          _staffId,
        );
      });
    }
  }

//下一位
  void _done(int _as) async {
    if (processPeople[_as] != 'idle') {
      setState(() {
        finishList[_as].add(processPeople[_as]);
        processPeople[_as] = 'idle';
      });
    }
  }

//rows
  List<DataRow> getNumberRows() {
    List<DataRow> rows = [];

    for (var a = 0; a < widget.staff; a++) {
      var staffId = a + 1;
      var rad = Random();
      int _second = 5000 + rad.nextInt(5000); //隨機處理時間 ５～１０ｓ
      Future.delayed(const Duration(milliseconds: 10), () {
        _callNumber(a, _second);
      });

      DataRow row = DataRow(
        cells: [
          DataCell(
            SizedBox(
              width: 100.0,
              child: Center(
                  child: Text(
                "櫃檯 " + staffId.toString(),
              )),
            ),
          ),
          DataCell(
            SizedBox(
              width: 100.0,
              child: Center(
                  child: Text(
                processPeople[a],
              )),
            ),
          ),
          DataCell(
            SizedBox(
              width: 700.0,
              child: Center(
                  child: Text(
                finishList[a]
                    .toString()
                    .replaceAll('[', '')
                    .replaceAll(']', '')
                    .replaceAll(',', '、'),
              )),
            ),
          ),
        ],
      );
      rows.add(row);
    }
    return rows;
  }

//data table
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Counter'),
      ),
      body: ListView(children: [
        const SizedBox(height: 10.0),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("等待人數 : $_waiting 人"),
          Text("  ->     " + _nownumber.toString() + "號     "),
          Text("請至 " + _nowstaff.toString() + "號櫃檯"),
        ]),
        const SizedBox(height: 50.0),
        // Center(
        //     child: Text("等待顧客 : " +
        //         waitingPeople
        //             .toString()
        //             .replaceAll('[', '')
        //             .replaceAll(']', '')
        //             .replaceAll(',', '、'))),
        // const SizedBox(height: 20.0),
        DataTable(
          dataRowHeight: 60.0,
          columnSpacing: 3.0,
          showCheckboxColumn: false,
          columns: const <DataColumn>[
            DataColumn(
              label: SizedBox(
                width: 100.0,
                child: Center(child: Text('櫃檯行員')),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 100.0,
                child: Center(child: Text('服務中')),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: 700.0,
                child: Center(child: Text('已服務完成')),
              ),
            ),
          ],
          rows: getNumberRows(),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: () => _incrementNumber(),
      ),
    );
  }
}
