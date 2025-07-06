import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de'),
    Locale('it'),
    Locale('nl'),
    Locale('tr'),
  ];

  /// No description provided for @pressStart.
  ///
  /// In en, this message translates to:
  /// **'Press Start'**
  String get pressStart;

  /// No description provided for @inhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get inhale;

  /// No description provided for @exhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get exhale;

  /// No description provided for @hold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get hold;

  /// No description provided for @inhaleHold.
  ///
  /// In en, this message translates to:
  /// **'Inhale Hold'**
  String get inhaleHold;

  /// No description provided for @exhaleHold.
  ///
  /// In en, this message translates to:
  /// **'Exhale Hold'**
  String get exhaleHold;

  /// No description provided for @inhaleLast.
  ///
  /// In en, this message translates to:
  /// **'Inhale Last'**
  String get inhaleLast;

  /// No description provided for @exhaleLast.
  ///
  /// In en, this message translates to:
  /// **'Exhale Last'**
  String get exhaleLast;

  /// No description provided for @inhaleAudio.
  ///
  /// In en, this message translates to:
  /// **'Inhale Audio'**
  String get inhaleAudio;

  /// No description provided for @inhaleHoldAudio.
  ///
  /// In en, this message translates to:
  /// **'Inhale Hold Audio'**
  String get inhaleHoldAudio;

  /// No description provided for @exhaleAudio.
  ///
  /// In en, this message translates to:
  /// **'Exhale Audio'**
  String get exhaleAudio;

  /// No description provided for @exhaleHoldAudio.
  ///
  /// In en, this message translates to:
  /// **'Exhale Hold Audio'**
  String get exhaleHoldAudio;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @durationVibrate.
  ///
  /// In en, this message translates to:
  /// **'Duration Vibrate'**
  String get durationVibrate;

  /// No description provided for @durationTts.
  ///
  /// In en, this message translates to:
  /// **'Duration TTS'**
  String get durationTts;

  /// No description provided for @breathVibrate.
  ///
  /// In en, this message translates to:
  /// **'Breath Vibrate'**
  String get breathVibrate;

  /// No description provided for @breathTts.
  ///
  /// In en, this message translates to:
  /// **'Breath TTS'**
  String get breathTts;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @presets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presets;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @def.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get def;

  /// No description provided for @physiologicalSigh.
  ///
  /// In en, this message translates to:
  /// **'Physiological Sigh'**
  String get physiologicalSigh;

  /// No description provided for @breathing478.
  ///
  /// In en, this message translates to:
  /// **'4-7-8 Breathing'**
  String get breathing478;

  /// No description provided for @boxBreathing.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing'**
  String get boxBreathing;

  /// No description provided for @cont.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get cont;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get backgroundColor;

  /// No description provided for @longPressSavePreference.
  ///
  /// In en, this message translates to:
  /// **'Long press button to save preference'**
  String get longPressSavePreference;

  /// No description provided for @selectAPreset.
  ///
  /// In en, this message translates to:
  /// **'Select a preset'**
  String get selectAPreset;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @resetAllPreferences.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all preferences?'**
  String get resetAllPreferences;

  /// No description provided for @preferencesReset.
  ///
  /// In en, this message translates to:
  /// **'Preferences reset'**
  String get preferencesReset;

  /// No description provided for @enterAName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get enterAName;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @clearAllSessions.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all sessions?'**
  String get clearAllSessions;

  /// No description provided for @sessionsCleared.
  ///
  /// In en, this message translates to:
  /// **'Sessions cleared'**
  String get sessionsCleared;

  /// No description provided for @sessionsBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Sessions backed up'**
  String get sessionsBackedUp;

  /// No description provided for @sessionsRestored.
  ///
  /// In en, this message translates to:
  /// **'Sessions restored'**
  String get sessionsRestored;

  /// No description provided for @sessionsExportedTo.
  ///
  /// In en, this message translates to:
  /// **'Sessions exported to'**
  String get sessionsExportedTo;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @couldNotLaunch.
  ///
  /// In en, this message translates to:
  /// **'Could not launch url'**
  String get couldNotLaunch;

  /// No description provided for @openBrowser.
  ///
  /// In en, this message translates to:
  /// **'Please open a browser and go to'**
  String get openBrowser;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get reportIssue;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @breaths.
  ///
  /// In en, this message translates to:
  /// **'Breaths'**
  String get breaths;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @breath.
  ///
  /// In en, this message translates to:
  /// **'Breath'**
  String get breath;

  /// No description provided for @preference.
  ///
  /// In en, this message translates to:
  /// **'Preference'**
  String get preference;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @colorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Color is disabled in dark mode.'**
  String get colorDisabled;

  /// No description provided for @heartrate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartrate;

  /// No description provided for @noPreferences.
  ///
  /// In en, this message translates to:
  /// **'No Preferences'**
  String get noPreferences;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'it', 'nl', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
    case 'nl':
      return AppLocalizationsNl();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
