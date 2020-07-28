import 'dart:async';

import 'package:couchbase_lite/couchbase_lite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


//void main() => runApp(BeerSampleApp(AppMode.production));
void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {

  String dbName;
  String _documentCount = '0';
  String _documents = ' <Empty>';
  String firstDocAddedTime = '';
  String lastDocAddedTime = '';

//  String _displayString = 'Initializing';
  Database database;
  ListenerToken _listenerToken;
  ListenerToken _listenerToken2;
  Replicator replicator;
  @override
  void initState() {
    super.initState();
    runExample("db_chandika", "chandika", "password");

  }

  Future<String> runExample(_dbName, username, userpwd) async {
    try {
      dbName = _dbName;
      database = await Database.initWithName(dbName);
    } on PlatformException {
      return "Error initializing database";
    }

    // Note wss://10.0.2.2:4984/my-database is for the android simulator on your local machine's couchbase database
    // Create replicators to push and pull changes to and from the cloud.
//    ReplicatorConfiguration config = ReplicatorConfiguration(database, "ws://10.0.2.2:4984/scy");
    ReplicatorConfiguration config = ReplicatorConfiguration(database, "ws://192.168.8.101:4984/scy");
//    ReplicatorConfiguration config = ReplicatorConfiguration(database, "ws://10.16.32.115:4984/scy");
//    ReplicatorConfiguration(database, "ws://10.16.32.115:4984/scy");
    config.replicatorType = ReplicatorType.pushAndPull;
    config.continuous = true;

    // Add authentication.
    config.authenticator = BasicAuthenticator(username, userpwd);

    // Create replicator (make sure to add an instance or static variable named replicator)
    replicator = Replicator(config);

    // Listen to replicator change events.
    _listenerToken = replicator.addChangeListener((ReplicatorChange event) {
      if (event.status.error != null) {
        print("Error: " + event.status.error);
      }
      print("addChangeListener >>> " + event.status.activity.toString());
    });


    replicator.addConflictResolveListener((str) {
      print(">>>>>conflict in fluter "+str);
    });


    _listenerToken2 = replicator.addDocumentReplicationListener((DocumentReplication event) {

      print("doc length : " + event.documents.length.toString());
      print("addDocumentReplicationListener : " + event.toMap().toString());
      print("addDocumentReplicationListener >>> " + event.documents .toList().last .id + " time = " + DateTime.now().toIso8601String());
    });

    // Start replication.
    await replicator.start();

    return "Database and Replicator Started";
  }


  int counter = 2;
  Document doc;

  @override
  Widget build(BuildContext context) {
//    printRec();
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('Add  Document '),
                // ignore: missing_return
                onPressed: () {
                  try {
                    var mutableDoc = MutableDocument( id: "2", data: {"equip_num": 3333, "equip_init": "AM", "org": "AM", "screen": "LISTVIEW", "flag": "fmob"});
                    database.saveDocument(mutableDoc, concurrencyControl: ConcurrencyControl.failOnConflict).then((value) {
                      print("value>>" + value.toString());
                      return value;
                    }, onError: (err) {
                      print(">>>>>>ERRRO $err");
                    });
//                    print("result =" + result.toString());
                  } catch (err) {
                    print("*********Error saving document" + err.toString());
                  }
                },
              ),
              RaisedButton(
                child: Text('Update  Document'),
                // ignore: missing_return
                onPressed: () {
                  try {
//                    var mutableDoc = MutableDocument( id: "2", data: {"equip_num": 3333, "equip_init": "AM", "org": "AM", "screen": "LISTVIEW", "flag": "fmob"});
                    var mutableDoc = doc.toMutable();
                    mutableDoc.setValue("equip_num", "3333");
                    database.saveDocument(mutableDoc).then((value) {
                      print("value>>" + value.toString());
                      return value;
                    }, onError: (err) {
                      print(">>>>>>ERRRO $err");
                    });
//                    print("result =" + result.toString());
                  } catch (err) {
                    print("*********Error saving document" + err.toString());
                  }
                },
              ),
              RaisedButton(
                child: Text('Refresh Document Count'),
                // ignore: missing_return
                onPressed: () async {

                  ResultSet result;
                  // Create a query to fetch documents of type SDK.
                  var query = QueryBuilder.select([SelectResult.all().from("mydocs")
                  ]).from(dbName, as: "mydocs") ;
                  // Run the query.
                  try {
                    result = await query.execute();
                    result.elementAt(0).
                    print("Number of rows :: ${result .allResults() .length}");
//                    result.allResults().forEach((result) => print(result.toList().toString()));
                    doc = await database.document("doc05");
                    print(" doc05 >>>" + doc.toMap().toString());
                    print(" doc05 >>>" + doc.id);
                  } catch (err) {
                    print("**********Error Fetching document $err");
                  }
                },
              ),
            ],)
      ),
    );
  }

  @override
  void dispose() async {
    print("<<dispose()>>>");
    closeAll();
    super.dispose();
  }

  closeAll() async {
    await replicator?.removeChangeListener(_listenerToken);
    await replicator?.removeChangeListener(_listenerToken2);
    await replicator?.stop();
    await replicator?.dispose();
//    await database?.close();
  }

  void printRec() async {
    var query = QueryBuilder.select([SelectResult.all().from("mydocs")]).from(dbName, as: "mydocs");
    try {
      var result = await query.execute();
      print("Number of rows :: ${result
          .allResults()
          .length}");
      result.allResults().forEach((element) {
        print(element.toList().toString());
      }
      );
    } on PlatformException {
      print("Errpr PlatformException ");
    }
  }
}
