import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/hive_storage.dart';
import 'package:brethap/wear.dart';
import 'package:brethap/l10n/generated/app_localizations.dart';

class PreferencesWidget extends StatefulWidget {
  const PreferencesWidget({
    super.key,
    required this.preferences,
    required this.customSounds,
    required this.callback,
  });

  final Box preferences;
  final Box customSounds;
  final dynamic callback;

  // These static variables are used with flutter tests
  static int maxDurationMinutes = 120,
      maxDurationSeconds = 59,
      maxVibration = 100,
      minBreath = 5,
      maxInhale = 150,
      maxExhale = 300,
      maxHold = 100;
  static String keyMenu = "Menu",
      keyPreference = "Preference",
      keyPreferenceName = "Preference Name",
      keyDrag = "Drag";

  @override
  State<PreferencesWidget> createState() => _PreferencesWidgetState();
}

class _PreferencesWidgetState extends State<PreferencesWidget> {
  late double _durationMinutes = 0.0,
      _durationSeconds = 0.0,
      _inhale0 = PreferencesWidget.minBreath.toDouble(),
      _inhale1 = 0.0,
      _inhale2 = 0.0,
      _exhale0 = PreferencesWidget.minBreath.toDouble(),
      _exhale1 = 0.0,
      _exhale2 = 0.0,
      _vibrateDurationD = 0.0,
      _vibrateBreathD = 0.0;
  late bool _durationTts = false, _breathTts = false;
  final TextEditingController _textEditingController = TextEditingController();

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
    widget.preferences.getAt(0).save();
    // Use a post-frame callback to avoid setState during disposal (locked tree)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.callback();
    });
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
      _durationSeconds = (duration.inSeconds % Duration.secondsPerMinute)
          .toDouble();
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

    debugPrint("set preference $index in:");
    for (Preference p in widget.preferences.values) {
      debugPrint("$p");
    }
  }

  Widget _getPreferenceButton(BuildContext context, int position) {
    String name = "${PreferencesWidget.keyPreference} $position";
    bool exists = widget.preferences.length > position;
    
    // Check if this is the currently active preference
    // Slot 0 is always the active one, so we compare its content with the saved slots
    Preference active = widget.preferences.getAt(0);
    bool isActive = false;
    if (exists) {
      Preference saved = widget.preferences.getAt(position);
      // Simple check to see if it's "active" by name or duration
      isActive = saved.name == active.name && saved.duration == active.duration;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              OutlinedButton(
                key: Key(name),
                onLongPress: () {
                  _savePreference(position);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text("Saved to Slot $position"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                onPressed: () {
                  if (!exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text("Long press to save current settings."),
                      ),
                    );
                  } else {
                    _setPreference(position);
                    _init();
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.zero,
                  backgroundColor: exists
                      ? COLORS_PRIMARY[(widget.preferences.getAt(position) as Preference).colors[0]].withValues(alpha: isActive ? 0.3 : 0.1)
                      : null,
                  side: BorderSide(
                    color: exists
                        ? COLORS_PRIMARY[(widget.preferences.getAt(position) as Preference).colors[0]]
                        : Theme.of(context).dividerColor,
                    width: isActive ? 2.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    "$position",
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (exists)
                const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 20,
          child: Text(
            exists ? (widget.preferences.getAt(position) as Preference).name.isEmpty ? "Slot $position" : (widget.preferences.getAt(position) as Preference).name : "Empty",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: exists ? null : Theme.of(context).disabledColor,
            ),
          ),
        ),
      ],
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

  SimpleDialogOption _getPresetOption(
    String key,
    String text,
    Preference pref,
  ) {
    return SimpleDialogOption(
      onPressed: () {
        switch (key) {
          case DEFAULT_TEXT:
            {
              pref.name = "";
            }
            break;
          default:
            {
              pref.name = text;
            }
            break;
        }

        Preference preference = widget.preferences.getAt(0);
        preference.copy(pref);
        preference.save();
        widget.callback();
        _init();
        Navigator.of(context).pop();
        debugPrint("$key preference set");
      },
      child: Text(
        text,
        key: Key(key),
        textScaler: const TextScaler.linear(1.5),
      ),
    );
  }

  void _showPresetDialog() {
    SimpleDialog dialog = SimpleDialog(
      title: Text(AppLocalizations.of(context).selectAPreset),
      children: <Widget>[
        _getPresetOption(
          PRESET_478_TEXT,
          AppLocalizations.of(context).breathing478,
          Preference.get478Pref(),
        ),
        _getPresetOption(
          BOX_TEXT,
          AppLocalizations.of(context).boxBreathing,
          Preference.getBoxPref(),
        ),
        _getPresetOption(
          PHYS_SIGH_TEXT,
          AppLocalizations.of(context).physiologicalSigh,
          Preference.getPhysSighPref(),
        ),
        _getPresetOption(
          DEFAULT_TEXT,
          AppLocalizations.of(context).def,
          Preference.getDefaultPref(),
        ),
        TextButton(
          child: Text(
            AppLocalizations.of(context).cancel,
            key: const Key(CANCEL_TEXT),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Preference preference = widget.preferences.getAt(0);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).preferences),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<String>(
            key: Key(PreferencesWidget.keyMenu),
            onSelected: (value) {
              switch (value) {
                case RESET_ALL_TEXT:
                  showAlertDialog(
                    context,
                    AppLocalizations.of(context).resetAll,
                    AppLocalizations.of(context).resetAllPreferences,
                    () {
                      _deleteAll();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context).preferencesReset,
                          ),
                        ),
                      );
                    },
                  );
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
                child: Text(AppLocalizations.of(context).resetAll),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                key: const Key(PRESETS_TEXT),
                value: PRESETS_TEXT,
                child: Text(AppLocalizations.of(context).presets),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        key: Key(PreferencesWidget.keyDrag),
        children: [
          _buildSectionHeader(AppLocalizations.of(context).general),
          _buildPreferenceCard(
            children: [
              TextFormField(
                key: Key(PreferencesWidget.keyPreferenceName),
                controller: _textEditingController,
                maxLength: 32,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).name,
                  hintText: AppLocalizations.of(context).enterAName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit_outlined),
                ),
                onChanged: (value) {
                  setState(() {
                    preference.name = value;
                  });
                },
                onEditingComplete: () {
                  preference.save();
                  widget.callback();
                },
              ),
            ],
          ),

          _buildSectionHeader(AppLocalizations.of(context).duration),
          _buildPreferenceCard(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Time"),
                  Text(
                    getDurationString(Duration(seconds: preference.duration)),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                key: const Key(DURATION_MINUTES_TEXT),
                value: _durationMinutes,
                min: 0,
                max: PreferencesWidget.maxDurationMinutes.toDouble(),
                divisions: PreferencesWidget.maxDurationMinutes + 1,
                label: "${_durationMinutes.toInt()}m",
                onChanged: (double value) {
                  setState(() {
                    _durationMinutes = value;
                    preference.duration = Duration(
                      minutes: _durationMinutes.toInt(),
                      seconds: _durationSeconds.toInt(),
                    ).inSeconds.toInt();
                  });
                },
                onChangeEnd: (double value) {
                  setState(() {
                    preference.save();
                    widget.callback();
                  });
                },
              ),
              Slider(
                key: const Key(DURATION_SECONDS_TEXT),
                value: _durationSeconds,
                min: 0,
                max: PreferencesWidget.maxDurationSeconds.toDouble(),
                divisions: PreferencesWidget.maxDurationSeconds + 1,
                label: "${_durationSeconds.toInt()}s",
                onChanged: (double value) {
                  setState(() {
                    _durationSeconds = value;
                    preference.duration = Duration(
                      minutes: _durationMinutes.toInt(),
                      seconds: _durationSeconds.toInt(),
                    ).inSeconds.toInt();
                  });
                },
                onChangeEnd: (double value) {
                  setState(() {
                    preference.save();
                    widget.callback();
                  });
                },
              ),
              const Divider(),
              SwitchListTile(
                key: const Key(DURATION_TTS_TEXT),
                contentPadding: EdgeInsets.zero,
                title: Text(AppLocalizations.of(context).durationTts),
                value: _durationTts,
                onChanged: (value) {
                  setState(() {
                    _durationTts = value;
                    preference.durationTts = value;
                    preference.save();
                  });
                },
              ),
              if (!isWeb()) ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).durationVibrate),
                    Text("${preference.vibrateDuration} ms"),
                  ],
                ),
                Slider(
                  key: const Key(DURATION_VIBRATE_TEXT),
                  value: _vibrateDurationD,
                  min: 0,
                  max: PreferencesWidget.maxVibration.toDouble(),
                  divisions: PreferencesWidget.maxVibration + 1,
                  onChanged: (double value) {
                    setState(() {
                      _vibrateDurationD = value;
                      preference.vibrateDuration = (value.round()).toInt() * 10;
                    });
                  },
                  onChangeEnd: (double value) {
                    setState(() {
                      preference.save();
                    });
                  },
                ),
              ],
            ],
          ),

          _buildSectionHeader(AppLocalizations.of(context).inhale),
          _buildPreferenceCard(
            children: [
              _buildBreathSlider(
                key: const Key(INHALE_TEXT),
                label: AppLocalizations.of(context).inhale,
                value: _inhale0,
                min: PreferencesWidget.minBreath.toDouble(),
                max: PreferencesWidget.maxInhale.toDouble(),
                onChanged: (val) => setState(() {
                  _inhale0 = val;
                  preference.inhale[0] = ((val.round() / 10) * 1000).toInt();
                }),
                onEnd: () => preference.save(),
                displayValue:
                    "${(preference.inhale[0] / 1000).toStringAsFixed(1)} s",
              ),
              _buildBreathSlider(
                key: const Key(INHALE_HOLD_TEXT),
                label: AppLocalizations.of(context).inhaleHold,
                value: _inhale1,
                min: 0,
                max: PreferencesWidget.maxHold.toDouble(),
                onChanged: (val) => setState(() {
                  _inhale1 = val;
                  preference.inhale[1] = ((val.round() / 10) * 1000).toInt();
                }),
                onEnd: () => preference.save(),
                displayValue:
                    "${(preference.inhale[1] / 1000).toStringAsFixed(1)} s",
              ),
              _buildBreathSlider(
                key: const Key(INHALE_LAST_TEXT),
                label: AppLocalizations.of(context).inhaleLast,
                value: _inhale2,
                min: 0,
                max: PreferencesWidget.maxHold.toDouble(),
                onChanged: (val) => setState(() {
                  _inhale2 = val;
                  preference.inhale[2] = ((val.round() / 10) * 1000).toInt();
                }),
                onEnd: () => preference.save(),
                displayValue:
                    "${(preference.inhale[2] / 1000).toStringAsFixed(1)} s",
              ),
              const Divider(),
              _buildAudioDropdown(
                key: const Key(INHALE_AUDIO_TEXT),
                label: AppLocalizations.of(context).inhaleAudio,
                value: _audio0,
                onChanged: (val) {
                  setState(() {
                    _audio0 = val!;
                    preference.audio[0] = _audio0;
                    preference.save();
                  });
                  play(_player, _audio0);
                },
              ),
              _buildAudioDropdown(
                key: const Key(INHALE_HOLD_AUDIO_TEXT),
                label: AppLocalizations.of(context).inhaleHoldAudio,
                value: _audio2,
                onChanged: (val) {
                  setState(() {
                    _audio2 = val!;
                    preference.audio[2] = _audio2;
                    preference.save();
                  });
                  play(_player, _audio2);
                },
              ),
            ],
          ),

          _buildSectionHeader(AppLocalizations.of(context).exhale),
          _buildPreferenceCard(
            children: [
              _buildBreathSlider(
                key: const Key(EXHALE_TEXT),
                label: AppLocalizations.of(context).exhale,
                value: _exhale0,
                min: PreferencesWidget.minBreath.toDouble(),
                max: PreferencesWidget.maxExhale.toDouble(),
                onChanged: (val) => setState(() {
                  _exhale0 = val;
                  preference.exhale[0] = ((val.round() / 10) * 1000).toInt();
                }),
                onEnd: () => preference.save(),
                displayValue:
                    "${(preference.exhale[0] / 1000).toStringAsFixed(1)} s",
              ),
              _buildBreathSlider(
                key: const Key(EXHALE_HOLD_TEXT),
                label: AppLocalizations.of(context).exhaleHold,
                value: _exhale1,
                min: 0,
                max: PreferencesWidget.maxHold.toDouble(),
                onChanged: (val) => setState(() {
                  _exhale1 = val;
                  preference.exhale[1] = ((val.round() / 10) * 1000).toInt();
                }),
                onEnd: () => preference.save(),
                displayValue:
                    "${(preference.exhale[1] / 1000).toStringAsFixed(1)} s",
              ),
              _buildBreathSlider(
                key: const Key(EXHALE_LAST_TEXT),
                label: AppLocalizations.of(context).exhaleLast,
                value: _exhale2,
                min: 0,
                max: PreferencesWidget.maxHold.toDouble(),
                onChanged: (val) => setState(() {
                  _exhale2 = val;
                  preference.exhale[2] = ((val.round() / 10) * 1000).toInt();
                }),
                onEnd: () => preference.save(),
                displayValue:
                    "${(preference.exhale[2] / 1000).toStringAsFixed(1)} s",
              ),
              const Divider(),
              _buildAudioDropdown(
                key: const Key(EXHALE_AUDIO_TEXT),
                label: AppLocalizations.of(context).exhaleAudio,
                value: _audio1,
                onChanged: (val) {
                  setState(() {
                    _audio1 = val!;
                    preference.audio[1] = _audio1;
                    preference.save();
                  });
                  play(_player, _audio1);
                },
              ),
              _buildAudioDropdown(
                key: const Key(EXHALE_HOLD_AUDIO_TEXT),
                label: AppLocalizations.of(context).exhaleHoldAudio,
                value: _audio3,
                onChanged: (val) {
                  setState(() {
                    _audio3 = val!;
                    preference.audio[3] = _audio3;
                    preference.save();
                  });
                  play(_player, _audio3);
                },
              ),
            ],
          ),

          _buildSectionHeader(AppLocalizations.of(context).feedback),
          _buildPreferenceCard(
            children: [
              if (!isWeb()) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context).breathVibrate),
                    Text("${preference.vibrateBreath} ms"),
                  ],
                ),
                Slider(
                  key: const Key(BREATH_VIBRATE_TEXT),
                  value: _vibrateBreathD,
                  min: 0,
                  max: PreferencesWidget.maxVibration.toDouble(),
                  divisions: PreferencesWidget.maxVibration + 1,
                  onChanged: (double value) {
                    setState(() {
                      _vibrateBreathD = value;
                      preference.vibrateBreath = (value.round()).toInt() * 10;
                    });
                  },
                  onChangeEnd: (double value) {
                    setState(() {
                      preference.save();
                    });
                  },
                ),
                const Divider(),
              ],
              SwitchListTile(
                key: const Key(BREATH_TTS_TEXT),
                contentPadding: EdgeInsets.zero,
                title: Text(AppLocalizations.of(context).breathTts),
                value: _breathTts,
                onChanged: (value) {
                  setState(() {
                    _breathTts = value;
                    preference.breathTts = value;
                    preference.save();
                  });
                },
              ),
            ],
          ),

          _buildSectionHeader(AppLocalizations.of(context).preference),
          _buildPreferenceCard(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Reduced to 4 for better fit
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.65, // Adjusted for label space
                ),
                itemCount: SAVED_PREFERENCES,
                itemBuilder: (context, index) {
                  return _getPreferenceButton(context, index + 1);
                },
              ),
              const SizedBox(height: 12),
              Text(
                "Tip: Long press a slot to save. Tap to load.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const Divider(height: 1),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showPresetDialog,
        label: Text(AppLocalizations.of(context).presets),
        icon: const Icon(Icons.auto_awesome),
      ),
    );
  }

  Widget _buildBreathSlider({
    Key? key,
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required VoidCallback onEnd,
    required String displayValue,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(displayValue, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          key: key,
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt() + 1,
          onChanged: onChanged,
          onChangeEnd: (_) => onEnd(),
        ),
      ],
    );
  }

  Widget _buildAudioDropdown({
    Key? key,
    required String label,
    required String value,
    required Function(String?) onChanged,
  }) {
    List<String> items = [
      AUDIO_NONE,
      AUDIO_TONE1,
      AUDIO_TONE2,
      AUDIO_TONE3,
      AUDIO_TONE4,
    ];
    
    // Add custom sounds
    for (var path in widget.customSounds.values) {
      items.add(path as String);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        DropdownButton<String>(
          key: key,
          value: items.contains(value) ? value : AUDIO_NONE,
          icon: const Icon(Icons.keyboard_arrow_down),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String val) {
            String displayName = val;
            if (val.contains('/')) {
              displayName = val.split('/').last;
            }
            return DropdownMenuItem<String>(
              value: val,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(displayName, overflow: TextOverflow.ellipsis),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
