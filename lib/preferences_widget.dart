import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/hive_storage.dart';
import 'package:just_audio/just_audio.dart';

class PreferencesWidget extends StatefulWidget {
  const PreferencesWidget(
      {Key? key, required this.preferences, required this.callback})
      : super(key: key);

  final Box preferences;
  final dynamic callback;

  // These static variables are used with flutter tests
  static String keyTrailName = "Trail Name";

  @override
  State<PreferencesWidget> createState() => _PreferencesWidgetState();
}

class _PreferencesWidgetState extends State<PreferencesWidget> {
  static const double MINIMUM_BREATH = 5.0, MAXIMUM_BREATH = 150.0;
  late double _durationMinutes = 0.0,
      _durationSeconds = 0.0,
      _inhale0 = MINIMUM_BREATH,
      _inhale1 = 0.0,
      _inhale2 = 0.0,
      _exhale0 = MINIMUM_BREATH,
      _exhale1 = 0.0,
      _exhale2 = 0.0,
      _vibrateDurationD = 0.0,
      _vibrateBreathD = 0.0;
  late bool _durationTts = false, _breathTts = false;
  final TextEditingController _textEditingController = TextEditingController();

  late MaterialColor _primaryColor = COLORS_PRIMARY[0] as MaterialColor;
  late Color _backgroundColor = const Color(COLOR_BACKGROUND);

  late String _audio0 = AUDIO_NONE,
      _audio1 = AUDIO_NONE,
      _audio2 = AUDIO_NONE,
      _audio3 = AUDIO_NONE;
  late final AudioPlayer _player = AudioPlayer();

  @override
  initState() {
    debugPrint("$widget.initState");
    _init();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("$widget.dispose");
    _player.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // Create default preference
    if (widget.preferences.isEmpty) {
      await _createSavedPreferences(1);
    }
    Preference preference = widget.preferences.getAt(0);

    setState(() {
      Duration duration = Duration(seconds: preference.duration);
      _durationMinutes = duration.inMinutes.toDouble();
      _durationSeconds =
          (duration.inSeconds % Duration.secondsPerMinute).toDouble();
      _inhale0 =
          preference.inhale[0].toDouble() / Duration.millisecondsPerSecond * 10;
      _inhale1 =
          preference.inhale[1].toDouble() / Duration.millisecondsPerSecond * 10;
      _inhale2 =
          preference.inhale[2].toDouble() / Duration.millisecondsPerSecond * 10;
      _exhale0 =
          preference.exhale[0].toDouble() / Duration.millisecondsPerSecond * 10;
      _exhale1 =
          preference.exhale[1].toDouble() / Duration.millisecondsPerSecond * 10;
      _exhale2 =
          preference.exhale[2].toDouble() / Duration.millisecondsPerSecond * 10;
      _vibrateDurationD = preference.vibrateDuration.toDouble() / 10;
      _vibrateBreathD = preference.vibrateBreath.toDouble() / 10;
      _durationTts = preference.durationTts;
      _breathTts = preference.breathTts;
      _primaryColor = COLORS_PRIMARY[preference.colors[0]] as MaterialColor;
      _backgroundColor = Color(preference.colors[1]);
      _textEditingController.text = preference.name;
      _audio0 = preference.audio[0];
      _audio1 = preference.audio[1];
      _audio2 = preference.audio[2];
      _audio3 = preference.audio[3];
    });

    debugPrint("preferences (${widget.preferences.length}):");
    for (Preference p in widget.preferences.values) {
      debugPrint("$p");
    }
  }

  Future<void> _createSavedPreferences(int length) async {
    while (widget.preferences.length < length) {
      createDefaultPref(widget.preferences);
    }
  }

  Future<void> _savePreference(int index) async {
    if (widget.preferences.length <= index) {
      await _createSavedPreferences(index + 1);
    }
    Preference preference = widget.preferences.getAt(0);
    Preference p = widget.preferences.getAt(index);
    p.copy(preference);
    await p.save();

    debugPrint("saved preference $index in:");
    for (Preference p in widget.preferences.values) {
      debugPrint("$p");
    }
  }

