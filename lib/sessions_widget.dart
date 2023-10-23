import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:csv/csv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/hive_storage.dart';

class SessionsWidget extends StatefulWidget {
  const SessionsWidget({super.key, required this.sessions});
  final Box sessions;

  // These static variables are used with flutter tests
  static String keyMenu = "Menu";

  @override
  State<SessionsWidget> createState() => _SessionsWidgetState();
}

class _SessionsWidgetState extends State<SessionsWidget> {
  late final List<Session> _list;

  @override
  void initState() {
    debugPrint("$widget.initState");
    _init();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("$widget.dispose");
    super.dispose();
  }

  void _init() {
    _list = widget.sessions.values.toList().cast<Session>().reversed.toList();
  }

  DateTime _getFirstDate(List<Session> list) {
    DateTime start = DateTime.now();
    if (list.isNotEmpty) {
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
        ["start", "end", "breaths", "heartrate"]
      ];
      for (var element in list) {
        List<double>? heartrates = element.heartrates;
        heartrates ??= [0.0];
        rows.add(
            [element.start, element.end, element.breaths, heartrates.average]);
        added++;
      }
      String csv = const ListToCsvConverter().convert(rows);
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
      List<List<dynamic>> rows = const CsvToListConverter().convert(contents);

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
          session.heartrates = [row[3]];
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
        for (var element in _list) {
          await widget.sessions.add(element);
        }

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

  _showSnackBar(BuildContext context, String text, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: duration,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).sessions),
        actions: <Widget>[
          PopupMenuButton<String>(
            key: Key(SessionsWidget.keyMenu),
            onSelected: (value) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              switch (value) {
                case CLEAR_ALL_TEXT:
                  showAlertDialog(
                      context,
                      AppLocalizations.of(context).clearAll,
                      AppLocalizations.of(context).clearAllSessions, () {
                    _clearAll();
                    Navigator.of(context).pop();
                    _showSnackBar(
                        context,
                        AppLocalizations.of(context).sessionsCleared,
                        const Duration(seconds: 3));
                  });
                  debugPrint(CLEAR_ALL_TEXT);
                  break;
                case BACKUP_TEXT:
                  _exportCsv(_list).then((value) {
                    _showSnackBar(
                        context,
                        AppLocalizations.of(context).sessionsBackedUp,
                        const Duration(seconds: 3));
                  });
                  debugPrint(BACKUP_TEXT);
                  break;
                case RESTORE_TEXT:
                  _importCsv().then((value) {
                    _showSnackBar(
                        context,
                        AppLocalizations.of(context).sessionsRestored,
                        const Duration(seconds: 3));
                  });
                  debugPrint(RESTORE_TEXT);
                  break;
                case EXPORT_TEXT:
                  _exportCsv(_list).then((number) {
                    _getExportFile().then((file) {
                      _showSnackBar(
                          context,
                          "$number ${AppLocalizations.of(context).sessionsExportedTo}:\n${file.path}",
                          const Duration(seconds: 5));
                    });
                  });
                  debugPrint(EXPORT_TEXT);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                key: const Key(CLEAR_ALL_TEXT),
                value: CLEAR_ALL_TEXT,
                child: Text(AppLocalizations.of(context).clearAll),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                key: const Key(BACKUP_TEXT),
                value: BACKUP_TEXT,
                child: Text(AppLocalizations.of(context).backup),
              ),
              PopupMenuItem<String>(
                key: const Key(RESTORE_TEXT),
                value: RESTORE_TEXT,
                child: Text(AppLocalizations.of(context).restore),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                key: const Key(EXPORT_TEXT),
                value: EXPORT_TEXT,
                child: Text(AppLocalizations.of(context).export),
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
              child: getSessionCard(context, session));
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            DateTime firstDate = _getFirstDate(_list);
            String stats = getStats(context, _list, firstDate, DateTime.now());
            String streak =
                getStreak(context, _list, firstDate, DateTime.now());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$stats $streak", key: const Key("stats")),
              ),
            );
          },
          tooltip: AppLocalizations.of(context).statistics,
          child: const Icon(Icons.query_stats)),
    );
  }
}
