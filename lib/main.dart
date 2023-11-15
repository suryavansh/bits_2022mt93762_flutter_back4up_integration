import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final keyApplicationId = 'LcEKGsnyV1eI9U7c6UxBS5ZrZiCeDQIZMuGsI0ea';
  final keyClientKey = 'r4O2hUPl1JlCz4im7tcxPeUSS2dxtazW6UCQ4Tfk';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);

  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final taskController = TextEditingController();
  final statusController = TextEditingController();
  final ownerController = TextEditingController();
  String recordId = "";

  void validateAndSave() async {
    if (taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task Title can not be empty."),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (statusController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task Status can not be empty."),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (ownerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task Owner can not be empty."),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await saveTask(taskController.text, statusController.text, ownerController.text);
    setState(() {
      taskController.clear();
      statusController.clear();
      ownerController.clear();
    });
  }
  void displayFieldData (String id, String  task, String status, String owner) async {
    taskController.text = task;
    statusController.text = status;
    ownerController.text = owner;
    recordId = id;
  }
  void updateStatus () async {
    if (taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task Title can not be empty."),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (statusController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task Status can not be empty."),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    if (ownerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Task Owner can not be empty."),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    await updateTask(recordId,statusController.text);
    clearContents();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter-Back4App Integration"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 17.0, 17.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: taskController,
                      decoration: InputDecoration(
                          labelText: "Task Title",
                          labelStyle: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ],
              )),
          Container(
              padding: EdgeInsets.fromLTRB(17.0, 17.0, 17.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: statusController,
                      decoration: InputDecoration(
                          labelText: "Task Status",
                          labelStyle: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ],
              )),
              Container(
              padding: EdgeInsets.fromLTRB(17.0, 17.0, 17.0, 1.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: ownerController,
                      decoration: InputDecoration(
                          labelText: "Task Owner",
                          labelStyle: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ],
              )),
              Container(
              padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0.0),
              child: Row(children: <Widget>[
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(150, 40),
                    ),
                    onPressed: clearContents,
                    child: Text("Clear")),
                SizedBox(width: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(150, 40),
                    ),
                    onPressed: validateAndSave,
                    child: Text("Add Task")),
              ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      minimumSize: Size(150, 40),
                    ),
                    onPressed: updateStatus,
                    child: Text("Update Task")),
        ])),
          Expanded(
              child: FutureBuilder<List<ParseObject>>(
                  future: getTasks(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue),
                              )),
                        );
                      default:
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error..."),
                          );
                        }
                        if (!snapshot.hasData) {
                          return Center(
                            child: Text("No Data..."),
                          );
                        } else {
                          return ListView.builder(
                              padding: EdgeInsets.only(top: 10.0),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                //*************************************
                                //Get Parse Object Values
                                final varTask = snapshot.data![index];
                                final varTaskName = varTask.get<String>('Task')!;
                                final varTaskStatus = varTask.get<String>('TaskStatus')!;
                                final varTaskOwner = varTask.get<String>('TaskOwner')!;
                                final varIsDelayed = varTask.get<bool>('IsDelayed')!;
                                //*************************************

                                return ListTile(
                                  title: Text(varTaskName),
                                  leading: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4.0),
                                        bottomRight: Radius.circular(4.0),
                                        topLeft: Radius.circular(4.0),
                                        bottomLeft: Radius.circular(4.0)),
                                    ),
                                    padding:
                                      EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
                                    // color: Colors.Blue,
                                    child: Text(
                                          varTaskOwner,
                                          style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          ),
                                        ),                                    
                                    ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                          value: varIsDelayed,
                                          onChanged: (value) async {
                                            displayFieldData(
                                                varTask.objectId!, varTask.get<String>('Task')!, varTask.get<String>('TaskStatus')!, varTask.get<String>('TaskOwner')!);
                                            setState(() {
                                              //Refresh UI
                                            });
                                          }),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          await deleteTask(varTask.objectId!);
                                          setState(() {
                                            final snackBar = SnackBar(
                                              content: Text("Todo deleted!"),
                                              duration: Duration(seconds: 2),
                                            );
                                            ScaffoldMessenger.of(context)
                                              ..removeCurrentSnackBar()
                                              ..showSnackBar(snackBar);
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                );
                              });
                        }
                    }
                  }))
        ],
      ),
    );
  }

  void clearContents() {
    setState(() {
      taskController.clear();
      ownerController.clear();
      statusController.clear();
    });
  }
  Future<void> saveTask(String title, String status, String owner) async {
    final record = ParseObject('Task_Database')
    ..set('Task', title)
    ..set('TaskStatus', status)
    ..set('TaskOwner', owner);
    await record.save();
  }

  Future<List<ParseObject>> getTasks() async {
    QueryBuilder<ParseObject> queryTodo =
        QueryBuilder<ParseObject>(ParseObject('Task_Database'));
    final ParseResponse apiResponse = await queryTodo.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  Future<void> updateTask(String id, String status) async {
     var record = ParseObject('Task_Database')
      ..objectId = id
      ..set('TaskStatus', status);
    await record.save();
  }

  Future<void> deleteTask(String id) async {
    var record = ParseObject('Task_Database')..objectId = id;
    await record.delete();
  }

}