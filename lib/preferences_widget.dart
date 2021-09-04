import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:csv/csv.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/hive_storage.dart';

class PreferencesWidget extends StatefulWidget {
  const PreferencesWidget(
      {Key? key, required this.preferences, required this.callback})
      : super(key: key);

  final Box preferences;
  final callback;

  @override
  _PreferencesWidgetState createState() => _PreferencesWidgetState();
}

class _PreferencesWidgetState extends State<PreferencesWidget> {
  late double _durationD = DURATION.toDouble() / Duration.secondsPerMinute,
      _breathD = BREATH.toDouble() / Duration.millisecondsPerSecond * 10,
      _vibrateDurationD = VIBRATE_DURATION.toDouble() / 10,
      _vibrateBreathD = VIBRATE_BREATH.toDouble() / 10;
  late bool _speakDuration = SPEAK_DURATION, _speakBreath = SPEAK_BREATH;

  @override
  initState() {
    debugPrint("${this.widget}.initState");
    _init();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("${this.widget}.dispose");
    super.dispose();
  }

  Future<void> _init() async {
    // Create default preference
    if (widget.preferences.isEmpty) {
      await _createSavedPreferences(1);
    }
    Preference preference = widget.preferences.get(0);

    setState(() {
      _durationD = preference.duration.toDouble() / Duration.secondsPerMinute;
      _breathD =
          preference.breath.toDouble() / Duration.millisecondsPerSecond * 10;
      _vibrateDurationD = preference.vibrateDuration.toDouble() / 10;
      _vibrateBreathD = preference.vibrateBreath.toDouble() / 10;
      _speakDuration = preference.speakDuration;
      _speakBreath = preference.speakBreath;
    });
  }

  Future<void> _createSavedPreferences(int length) async {
    while (widget.preferences.length <= length) {
      createDefaultPref(widget.preferences);
    }
  }

  Future<void> _savePreference(int index) async {
    if (widget.preferences.length <= index) {
      await _createSavedPreferences(index);
    }
    Preference preference = widget.preferences.get(0);
    Preference p = widget.preferences.getAt(index);
    p.copy(preference);
    await p.save();
    debugPrint("saved $index preference in: ${widget.preferences.values}");
  }

  Future<void> _setPreference(int index) async {
    if (widget.preferences.length <= index) {
      await _createSavedPreferences(index);
    }
    Preference preference = widget.preferences.get(0);
    Preference p = widget.preferences.getAt(index);
    preference.copy(p);
    await preference.save();
    widget.callback();
    debugPrint("set $index preferences in: ${widget.preferences.values}");
  }

  Future<void> _resetPreference(int index) async {
    if (widget.preferences.length <= index) {
      await _createSavedPreferences(index);
      return;
    }
    Preference preference = widget.preferences.getAt(index);
    preference.copy(getDefaultPref());
    await preference.save();
    debugPrint(
        "reset $index in preferences(${widget.preferences.length}): ${widget.preferences.values}");
  }

