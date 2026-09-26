import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:watch_connectivity/watch_connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/constants.dart';
import 'package:brethap/preferences_widget.dart';
import 'package:brethap/sessions_widget.dart';
import 'package:brethap/hive_storage.dart';
import 'package:brethap/sessions_calendar_widget.dart';
import 'package:brethap/wear.dart';
import 'package:brethap/l10n/generated/app_localizations.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({
    super.key,
    required this.appName,
    required this.version,
    required this.preferences,
    required this.sessions,
    required this.customSounds,
  });

  final String appName, version;
  final Box preferences, sessions, customSounds;

  // These static variables are used with flutter tests
  static String keyPreferences = "Preferences",
      keySessions = "Sessions",
      keyCalendar = "Calendar",
      keyNoPreferences = "No Preferences",
      keyStatusText = "Status Text";
  static int totalSessions = 200;

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  bool _isRunning = false,
      _ringVisible = false,
      _hasVibrator = false,
      _hasCustomVibrate = false,
      _hasWakelock = false,
      _hasSpeak = false,
  // ignore: unused_field, prefer_final_fields
      _hasWear =
      false;
  late Duration _duration;
  late String _status, _preferenceName;
  late FlutterTts _tts;
  double _scale = 0.0;
  int _breaths = 0;
  late AudioPlayer _player;
  late WatchConnectivity _watch; // REMOVE FROM FDROID BUILD
  Timer? _timer;
  StreamSubscription? _watchSubscription;

  @override
  initState() {
    debugPrint("$widget.initState");
    _initVibrator();
    _initWakeLock();
    _initSpeak();
    _initAudio();
    _initWear();
    _init();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("$widget.dispose");
    _timer?.cancel();
    _watchSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  void _init() {
    if (kDebugMode && widget.sessions.isEmpty) {
      createRandomSessions(
        widget.sessions,
        HomeWidget.totalSessions,
        DateTime.now().subtract(const Duration(days: 180)),
        DateTime.now().subtract(const Duration(days: 1)),
      );
    }
    _status = "";
    if (widget.preferences.isEmpty) {
      createDefaultPref(widget.preferences);
    }

    _update();
  }

  Future<void> _initVibrator() async {
    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasCustomVibrate = await Vibration.hasCustomVibrationsSupport();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _initSpeak() async {
    try {
      _tts = FlutterTts();
      await _tts.awaitSpeakCompletion(false);
      _hasSpeak = true;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _initAudio() {
    AudioCache.instance = AudioCache(prefix: "audio/");
    _player = AudioPlayer();
  }

  Future<void> _initWakeLock() async {
    try {
      await WakelockPlus.enabled;
      _hasWakelock = true;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _initWear() async {
    // REMOVE FROM FDROID BUILD
    _hasWear = await isPhysicalPhone();

    if (_hasWear) {
      try {
        _watch = WatchConnectivity();
        _watchSubscription = _watch.messageStream.listen(
          (message) async {
            debugPrint('Received message: $message');

            Map<String, dynamic> response = {"received": true};

            // Send a preference
            int? index = message['preference'] as int?;
            if (index != null) {
              Preference preference;
              if (index < widget.preferences.length) {
                preference = widget.preferences.get(index);
              } else {
                preference = widget.preferences.get(0);
              }
              response = preference.toJson();
            }

            // Received a session
            if (Session.isSession(message)) {
              Session session = Session.fromJson(message);
              _addSession(session);
              _onDuration(session);
            }

            await _send(response);
          },
        );

        if (widget.preferences.isNotEmpty) {
          Preference preference = widget.preferences.get(0);
          await _send(preference.toJson());
        }
      } catch (e) {
        debugPrint("Wearable initialization failed: $e");
        _hasWear = false;
      }
    }
  }

  // REMOVE FROM FDROID BUILD
  Future<void> _send(dynamic message) async {
    if (_hasWear) {
      try {
        await _watch.sendMessage(message);
        debugPrint("Sent message: $message");
      } catch (e) {
        debugPrint("Error sending message to watch: $e");
      }
    }
  }

  Future _speak(String text) async {
    if (_hasSpeak) {
      await _tts.speak(text);
      debugPrint("spoke: $text");
    }
  }

  void _wakeLock(bool enable) {
    if (_hasWakelock) {
      WakelockPlus.toggle(enable: enable);
      debugPrint("wakelock: $enable");
    }
  }

  void _update() {
    Preference preference = widget.preferences.get(0);
    _duration = Duration(seconds: preference.duration);
    _preferenceName = preference.name.isEmpty ? APP_NAME : preference.name;
    debugPrint("session preference:$preference");
  }

  Future<void> _vibrate(int ms) async {
    if (_hasVibrator && ms > 0) {
      if (_hasCustomVibrate) {
        await Vibration.vibrate(duration: ms);
      } else {
        await Vibration.vibrate();
      }
      debugPrint("vibrated: $ms");
    }
  }

  Future<void> _onDuration(Session session) async {
    Preference preference = widget.preferences.get(0);

    _vibrate(preference.vibrateDuration);

    Duration diff = roundDuration(session.end.difference(session.start));
    String duration = getDurationString(diff);
    int breaths = session.breaths;
    String text = "$duration ${AppLocalizations.of(context).session}";
    if (breaths == 1) {
      text += ", $breaths ${AppLocalizations.of(context).breath}";
    } else {
      text += ", $breaths ${AppLocalizations.of(context).breaths}";
    }
    if (session.heartrates != null) {
      int average = session.heartrates!.average.toInt();
      if (average > 0) {
        text += ", $average ${AppLocalizations.of(context).heartrate}";
      }
    }

    if (preference.durationTts) {
      await _speak(text);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _onBreath(String text, [int cycles = 1]) async {
    Preference preference = widget.preferences.get(0);

    for (int i = 0; i < cycles; i++) {
      _vibrate(preference.vibrateBreath ~/ cycles);
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (preference.breathTts) {
      await _speak(text);
    }
  }

  Future<void> _onInhale() async {
    Preference preference = widget.preferences.get(0);

    await play(_player, preference.audio[0]);
  }

  Future<void> _onInhaleHold() async {
    Preference preference = widget.preferences.get(0);

    await play(_player, preference.audio[2]);
  }

  Future<void> _onExhale() async {
    Preference preference = widget.preferences.get(0);

    await play(_player, preference.audio[1]);
  }

  Future<void> _onExhaleHold() async {
    Preference preference = widget.preferences.get(0);

    await play(_player, preference.audio[3]);
  }

  void _addSession(Session session) {
    widget.sessions.add(session).then((value) {
      debugPrint("added session:$session");
    });
  }

  void _buttonPressed(dynamic context) {
    debugPrint("$widget._buttonPressed");

    if (_isRunning) {
      _isRunning = false;
    } else {
      Preference preference = widget.preferences.get(0);
      _update();
      _isRunning = true;
      Session session = Session(start: DateTime.now());
      _wakeLock(true);

      Duration timerSpan = const Duration(milliseconds: 100);
      int inhale =
          preference.inhale[0] + preference.inhale[1] + preference.inhale[2];
      int exhale =
          preference.exhale[0] + preference.exhale[1] + preference.exhale[2];
      int breath = inhale + exhale;
      int cycle = 0;
      double inhaleScale =
          timerSpan.inMilliseconds /
              (preference.inhale[0] + preference.inhale[2]);
      double exhaleScale =
          timerSpan.inMilliseconds /
              (preference.exhale[0] + preference.exhale[2]);
      bool inhaling = true, exhaling = false;

      _timer = Timer.periodic(timerSpan, (Timer timer) {
        if (!_isRunning || (_duration.inSeconds <= 0 && cycle <= 0)) {
          setState(() {
            _status = AppLocalizations.of(context).pressStart;
            _isRunning = false;
            session.end = DateTime.now();
            session.breaths = _breaths;
            if (_preferenceName != APP_NAME) {
              session.description = _preferenceName;
            }
            _addSession(session);
            _onDuration(session);
            _wakeLock(false);
            _duration = Duration(seconds: preference.duration);
            _scale = 0.0;
            _breaths = 0;
            timer.cancel();
          });
        } else {
          setState(() {
            String text;
            if (cycle == 0) {
              inhaling = true;
              exhaling = false;
              text = AppLocalizations.of(context).inhale;
              _scale = 0.0;
              _onBreath(text);
              _status = text;
              _onInhale();
            } else if (preference.inhale[1] > 0 &&
                cycle == preference.inhale[0]) {
              inhaling = false;
              exhaling = false;
              text = AppLocalizations.of(context).hold;
              _onBreath(text);
              _status = text;
              _onInhaleHold();
            } else if (preference.inhale[2] > 0 &&
                cycle == preference.inhale[0] + preference.inhale[1]) {
              inhaling = true;
              exhaling = false;
              text = AppLocalizations.of(context).inhale;
              _onBreath(text);
              _status = text;
            } else if (cycle == inhale) {
              inhaling = false;
              exhaling = true;
              text = AppLocalizations.of(context).exhale;
              _scale = 1.0;
              _onBreath(text, 2);
              _status = text;
              _onExhale();
            } else if (preference.exhale[1] > 0 &&
                cycle == inhale + preference.exhale[0]) {
              inhaling = false;
              exhaling = false;
              text = AppLocalizations.of(context).hold;
              _onBreath(text);
              _status = text;
              _onExhaleHold();
            } else if (preference.exhale[2] > 0 &&
                cycle == inhale + preference.exhale[0] + preference.exhale[1]) {
              inhaling = false;
              exhaling = true;
              text = AppLocalizations.of(context).exhale;
              _onBreath(text);
              _status = text;
            }

            cycle += timerSpan.inMilliseconds;
            if (cycle >= breath) {
              cycle = 0;
              _breaths++;
            }

            if (inhaling) {
              _scale += inhaleScale;
              if (_scale > 1.0) {
                _scale = 1.0;
              }
            } else if (exhaling) {
              _scale -= exhaleScale;
              if (_scale < 0.0) {
                _scale = 0.0;
              }
            }

            if (!_duration.isNegative) {
              _duration -= timerSpan;
            }
          });
        }
      });
    }
  }

  void _showWebDialog(String title, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).openBrowser),
              const SizedBox(height: 10),
              SelectionArea(child: Text(url)),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Callback for variables needed in HomeWidget when PreferenceWidget closes
  void _preferenceUpdated() {
    debugPrint("$widget.preferenceUpdated()");
    if (!mounted) return;
    Preference preference = widget.preferences.get(0);
    setState(() {
      _duration = Duration(seconds: preference.duration);
      _preferenceName = preference.name.isEmpty ? APP_NAME : preference.name;
    });
  }

  Widget _buildInfoCard(
      BuildContext context,
      IconData icon,
      String value,
      String label,
      ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (_status.isEmpty) {
      _status = AppLocalizations.of(context).pressStart;
    }

    // Breathing animation constants
    const double circleHeight = 150.0,
        circleWidth = 150.0,
        circlePadding = 8.0,
        ringWidth = 4.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_preferenceName),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          Visibility(
            visible: !_isRunning,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.bookmarks_outlined),
              itemBuilder: (BuildContext context) {
                int i = 0;
                List<PopupMenuItem<String>> menuItems = [];
                for (Preference p in widget.preferences.values) {
                  if (i > 0) {
                    String name =
                        "${AppLocalizations.of(context).preference} $i";
                    if (p.name.isNotEmpty) {
                      name = p.name;
                    }
                    menuItems.add(
                      PopupMenuItem(
                        key: Key(name),
                        child: Text(name),
                        onTap: () async {
                          Preference currentPreference = widget.preferences
                              .getAt(0);
                          currentPreference.copy(p);
                          await currentPreference.save();
                          _preferenceUpdated();
                        },
                      ),
                    );
                  }
                  i++;
                }
                if (menuItems.isEmpty) {
                  menuItems.add(
                    PopupMenuItem(
                      key: Key(HomeWidget.keyNoPreferences),
                      child: Text(AppLocalizations.of(context).noPreferences),
                    ),
                  );
                }
                return menuItems;
              },
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _ringVisible = !_ringVisible;
                      });
                    },
                    child: Text(
                      key: Key(HomeWidget.keyStatusText),
                      _status,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: circleWidth + (circlePadding * 2),
                      height: circleHeight + (circlePadding * 2),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          // Breathing animation outer ring (Feature Request #134)
                          Visibility(
                            visible: _ringVisible,
                            child: Container(
                              width: circleWidth,
                              height: circleHeight,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.15),
                                  width: ringWidth,
                                ),
                              ),
                            ),
                          ),

                          // Breathing animation circle
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: circleWidth * _scale,
                            height: circleHeight * _scale,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5 * _scale,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoCard(
                        context,
                        Icons.timer_outlined,
                        getDurationString(_duration),
                        AppLocalizations.of(context).duration,
                      ),
                      const SizedBox(width: 40),
                      _buildInfoCard(
                        context,
                        Icons.air_outlined,
                        _breaths.toString(),
                        AppLocalizations.of(context).breaths,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      drawer: NavigationDrawer(
        selectedIndex: -1,
        onDestinationSelected: (int index) async {
          Navigator.pop(context); // Close drawer
          if (index == 0) {
            _isRunning = false;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PreferencesWidget(
                  preferences: widget.preferences,
                  customSounds: widget.customSounds,
                  callback: _preferenceUpdated,
                ),
              ),
            );
          } else if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SessionsWidget(sessions: widget.sessions),
              ),
            );
          } else if (index == 2) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SessionsCalendarWidget(sessions: widget.sessions),
              ),
            );
          }
        },
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("images/launcher.png", height: 64),
                const SizedBox(height: 8),
                Text(
                  widget.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          NavigationDrawerDestination(
            key: Key(HomeWidget.keyPreferences),
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: Text(AppLocalizations.of(context).preferences),
          ),
          NavigationDrawerDestination(
            key: Key(HomeWidget.keySessions),
            icon: const Icon(Icons.format_list_numbered_outlined),
            selectedIcon: const Icon(Icons.format_list_numbered),
            label: Text(AppLocalizations.of(context).sessions),
          ),
          NavigationDrawerDestination(
            key: Key(HomeWidget.keyCalendar),
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: Text(AppLocalizations.of(context).calendar),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Text(
              AppLocalizations.of(context).appearance,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(COLORS_PRIMARY.length, (index) {
                Preference p = widget.preferences.getAt(0);
                bool isSelected = p.colors[0] == index;
                return GestureDetector(
                  onTap: () async {
                    Preference p = widget.preferences.getAt(0);
                    p.colors[0] = index;
                    await widget.preferences.putAt(0, p);
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: COLORS_PRIMARY[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: COLORS_PRIMARY[index].withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ] : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Text(
              AppLocalizations.of(context).customTones,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 28),
            leading: const Icon(Icons.library_music_outlined),
            title: Text(AppLocalizations.of(context).addCustomSound),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
              );

              if (result != null) {
                File file = File(result.files.single.path!);
                String fileName = result.files.single.name;

                // Save to app docs
                Directory appDocDir = await getApplicationDocumentsDirectory();
                String newPath = "${appDocDir.path}/$fileName";
                await file.copy(newPath);

                // Add to Hive if not exists
                if (!widget.customSounds.values.contains(newPath)) {
                  await widget.customSounds.add(newPath);
                  messenger.showSnackBar(
                    SnackBar(content: Text("Added $fileName to sounds")),
                  );
                }
              }
            },
          ),
          ValueListenableBuilder(
            valueListenable: widget.customSounds.listenable(),
            builder: (context, Box box, _) {
              if (box.isEmpty) return const SizedBox.shrink();
              return Column(
                children: box.values.map((path) {
                  String name = path.split('/').last;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                    dense: true,
                    leading: const Icon(Icons.music_note, size: 20),
                    title: Text(name, style: const TextStyle(fontSize: 13)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => box.deleteAt(box.values.toList().indexOf(path)),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Divider(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AboutListTile(
              icon: const Icon(Icons.info_outline),
              applicationIcon: Image.asset('images/animated.webp', height: 48),
              applicationName: widget.appName,
              applicationVersion: widget.version,
              applicationLegalese: COPYRIGHT,
              aboutBoxChildren: [
                ListTile(
                  title: Text(AppLocalizations.of(context).help),
                  leading: const Icon(Icons.help),
                  onTap: () {
                    _showWebDialog(AppLocalizations.of(context).help, HELP_URL);
                  },
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).reportIssue),
                  leading: const Icon(Icons.bug_report),
                  onTap: () {
                    _showWebDialog(
                      AppLocalizations.of(context).reportIssue,
                      BUGS_URL,
                    );
                  },
                ),
                Center(child: Image.asset('images/github-qr.png')),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          _buttonPressed(context);
        },
        tooltip: _isRunning
            ? AppLocalizations.of(context).stop
            : AppLocalizations.of(context).start,
        backgroundColor: _isRunning
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: _isRunning
            ? Theme.of(context).colorScheme.onErrorContainer
            : Theme.of(context).colorScheme.onPrimaryContainer,
        child: _isRunning
            ? const Icon(Icons.stop_rounded, size: 40)
            : const Icon(Icons.play_arrow_rounded, size: 40),
      ),
    );
  }
}
