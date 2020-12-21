import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter canerawidjet Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Flutter camerawidjet Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;

  Future getImage() async {
    final image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget imageSection = Container(
      child: _image == null //
          ? Text("push camera button") //
          : Image.file(_image), //
      width: size.width,
      height: size.height * 0.4,
    );

    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  child: Text(
                    'Recognition success',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
      final record = Record.fromSnapshot(data);
      return ListTile(
        title: Text(record.license_plate),
        trailing: Text(record.date_time.toDate().toString()),
        //onTap: () => record.reference.updateData({'votes': FieldValue.increment(1)})
      );
    }

    Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
      return ListView(
        scrollDirection: Axis.vertical,
        //padding: const EdgeInsets.all(600),
        children:
            snapshot.map((data) => _buildListItem(context, data)).toList(),
      );
    }

    Widget _buildBody(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('lpctext').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();

          return _buildList(context, snapshot.data.documents);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
          //bottom: false,
          child: Column(
        children: <Widget>[
          Container(
            height: 200.0,
            width: 300.0,
            child: imageSection,
          ),
          Container(
            height: 85.0,
            width: 300.0,
            child: titleSection,
          ),
          Container(
            height: 303.0,
            //width: 100.0,
            child: _buildBody(context),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Increment',
        child: Icon(Icons.camera_alt_rounded),
      ),
    );
  }
}

class Record {
  final String license_plate;
  final Timestamp date_time;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['license_plate'] != null),
        assert(map['date_time'] != null),
        license_plate = map['license_plate'],
        date_time = map['date_time'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$license_plate:$date_time>";
}