  ElevatedButton _getPreferenceButton(int position) {
    String name = "Preference $position";
    return ElevatedButton(
      child: Text("$position", semanticsLabel: name),
      key: Key(name),
      onLongPress: () {
        debugPrint("onLongPress $name");
        Feedback.forLongPress(context);
        _savePreference(position);
      },
      onPressed: () {
        debugPrint("onPressed $name");
        if (widget.preferences.length <= position) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Long press button to save preference'),
          ));
        }
        _setPreference(position);
        _init();
      },
      style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ))),
    );
  }

  Future<void> _resetAll() async {
    for (int index = 0; index < widget.preferences.length; index++) {
      _resetPreference(index);
    }
    widget.callback();
    _init();
  }

  Future<File> _getExportFile() async {
    Directory? directory = await getStorageDir();
    File file = File("${directory?.path}/brethap.preferences.csv");
    file.exists().then((value) async {
      if (!value) {
        file
            .create(recursive: true)
            .then((value) => debugPrint("created: ${file.path}"));
      }
    });
    return file;
  }

  Future<int> _exportCsv() async {
    int added = 0;
    List<Preference> list =
        widget.preferences.values.toList().cast<Preference>();
    try {
      List<List<dynamic>> rows = [
        [
          "duration",
          "breath",
          "vibrateDuration",
          "vibrateBreath",
          "speakDuration",
          "speakBreath"
        ]
      ];

      list.forEach((element) {
        added++;
        rows.add([
          element.duration,
          element.breath,
          element.vibrateDuration,
          element.vibrateBreath,
          element.speakDuration,
          element.speakBreath
        ]);
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
      _createSavedPreferences(SAVED_PREFERENCES);

      // skip header at 0
      for (int i = 1; i < rows.length && i <= SAVED_PREFERENCES + 1; i++) {
        var row = rows[i];
        Preference preference = widget.preferences.getAt(i - 1);
        Preference p = Preference(
            duration: row[0],
            breath: row[1],
            vibrateDuration: row[2],
            vibrateBreath: row[3],
            speakDuration: row[4].contains("true"),
            speakBreath: row[5].contains("true"));
        preference.copy(p);
        await preference.save();
        added++;
      }
      _init();
    } catch (e) {
      debugPrint(e.toString());
      return 0;
    }
    return added;
  }

  @override
  Widget build(BuildContext context) {
    Preference preference = widget.preferences.get(0);
    return Scaffold(
        appBar: AppBar(
          title: Text('Preferences'),
          actions: <Widget>[
            PopupMenuButton<String>(
              key: Key("menu"),
              onSelected: (value) {
                switch (value) {
                  case RESET_ALL_TEXT:
                    showAlertDialog(context, RESET_ALL_TEXT,
                        "Are you sure you want to reset all preferences?", () {
                      _resetAll();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Preferences reset"),
                      ));
                    });
                    debugPrint(RESET_ALL_TEXT);
                    break;
                  case BACKUP_TEXT:
                    _exportCsv().then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("$value preferences backed up"),
                      ));
                    });
                    debugPrint(BACKUP_TEXT);
                    break;
                  case RESTORE_TEXT:
                    _importCsv().then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("$value preferences restored"),
                      ));
                    });
                    debugPrint(RESTORE_TEXT);
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {RESET_ALL_TEXT, BACKUP_TEXT, RESTORE_TEXT}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    key: Key("$choice"),
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DURATION_TEXT,
                  ),
                  Text(
                      getDurationString(Duration(seconds: preference.duration)),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: Key(DURATION_TEXT),
                        value: _durationD,
                        min: 1,
                        max: 120,
                        divisions: 120,
                        onChanged: (double value) {
                          setState(() {
                            _durationD = value;
                            preference.duration =
                                (value.round() * Duration.secondsPerMinute)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            preference.duration =
                                (value.round() * Duration.secondsPerMinute)
                                    .toInt();
                            preference.save();
                            widget.callback();
                          });
                          debugPrint("$DURATION_TEXT: ${preference.duration}");
                        },
                      )),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DURATION_VIBRATE_TEXT,
                  ),
                  Text(preference.vibrateDuration.toString() + " ms",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: Key(DURATION_VIBRATE_TEXT),
                        value: _vibrateDurationD,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (double value) {
                          setState(() {
                            _vibrateDurationD = value;
                            preference.vibrateDuration =
                                (value.round()).toInt() * 10;
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            preference.vibrateDuration =
                                (value.round()).toInt() * 10;
                            preference.save();
                            debugPrint(
                                "$DURATION_VIBRATE_TEXT: ${preference.vibrateDuration}");
                          });
                        },
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DURATION_SPEAK_TEXT,
                  ),
                  Switch(
                    key: Key(DURATION_SPEAK_TEXT),
                    value: _speakDuration,
                    onChanged: (value) {
                      setState(() {
                        _speakDuration = value;
                        preference.speakDuration = value;
                        preference.save();
                        debugPrint(
                            "$DURATION_SPEAK_TEXT: ${preference.speakDuration}");
                      });
                    },
                  )
                ],
              ),
              Divider(
                thickness: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    BREATH_TEXT,
                  ),
                  Text(
                      (preference.breath.toDouble() /
                                  Duration.millisecondsPerSecond.toDouble())
                              .toString() +
                          " s",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: Key(BREATH_TEXT),
                        value: _breathD,
                        min: 2,
                        max: 202,
                        divisions: 100, //force breath even for equal half cycle
                        onChanged: (double value) {
                          setState(() {
                            _breathD = value;
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.breath =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.breath =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                            preference.save();
                          });

                          debugPrint("$BREATH_TEXT: ${preference.breath}");
                        },
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    BREATH_VIBRATE_TEXT,
                  ),
                  Text(preference.vibrateBreath.toString() + " ms",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: Key(BREATH_VIBRATE_TEXT),
                        value: _vibrateBreathD,
                        min: 0,
                        max: 50,
                        divisions: 50,
                        onChanged: (double value) {
                          setState(() {
                            _vibrateBreathD = value;
                            preference.vibrateBreath =
                                (value.round()).toInt() * 10;
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            preference.vibrateBreath =
                                (value.round()).toInt() * 10;
                            preference.save();
                            debugPrint(
                                "$BREATH_VIBRATE_TEXT: ${preference.vibrateBreath}");
                          });
                        },
                      ))
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    BREATH_SPEAK_TEXT,
                  ),
                  Switch(
                    key: Key(BREATH_SPEAK_TEXT),
                    value: _speakBreath,
                    onChanged: (value) {
                      setState(() {
                        _speakBreath = value;
                        preference.speakBreath = value;
                        preference.save();
                        debugPrint(
                            "$BREATH_SPEAK_TEXT: ${preference.speakBreath}");
                      });
                    },
                  ),
                ],
              ),
              Divider(
                thickness: 3,
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(padding: EdgeInsets.only(left: 20.0)),
            _getPreferenceButton(1),
            _getPreferenceButton(2),
            _getPreferenceButton(3),
            _getPreferenceButton(4),
            _getPreferenceButton(5),
          ],
        ));
  }
}
