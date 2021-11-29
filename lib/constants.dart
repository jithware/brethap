const String JITHWARE_URL = "http://www.jithware.com",
    DONATE_URL =
        "https://www.paypal.com/donate/?hosted_button_id=2ZFSMQ8DGQVFS",
    BUGS_URL = "https://github.com/jithware/brethap/issues",
    HELP_URL = "https://github.com/jithware/brethap#readme",
    COPYRIGHT = "Copyright 2021 Jithware. All rights reserved.";

const String DATE_FORMAT = "yyyy-MM-dd h:mm a",
    PRESS_BUTTON_TEXT = "Press button to begin",
    INHALE_TEXT = "Inhale",
    EXHALE_TEXT = "Exhale",
    HOLD_TEXT = "Hold",
    INHALE_HOLD_TEXT = "Inhale Hold",
    EXHALE_HOLD_TEXT = "Exhale Hold",
    INHALE_LAST_TEXT = "Inhale Last",
    EXHALE_LAST_TEXT = "Exhale Last",
    DURATION_TEXT = "Duration",
    DURATION_MINUTES_TEXT = "Duration Minutes",
    DURATION_SECONDS_TEXT = "Duration Seconds",
    DURATION_VIBRATE_TEXT = "Duration Vibrate",
    DURATION_TTS_TEXT = "Duration TTS",
    BREATH_VIBRATE_TEXT = "Breath Vibrate",
    BREATH_TTS_TEXT = "Breath TTS",
    CLEAR_ALL_TEXT = "Clear All",
    RESET_ALL_TEXT = "Reset All",
    BACKUP_TEXT = "Backup",
    RESTORE_TEXT = "Restore",
    EXPORT_TEXT = "Export",
    PRESETS_TEXT = "Presets",
    DEFAULT_TEXT = "Default",
    PHYS_SIGH_TEXT = "Physiological Sigh",
    PRESET_478_TEXT = "4-7-8",
    BOX_TEXT = "Box",
    CONTINUE_TEXT = "Continue",
    CANCEL_TEXT = "Cancel",
    OK_TEXT = "Ok";

const int SAVED_PREFERENCES = 5;

// Default values
const int DURATION = 120, //seconds
    INHALE = 4000, //milliseconds
    INHALE_HOLD = 0, //milliseconds
    INHALE_LAST = 0, //milliseconds
    EXHALE = 4000, //milliseconds
    EXHALE_HOLD = 0, //milliseconds
    EXHALE_LAST = 0, //milliseconds
    VIBRATE_DURATION = 250, //milliseconds
    VIBRATE_BREATH = 25; //milliseconds
const bool DURATION_TTS = true, BREATH_TTS = true;

// Physiological sigh values
const int DURATION_PS = 15, //seconds
    INHALE_PS = 1000, //milliseconds
    INHALE_HOLD_PS = 500, //milliseconds
    INHALE_LAST_PS = 500, //milliseconds
    EXHALE_PS = 3000; //milliseconds

// 4-7-8 values
const int DURATION_478 = 76, //seconds
    INHALE_478 = 4000, //milliseconds
    INHALE_HOLD_478 = 7000, //milliseconds
    EXHALE_478 = 8000; //milliseconds

// Box values
const int DURATION_BOX = 60, //seconds
    INHALE_BOX = 4000, //milliseconds
    INHALE_HOLD_BOX = 4000, //milliseconds
    EXHALE_BOX = 4000, //milliseconds
    EXHALE_HOLD_BOX = 4000; //milliseconds