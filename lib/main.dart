import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; //sqflite package
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'; //used to join paths
import 'dart:io';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var d = {'title': 'test1', 'context': 'isi test1'};
  bool isReady = false;
  List data = [];
  TextEditingController juduls = new TextEditingController();
  TextEditingController isis = new TextEditingController();

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
//returns a directory which stores permanent files
    final path = join(directory.path, "memos.db"); //create path to database

    return await openDatabase(
        //open the database or create a database if there isn't any
        path,
        version: 1, onCreate: (Database db, int version) async {
      await db.execute("""
          CREATE TABLE Memos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT)""");
    });
  }

  @override
  void initState() {
    //addItem(d);
    super.initState();
    getListItem();
  }

  Future<int> addItem() async {
    //returns number of items inserted as an integer
    isReady = false;
    setState(() {});
    final db = await init(); //open database

    // await db.transaction((txn) async {
    //   int id1 = await txn.rawInsert(
    //       'INSERT INTO Memos(title, content) VALUES("' +
    //           item['title'] +
    //           '", "' +
    //           item['context'] +
    //           '")');
    //   print('inserted1: $id1');
    // });
    for (int i = 0; i < 5; i++) {
      await db.transaction((txn) async {
        int id1 = await txn.rawInsert(
            'INSERT INTO Memos(title, content) VALUES("test$i", "ini isi test$i")');
        print('inserted1: $id1');
      });
    }
    getListItem();
  }

  Future<void> getListItem() async {
    final db = await init();
    data = await db.rawQuery('SELECT * FROM Memos');
    isReady = true;
    setState(() {});
  }

  Future<void> updateItem(String id, String isi, String judul) async {
    final db = await init();
    //data = await db.rawQuery('SELECT * FROM Memos');
    int c = await db.rawUpdate(
        'UPDATE Memos SET title = ?, content = ? WHERE id = ?',
        [judul, isi, int.parse(id)]);
    //setState(() {});
    //print(c);
    getListItem();
    //print(data);
  }

  Future<void> deleteItem(String id) async {
    final db = await init();
    int count =
        await db.rawDelete('DELETE FROM Memos WHERE id = ?', [int.parse(id)]);
    //setState(() {});
    getListItem();
    //print(count);
  }

  void showAlertDialog(
      BuildContext context, String id, String judul, String isi) {
    // set up the button
    Widget okButton = RaisedButton(
      onPressed: () {
        updateItem(id, isis.text, juduls.text).then((value) {
          Navigator.pop(context);
        });
      },
      child: new Text("Submit"),
    );
    juduls.text = judul;
    isis.text = isi;

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Edit Memos Ke - $id"),
      content: Container(
          height: MediaQuery.of(context).size.height * 0.25,
          child: Column(children: [
            TextField(
              controller: juduls,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(), hintText: 'Judul'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            TextField(
              controller: isis,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(), hintText: 'Content'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Divider(
              thickness: 5,
            )
          ])),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  List<Widget> getAllList(BuildContext context) {
    List c = <Widget>[];
    for (int i = 0; i < data.length; i++) {
      c.add(
        Container(
          height: MediaQuery.of(context).size.height * 0.16,
          color: Colors.grey,
          child: Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                top: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data[i]['title'].toString()),
                Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
                Text(data[i]['content'].toString()),
                Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1),
                    child: Row(
                      children: [
                        RaisedButton(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                data[i]['id'].toString(),
                                data[i]['title'].toString(),
                                data[i]['content'].toString());
                          },
                          child: new Text("Update"),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1),
                        RaisedButton(
                          onPressed: () {
                            deleteItem(data[i]['id'].toString());
                          },
                          child: new Text("Delete"),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
      );
      c.add(SizedBox(height: 10));
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: isReady == false
          ? new Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: ListView(
                  padding: EdgeInsets.all(10.0),
                  children: getAllList(context) //<Widget>[
                  // for (var i in data)
                  //   Container(
                  //     height: MediaQuery.of(context).size.height * 0.1,
                  //     color: Colors.grey,
                  //     child: Padding(
                  //       padding: EdgeInsets.only(
                  //           left: MediaQuery.of(context).size.width * 0.05,
                  //           top: MediaQuery.of(context).size.height * 0.02,
                  //           right: MediaQuery.of(context).size.width * 0.3),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(i['title'].toString()),
                  //           Divider(
                  //             color: Colors.white,
                  //             thickness: 2,
                  //           ),
                  //           Text(i['content'].toString()),
                  //           SizedBox(height: 10)
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // SizedBox(height: 10),
                  //],
                  ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
