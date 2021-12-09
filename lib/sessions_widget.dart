import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:csv/csv.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/hive_storage.dart';

class SessionsWidget extends StatefulWidget {
  const SessionsWidget({Key? key, required this.sessions}) : super(key: key);
  final Box sessions;

  @override
  _SessionsWidgetState createState() => _SessionsWidgetState();
}

class _SessionsWidgetState extends State<SessionsWidget> {
  late final List<Session> _list;

  @override
  void initState() {
    debugPrint("${this.widget}.initState");
    _init();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("${this.widget}.dispose");
    super.dispose();
  }

  void _init() {
    _list = widget.sessions.values.toList().cast<Session>().reversed.toList();
  }

  DateTime _getFirstDate(List<Session> list) {
    DateTime start = DateTime.now();
    if (list.length > 0) {
      return list[list.length - 1].start;
    }
    return start;
  }

  Future<void> _clearAll() async {
    if (_list.isNotEmpty) {
      setState(() {
        _list.clear();
      });
      await widget.sessions.clear();
    }
  }

  Future<File> _getExportFile() async {
    Directory? directory = await getStorageDir();
    File file = File("${directory?.path}/brethap.sessions.csv");
    file.exists().then((value) async {
      if (!value) {
        file
            .create(recursive: true)
            .then((value) => debugPrint("created: ${file.path}"));
      }
    });
    return file;
  }

  Future<int> _exportCsv(List<Session> list) async {
    int added = 0;
    try {
      List<List<dynamic>> rows = [
        ["start", "end", "breaths"]
      ];
      list.forEach((element) {
        added++;
        rows.add([element.start, element.end, element.breaths]);
      });
      String csv = ListToCsvConverter().convert(rows);
      final file = await _getExportFile();
      file.writeAsString(csv);
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
    return added;
  }

  Future<int> _importCsv() async {
    int added = 0;
    try {
      final file = await _getExportFile();
      final contents = await file.readAsString();
      List<List<dynamic>> rows = CsvToListConverter().convert(contents);

      // skip header at 0
      for (int i = 1; i < rows.length; i++) {
        var row = rows[i];
        DateTime start = DateTime.parse(row[0]);

        // check if session already exists
        bool exists = false;
        for (int j = 0; j < _list.length; j++) {
          if (_list[j].start.millisecondsSinceEpoch ==
              start.millisecondsSinceEpoch) {
            exists = true;
            break;
          }
        }
        if (!exists) {
          Session session = Session(start: start);
          session.end = DateTime.parse(row[1]);
          session.breaths = row[2];
          _list.add(session);
          await widget.sessions.add(session);
          added++;
          debugPrint("imported: $session");
        }
      }

      if (added > 0) {
        // sort the list ascending to add to sessions
        _list.sort((a, b) => a.start.millisecondsSinceEpoch
            .compareTo(b.start.millisecondsSinceEpoch));

        // clear sessions and add back
        await widget.sessions.clear();
        _list.forEach((element) async {
          await widget.sessions.add(element);
        });

        setState(() {
          // sort the list descending for ui
          _list.sort((a, b) => b.start.millisecondsSinceEpoch
              .compareTo(a.start.millisecondsSinceEpoch));
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
    return added;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sessions'),
        actions: <Widget>[
          PopupMenuButton<String>(
            key: Key("menu"),
            onSelected: (value) {
              switch (value) {
                case CLEAR_ALL_TEXT:
                  showAlertDialog(context, CLEAR_ALL_TEXT,
                      "Are you sure you want to clear all sessions?", () {
                    _clearAll();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Sessions cleared"),
                    ));
                  });
                  debugPrint(CLEAR_ALL_TEXT);
                  break;
                case BACKUP_TEXT:
                  _exportCsv(_list).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$value sessions backed up"),
                    ));
                  });
                  debugPrint(BACKUP_TEXT);
                  break;
                case RESTORE_TEXT:
                  _importCsv().then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$value sessions restored"),
                    ));
                  });
                  debugPrint(RESTORE_TEXT);
                  break;
                case EXPORT_TEXT:
                  _exportCsv(_list).then((number) {
                    _getExportFile().then((file) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text("$number sessions exported to:\n${file.path}"),
                        duration: Duration(seconds: 5),
                      ));
                    });
                  });
                  debugPrint(EXPORT_TEXT);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                key: Key(CLEAR_ALL_TEXT),
                value: CLEAR_ALL_TEXT,
                child: Text(CLEAR_ALL_TEXT),
              ),
              PopupMenuDivider(),
              PopupMenuItem<String>(
                key: Key(BACKUP_TEXT),
                value: BACKUP_TEXT,
                child: Text(BACKUP_TEXT),
              ),
              PopupMenuItem<String>(
                key: Key(RESTORE_TEXT),
                value: RESTORE_TEXT,
                child: Text(RESTORE_TEXT),
              ),
              PopupMenuDivider(),
              PopupMenuItem<String>(
                key: Key(EXPORT_TEXT),
                value: EXPORT_TEXT,
                child: Text(EXPORT_TEXT),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, index) {
          Session session = _list[index];
          return Dismissible(
              key: Key(session.key.toString()),
              onDismissed: (direction) {
                setState(() {
                  _list[index].delete(); // removes from sessions
                  _list.remove(session); // removes from list
                });
              },
              child: getSessionCard(session));
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            DateTime firstDate = _getFirstDate(_list);
            String stats = getStats(_list, firstDate, DateTime.now());
            String streak = getStreak(_list, firstDate, DateTime.now());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$stats $streak", key: Key("stats")),
              ),
            );
          },
          tooltip: 'Stats',
          child: Icon(Icons.query_stats)),
    );
  }
}