  Future<void> _setPreference(int index) async {
    if (widget.preferences.length <= index) {
      await _createSavedPreferences(index);
    }
    Preference preference = widget.preferences.getAt(0);
    Preference p = widget.preferences.getAt(index);
    preference.copy(p);
    await preference.save();
    widget.callback();

    _setColors(index);

    debugPrint("set preference $index in:");
    for (Preference p in widget.preferences.values) {
      debugPrint("$p");
    }
  }

  Future<void> _setColors(int index) async {
    if (widget.preferences.length <= index) {
      await _createSavedPreferences(index);
    }
    Preference preference = widget.preferences.getAt(index);
    _primaryColor = COLORS_PRIMARY[preference.colors[0]] as MaterialColor;
    _backgroundColor = Color(preference.colors[1]);
    _changeTheme();

    debugPrint("_setColors: $_primaryColor, $_backgroundColor");
  }

  int _getColorPosition(List colors, MaterialColor color) {
    for (int i = 0; i < colors.length; i++) {
      if (colors[i] == color) {
        return i;
      }
    }
    return -1;
  }

  ElevatedButton _getPreferenceButton(context, int position) {
    String name = "${AppLocalizations.of(context)!.preference} $position";

    return ElevatedButton(
      key: Key(name),
      onLongPress: () {
        debugPrint("onLongPress $name");
        _savePreference(position);
      },
      onPressed: () {
        debugPrint("onPressed $name");
        if (widget.preferences.length <= position) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context)!.longPressSavePreference),
          ));
        } else {
          _setPreference(position);
          _init();
        }
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (widget.preferences.length <= position) {
              return Theme.of(context).disabledColor;
            }
            Preference preference = widget.preferences.getAt(position);
            return COLORS_PRIMARY[preference.colors[0]];
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          )),
      child: Text("$position", semanticsLabel: name),
    );
  }

  Future<void> _deleteAll() async {
    while (widget.preferences.length > 1) {
      debugPrint("deleting ${widget.preferences.length - 1}");
      await widget.preferences.deleteAt(widget.preferences.length - 1);
    }
    widget.callback();
    _init();
  }

  _getPresetOption(String text, Preference pref) {
    return SimpleDialogOption(
      onPressed: () {
        switch (pref.name) {
          case PHYS_SIGH_TEXT:
            {
              pref.name = AppLocalizations.of(context)!.physiologicalSigh;
            }
            break;
          case PRESET_478_TEXT:
            {
              pref.name = AppLocalizations.of(context)!.breathing478;
            }
            break;
          case BOX_TEXT:
            {
              pref.name = AppLocalizations.of(context)!.boxBreathing;
            }
            break;
          default:
            {
              pref.name = "";
            }
            break;
        }

        Preference preference = widget.preferences.getAt(0);
        preference.copy(pref);
        preference.save();
        widget.callback();
        _init();
        _setColors(0);
        Navigator.of(context).pop();
        debugPrint("$text preference set");
      },
      child: Text(
        text,
        textScaleFactor: 1.5,
      ),
    );
  }

  _showPresetDialog() {
    SimpleDialog dialog = SimpleDialog(
      title: Text(AppLocalizations.of(context)!.selectAPreset),
      children: <Widget>[
        _getPresetOption(
            AppLocalizations.of(context)!.breathing478, get478Pref()),
        _getPresetOption(
            AppLocalizations.of(context)!.boxBreathing, getBoxPref()),
        _getPresetOption(
            AppLocalizations.of(context)!.physiologicalSigh, getPhysSighPref()),
        _getPresetOption(AppLocalizations.of(context)!.def, getDefaultPref()),
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel,
              key: const Key(CANCEL_TEXT)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  void _changeTheme() {
    Get.changeTheme(
        ThemeData(primarySwatch: _primaryColor, canvasColor: _backgroundColor));
  }

  @override
  Widget build(BuildContext context) {
    Preference preference = widget.preferences.getAt(0);
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.preferences),
          actions: <Widget>[
            PopupMenuButton<String>(
              key: const Key("menu"),
              onSelected: (value) {
                switch (value) {
                  case RESET_ALL_TEXT:
                    showAlertDialog(
                        context,
                        AppLocalizations.of(context)!.resetAll,
                        AppLocalizations.of(context)!.resetAllPreferences, () {
                      _deleteAll();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.preferencesReset),
                      ));
                    });
                    debugPrint(RESET_ALL_TEXT);
                    break;
                  case PRESETS_TEXT:
                    _showPresetDialog();
                    debugPrint(PRESETS_TEXT);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  key: const Key(RESET_ALL_TEXT),
                  value: RESET_ALL_TEXT,
                  child: Text(AppLocalizations.of(context)!.resetAll),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  key: const Key(PRESETS_TEXT),
                  value: PRESETS_TEXT,
                  child: Text(AppLocalizations.of(context)!.presets),
                ),
              ],
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              // Trail Name
              Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextFormField(
                    key: Key(PreferencesWidget.keyTrailName),
                    controller: _textEditingController,
                    maxLength: 32,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: AppLocalizations.of(context)!.enterAName),
                    onChanged: (value) {
                      setState(() {
                        preference.name = value;
                        preference.save();
                        widget.callback();
                      });
                      debugPrint("$NAME_TEXT: ${preference.name}");
                    },
                  )),

              // Duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.duration,
                  ),
                  Text(
                      getDurationString(Duration(seconds: preference.duration)),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(DURATION_MINUTES_TEXT),
                        value: _durationMinutes,
                        min: 0,
                        max: 120,
                        divisions: 121,
                        onChanged: (double value) {
                          setState(() {
                            _durationMinutes = value;
                            preference.duration = Duration(
                                    minutes: _durationMinutes.toInt(),
                                    seconds: _durationSeconds.toInt())
                                .inSeconds
                                .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            preference.duration = Duration(
                                    minutes: _durationMinutes.toInt(),
                                    seconds: _durationSeconds.toInt())
                                .inSeconds
                                .toInt();
                            preference.save();
                            widget.callback();
                          });
                          debugPrint(
                              "$DURATION_SECONDS_TEXT: ${preference.duration}");
                        },
                      )),
                ],
              ),

              // Duration seconds
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(DURATION_SECONDS_TEXT),
                        value: _durationSeconds,
                        min: 0,
                        max: 59,
                        divisions: 60,
                        onChanged: (double value) {
                          setState(() {
                            _durationSeconds = value;
                            preference.duration = Duration(
                                    minutes: _durationMinutes.toInt(),
                                    seconds: _durationSeconds.toInt())
                                .inSeconds
                                .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            preference.duration = Duration(
                                    minutes: _durationMinutes.toInt(),
                                    seconds: _durationSeconds.toInt())
                                .inSeconds
                                .toInt();
                            preference.save();
                            widget.callback();
                          });
                          debugPrint(
                              "$DURATION_SECONDS_TEXT: ${preference.duration}");
                        },
                      )),
                ],
              ),

              // Duration vibrate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.durationVibrate,
                  ),
                  Text("${preference.vibrateDuration} ms",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(DURATION_VIBRATE_TEXT),
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

              // Duration TTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.durationTts,
                  ),
                  Switch(
                    key: const Key(DURATION_TTS_TEXT),
                    value: _durationTts,
                    onChanged: (value) {
                      setState(() {
                        _durationTts = value;
                        preference.durationTts = value;
                        preference.save();
                        debugPrint(
                            "$DURATION_TTS_TEXT: ${preference.durationTts}");
                      });
                    },
                  )
                ],
              ),

              const Divider(
                thickness: 3,
              ),
              const SizedBox(height: 50),

              // Inhale
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.inhale,
                  ),
                  Text(
                      "${preference.inhale[0].toDouble() / Duration.millisecondsPerSecond.toDouble()} s",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(INHALE_TEXT),
                        value: _inhale0,
                        min: MINIMUM_BREATH,
                        max: MAXIMUM_BREATH,
                        divisions:
                            MAXIMUM_BREATH.toInt() - MINIMUM_BREATH.toInt(),
                        onChanged: (double value) {
                          setState(() {
                            _inhale0 = value;
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.inhale[0] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.inhale[0] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                            preference.save();
                          });
                          debugPrint("$INHALE_TEXT: ${preference.inhale[0]}");
                        },
                      ))
                ],
              ),

              // Inhale hold
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.inhaleHold,
                  ),
                  Text(
                      "${preference.inhale[1].toDouble() / Duration.millisecondsPerSecond.toDouble()} s",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(INHALE_HOLD_TEXT),
                        value: _inhale1,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (double value) {
                          setState(() {
                            _inhale1 = value;
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.inhale[1] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.inhale[1] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                            preference.save();
                          });
                          debugPrint(
                              "$INHALE_HOLD_TEXT: ${preference.inhale[1]}");
                        },
                      ))
                ],
              ),

              // Inhale last
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.inhaleLast,
                  ),
                  Text(
                      "${preference.inhale[2].toDouble() / Duration.millisecondsPerSecond.toDouble()} s",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(INHALE_LAST_TEXT),
                        value: _inhale2,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (double value) {
                          setState(() {
                            _inhale2 = value;
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.inhale[2] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.inhale[2] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                            preference.save();
                          });
                          debugPrint(
                              "$INHALE_LAST_TEXT: ${preference.inhale[2]}");
                        },
                      ))
                ],
              ),

              // Inhale audio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.inhaleAudio,
                  ),
                  DropdownButton<String>(
                    key: const Key(INHALE_AUDIO_TEXT),
                    value: _audio0,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? value) {
                      setState(() {
                        _audio0 = value!;
                        preference.audio[0] = _audio0;
                        preference.save();
                      });
                      play(_player, _audio0);
                    },
                    items: <String>[
                      AUDIO_NONE,
                      AUDIO_TONE1,
                      AUDIO_TONE2,
                      AUDIO_TONE3,
                      AUDIO_TONE4,
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Inhale hold audio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.inhaleHoldAudio,
                  ),
                  DropdownButton<String>(
                    key: const Key(INHALE_HOLD_AUDIO_TEXT),
                    value: _audio2,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? value) {
                      setState(() {
                        _audio2 = value!;
                        preference.audio[2] = _audio2;
                        preference.save();
                      });
                      play(_player, _audio2);
                    },
                    items: <String>[
                      AUDIO_NONE,
                      AUDIO_TONE1,
                      AUDIO_TONE2,
                      AUDIO_TONE3,
                      AUDIO_TONE4,
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const Divider(
                thickness: 3,
              ),
              const SizedBox(height: 50),

              // Exhale
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.exhale,
                  ),
                  Text(
                      "${preference.exhale[0].toDouble() / Duration.millisecondsPerSecond.toDouble()} s",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(EXHALE_TEXT),
                        value: _exhale0,
                        min: MINIMUM_BREATH,
                        max: MAXIMUM_BREATH,
                        divisions:
                            MAXIMUM_BREATH.toInt() - MINIMUM_BREATH.toInt(),
                        onChanged: (double value) {
                          setState(() {
                            _exhale0 = value;
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.exhale[0] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.exhale[0] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                            preference.save();
                          });
                          debugPrint("$EXHALE_TEXT: ${preference.exhale[0]}");
                        },
                      ))
                ],
              ),

              // Exhale hold
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.exhaleHold,
                  ),
                  Text(
                      "${preference.exhale[1].toDouble() / Duration.millisecondsPerSecond.toDouble()} s",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(EXHALE_HOLD_TEXT),
                        value: _exhale1,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (double value) {
                          setState(() {
                            _exhale1 = value;
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.exhale[1] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.exhale[1] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                            preference.save();
                          });
                          debugPrint(
                              "$EXHALE_HOLD_TEXT: ${preference.exhale[1]}");
                        },
                      ))
                ],
              ),

              // Exhale last
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.exhaleLast,
                  ),
                  Text(
                      "${preference.exhale[2].toDouble() / Duration.millisecondsPerSecond.toDouble()} s",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(EXHALE_LAST_TEXT),
                        value: _exhale2,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (double value) {
                          setState(() {
                            _exhale2 = value;
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.exhale[2] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                          });
                        },
                        onChangeEnd: (double value) {
                          setState(() {
                            double tenthSeconds = (value.round().toInt()) / 10;
                            preference.exhale[2] =
                                (tenthSeconds * Duration.millisecondsPerSecond)
                                    .toInt();
                            preference.save();
                          });
                          debugPrint(
                              "$EXHALE_LAST_TEXT: ${preference.exhale[2]}");
                        },
                      ))
                ],
              ),

              // Exhale audio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.exhaleAudio,
                  ),
                  DropdownButton<String>(
                    key: const Key(EXHALE_AUDIO_TEXT),
                    value: _audio1,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? value) {
                      setState(() {
                        _audio1 = value!;
                        preference.audio[1] = _audio1;
                        preference.save();
                      });
                      play(_player, _audio1);
                    },
                    items: <String>[
                      AUDIO_NONE,
                      AUDIO_TONE1,
                      AUDIO_TONE2,
                      AUDIO_TONE3,
                      AUDIO_TONE4,
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Exhale hold audio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.exhaleHoldAudio,
                  ),
                  DropdownButton<String>(
                    key: const Key(EXHALE_HOLD_AUDIO_TEXT),
                    value: _audio3,
                    icon: const Icon(Icons.arrow_downward),
                    onChanged: (String? value) {
                      setState(() {
                        _audio3 = value!;
                        preference.audio[3] = _audio3;
                        preference.save();
                      });
                      play(_player, _audio3);
                    },
                    items: <String>[
                      AUDIO_NONE,
                      AUDIO_TONE1,
                      AUDIO_TONE2,
                      AUDIO_TONE3,
                      AUDIO_TONE4,
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const Divider(
                thickness: 3,
              ),
              const SizedBox(height: 50),

              // Breath vibrate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.breathVibrate,
                  ),
                  Text("${preference.vibrateBreath} ms",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Slider(
                        key: const Key(BREATH_VIBRATE_TEXT),
                        value: _vibrateBreathD,
                        min: 0,
                        max: 100,
                        divisions: 100,
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

              // Breath TTS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.breathTts,
                  ),
                  Switch(
                    key: const Key(BREATH_TTS_TEXT),
                    value: _breathTts,
                    onChanged: (value) {
                      setState(() {
                        _breathTts = value;
                        preference.breathTts = value;
                        preference.save();
                        debugPrint("$BREATH_TTS_TEXT: ${preference.breathTts}");
                      });
                    },
                  ),
                ],
              ),

              const Divider(
                thickness: 3,
              ),
              const SizedBox(height: 50),
              Visibility(
                visible: Get.isDarkMode,
                child: Text(
                  AppLocalizations.of(context)!.colorDisabled,
                ),
              ),
              const SizedBox(height: 20),

              // Primary Color
              Visibility(
                visible: !Get.isDarkMode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.primaryColor,
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: !Get.isDarkMode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialColorPicker(
                        key: const Key(COLOR_PRIMARY_TEXT),
                        colors: COLORS_PRIMARY,
                        allowShades: false,
                        onMainColorChange: (ColorSwatch? color) {
                          _primaryColor = color as MaterialColor;
                          _changeTheme();
                          preference.colors[0] =
                              _getColorPosition(COLORS_PRIMARY, color);
                          preference.save();
                          debugPrint("$COLOR_PRIMARY_TEXT: $color");
                        },
                        selectedColor: _primaryColor),
                  ],
                ),
              ),

              // Background Color
              Visibility(
                visible: !Get.isDarkMode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.backgroundColor,
                    ),
                  ],
                ),
              ),

              Visibility(
                visible: !Get.isDarkMode,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MaterialColorPicker(
                        key: const Key(COLOR_BACKGROUND_TEXT),
                        colors: COLORS_BACKGROUND,
                        onBack: () {
                          _changeTheme();
                        },
                        onColorChange: (Color color) {
                          _backgroundColor = color;
                          preference.colors[1] = color.value;
                          preference.save();
                          debugPrint("$COLOR_BACKGROUND_TEXT: $color");
                        },
                        selectedColor: _backgroundColor),
                  ],
                ),
              ),

              const Divider(
                thickness: 3,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Padding(padding: EdgeInsets.only(left: 20.0)),
            _getPreferenceButton(context, 1),
            _getPreferenceButton(context, 2),
            _getPreferenceButton(context, 3),
            _getPreferenceButton(context, 4),
            _getPreferenceButton(context, 5),
          ],
        ));
  }
}
