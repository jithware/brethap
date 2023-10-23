import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:brethap/utils.dart';
import 'package:brethap/hive_storage.dart';

class SessionsCalendarWidget extends StatefulWidget {
  const SessionsCalendarWidget({super.key, required this.sessions});
  final Box sessions;

  @override
  State<SessionsCalendarWidget> createState() => _SessionsCalendarWidgetState();
}

class _SessionsCalendarWidgetState extends State<SessionsCalendarWidget> {
  late final List<Session> _list;
  late final ValueNotifier<List<Session>> _selectedSessions;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime _firstDay, _lastDay, _statFirstDay, _statLastDay;

  void _init() {
    _list = widget.sessions.values.toList().cast<Session>();
    _lastDay = DateTime.now();
    _firstDay = _getFirstDate(_list);
    _selectedDay = _focusedDay;
    _statFirstDay =
        Jiffy.parseFromDateTime(_focusedDay).startOf(Unit.month).dateTime;
    _statLastDay = _focusedDay;
    _selectedSessions = ValueNotifier(_getSessionsForDay(_selectedDay!));
  }

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

  DateTime _getFirstDate(List<Session> list) {
    DateTime start = DateTime.now();
    if (list.isNotEmpty) {
      return list[0].start;
    }
    return start;
  }

  List<Session> _getSessionsForDay(DateTime day) {
    List<Session> sessions = <Session>[];
    for (var element in _list) {
      if (isSameDay(element.start, day)) {
        sessions.add(element);
      }
    }
    return sessions;
  }

  List<Session> _getSessionsForDateSpan(DateTime start, DateTime end) {
    List<Session> sessions = <Session>[];
    for (var item in _list) {
      if (item.start.millisecondsSinceEpoch >= start.millisecondsSinceEpoch &&
          item.end.millisecondsSinceEpoch <= end.millisecondsSinceEpoch) {
        sessions.add(item);
      }
    }

    return sessions;
  }

  void _updateStats() {
    if (_calendarFormat == CalendarFormat.month) {
      _statFirstDay =
          Jiffy.parseFromDateTime(_focusedDay).startOf(Unit.month).dateTime;
      _statLastDay =
          Jiffy.parseFromDateTime(_statFirstDay).add(months: 1).dateTime;
    } else if (_calendarFormat == CalendarFormat.week) {
      _statFirstDay =
          Jiffy.parseFromDateTime(_focusedDay).startOf(Unit.week).dateTime;
      _statLastDay =
          Jiffy.parseFromDateTime(_statFirstDay).add(weeks: 1).dateTime;
    }
    debugPrint(
        "focusedDay: $_focusedDay  statFirstDay: $_statFirstDay  statLastDay: $_statLastDay");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).calendar),
      ),
      body: Column(children: [
        TableCalendar<Session>(
          firstDay: _firstDay,
          lastDay: _lastDay,
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          eventLoader: _getSessionsForDay,
          availableCalendarFormats: {
            CalendarFormat.month: AppLocalizations.of(context).month,
            CalendarFormat.week: AppLocalizations.of(context).week,
          },
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedSessions.value = _getSessionsForDay(selectedDay);
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
                _selectedDay = null;
                _selectedSessions.value = [];
                _updateStats();
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
            _selectedDay = null;
            setState(() {
              _selectedSessions.value = [];
              _updateStats();
            });
          },
          calendarBuilders:
              CalendarBuilders(markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              DateTime dt = DateTime(date.year, date.month, date.day);
              Color color = Theme.of(context).primaryColor;
              if (dt.compareTo(_statFirstDay) < 0 ||
                  dt.compareTo(_statLastDay) >= 0) {
                color = Theme.of(context).disabledColor;
              }

              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                width: 16.0,
                height: 16.0,
                child: Center(
                  child: Text('${events.length}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 10.0)),
                ),
              );
            }
            return null;
          }),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Session>>(
            valueListenable: _selectedSessions,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  Session session = value[index];
                  return getSessionCard(context, session);
                },
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            String stats =
                getStats(context, _list, _statFirstDay, _statLastDay);
            String streak =
                getStreak(context, _list, _statFirstDay, _statLastDay);
            setState(() {
              _selectedDay = null;
              _selectedSessions.value =
                  _getSessionsForDateSpan(_statFirstDay, _statLastDay);
            });
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
