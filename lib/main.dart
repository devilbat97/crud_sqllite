import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

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
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List data = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<Database> init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, "latihan.db");

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

  Future<void> getData() async {
    final db = await init();
    data = await db.rawQuery('Select * from Memos');
    setState(() {});
  }

  Future<void> addData(String isi, String judul) async {
    final db = await init();
    await db.transaction((txn) async {
      int id2 = await txn.rawInsert(
          'INSERT INTO Memos(title,content) VALUES(?, ?)', [judul, isi]);
    });
    getData();
  }

  Future<void> updateData(String judul, String isi, String id) async {
    final db = await init();
    await db.rawUpdate('UPDATE Memos SET title = ?, content = ? WHERE id = ?',
        [judul, isi, int.parse(id)]);
    getData();
  }

  Future<void> deleteData(String id) async {
    final db = await init();
    await db.rawDelete('Delete from Memos where id= ?', [int.parse(id)]);
    getData();
  }

  void modalAdd(BuildContext context) {
    TextEditingController isi = new TextEditingController();
    TextEditingController judul = new TextEditingController();
    // set up the button
    Widget okButton = RaisedButton(
      onPressed: () {
        addData(isi.text, judul.text).then((ca) {
          Navigator.pop(context);
        });
      },
      child: new Text("Submit"),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Add"),
      content: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Column(children: [
            TextField(
              controller: judul,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(), hintText: 'Judul'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            TextField(
              controller: isi,
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

  void updateModal(
      BuildContext context, String id, String juduls, String isis) {
    // set up the button
    TextEditingController isi = new TextEditingController();
    TextEditingController judul = new TextEditingController();
    Widget okButton = RaisedButton(
      onPressed: () {
        updateData(judul.text, isi.text, id).then((value) {
          Navigator.pop(context);
        });
      },
      child: new Text("Submit"),
    );
    judul.text = juduls;
    isi.text = isis;

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Edit Memos Ke - $id"),
      content: Container(
          height: MediaQuery.of(context).size.height * 0.28,
          child: Column(children: [
            TextField(
              controller: judul,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(), hintText: 'Judul'),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            TextField(
              controller: isi,
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

  List<Widget> getViewList(BuildContext context) {
    List<Widget> temp = <Widget>[];
    //await getData();
    for (var i in data) {
      print(i['id'].toString());
      temp.add(
        Container(
          height: MediaQuery.of(context).size.height * 0.2,
          color: Colors.grey,
          child: Padding(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.05,
                top: MediaQuery.of(context).size.height * 0.02,
                right: MediaQuery.of(context).size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i['title'].toString()),
                Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
                Text(i['content'].toString()),
                Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.1),
                    child: Row(
                      children: [
                        RaisedButton(
                          onPressed: () {
                            updateModal(context, i['id'].toString(),
                                i['title'].toString(), i['content'].toString());
                          },
                          child: new Text("Update"),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.1),
                        RaisedButton(
                          onPressed: () {
                            deleteData(i['id'].toString());
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
      temp.add(SizedBox(height: 10));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView(
            padding: EdgeInsets.all(10), children: getViewList(context)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modalAdd(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
