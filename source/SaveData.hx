package;

import flixel.FlxG;

class SaveData
{
    private static var settings:Map<Settings, Dynamic> = 
    [
        DOWN_SCROLL => false,
        MIDDLE_SCROLL => false,
        SHOW_FRAMERATE => true,
        FLASHING => true,
        ANTIALIASING => true,
        NOTESPLASHES => true,
        LOW_QUALITY => false,
        FPS => 60,
        CAMERA_ZOOMS => true,
        HIDE_HUD => false,
        NOTE_OFFSET => 0,
        ARROW_HSV => [[0, 0, 0], [0, 0, 0], [0, 0, 0]],
        GHOST_TAPPING => true,
        HIDE_TIME => false,

        SHOW_MEMORY => true,
        SCORE_ZOOM => true,
        CAMERA_MOVEMENT => true,
        ICON_BOPING => false,
        PAUSE_MUSIC => "Tea Time",
        MISS_VOL => 0.2,
        HITSOUND_VOL => 0,
        SCORE_TEXT_STYLE => "Engine",
        COMBO_OFFSET => [0, 0, 0, 0],
        INPUT_TYPE => "Kade 1.5.3",
        SMOOTH_CAMERA_ZOOMS => true,
        OPPONENT_NOTESPLASHES => true,
        RATING_OFFSET => 0,
        SICK_WINDOW => 45,
        GOOD_WINDOW => 90,
        BAD_WINDOW => 135,
        SHIT_WINDOW => 166,
        SAFE_FRAMES => 10,
        ALLOW_FILESYS => false,
        ANSWERED => false,
        FREESTYLE_BF => true,
        COMBO_STACKING => true,
        PAUSE_ON_FOCUS_LOST => true,
        SNAP_CAMERA_ON_GAMEOVER => true,
        COUNTERS_FONT => "Funkin",
        OSU_MANIA_SIMULATION => true,
        ALLOW_ONLINE => false,
        SMALL_RATING_SIZE => true,
        LEGACY_RATINGS_STYLE => "Classic",
        USE_CLASSIC_COMBOS => false,
        RATINGS_STYLE => "Default"
    ];

    public static function getSetting(value:Settings)
    {
    }

    public static function saveSettings()
    {

    }

    public static function loadSettings()
    {
        for(settingName => settingValue in settings)
        {
            var flxProp = Reflect.getProperty(FlxG.save.data, settingName);
            if (flxProp != null)
                settings[settingName] = Reflect.getProperty(FlxG.save.data, settingName);
            else
                settings[settingName] = settingValue;
        }
    }
}

// the reason im doing it like this is to make it compatible with flxg save?
// no reason to be in upper case btw lol
enum abstract Settings(String) to String
{
    // psych settings 0.3.2h
    var DOWN_SCROLL = "DownScroll";
    var MIDDLE_SCROLL = "MiddleScroll";
    var SHOW_FRAMERATE = "ShowFPS";
    var FLASHING = "FlashingLights";
    var ANTIALIASING = "Antialiasing";
    var NOTESPLASHES = "NoteSplashes";
    var LOW_QUALITY = "LowQuality";
    var FPS = "Framerate";
    // should add cursing/violence/.. but who cares lol
    var CAMERA_ZOOMS = "CameraZooms";
    var HIDE_HUD = "HideHUD";
    var NOTE_OFFSET = "NoteOffset";
    var ARROW_HSV = "ArrowHSV";
    var GHOST_TAPPING = "GhostTapping";
    var HIDE_TIME = "HideTime";

    // engine settings
    var SHOW_MEMORY = "ShowMemory";
    var SCORE_ZOOM = "ScoreZoom";
    var CAMERA_MOVEMENT = "CameraMovement";
    var ICON_BOPING = "IconBoping";
    var PAUSE_MUSIC = "PauseMusic";
    var MISS_VOL = "MissVolume";
    var HITSOUND_VOL = "HitsoundVolume";
    var SCORE_TEXT_STYLE = "ScoreTextStyle";
    var COMBO_OFFSET = "ComboOffset";
    var INPUT_TYPE = "InputType";
    var SMOOTH_CAMERA_ZOOMS = "SmoothCameraZooms";
    var OPPONENT_NOTESPLASHES = "OpponentNoteSplash";
    var RATING_OFFSET = "RatingOffset";
    var SICK_WINDOW = "SickWindow";
    var GOOD_WINDOW = "GoodWindow";
    var BAD_WINDOW = "BadWindow";
    var SHIT_WINDOW = "ShitWindow";
    // miss window???
    var SAFE_FRAMES = "SafeFrames";
    var ALLOW_FILESYS = "AllowFileSys";
    var ANSWERED = "AnsweredRequests";
    var FREESTYLE_BF = "FreestyleBF";
    var COMBO_STACKING = "ComboStacking";
    var PAUSE_ON_FOCUS_LOST = "PauseOnFocusLost";
    var SNAP_CAMERA_ON_GAMEOVER = "SnapCameraOnGameover";
    var COUNTERS_FONT = "CounterFont";
    var OSU_MANIA_SIMULATION = "OsuManiaSimulation";
    var ALLOW_ONLINE = "AllowOnlineFetching";
    var SMALL_RATING_SIZE = "SmallRatingSize";
    var LEGACY_RATINGS_STYLE = "LegacyRatingStyle";
    var USE_CLASSIC_COMBOS = "UseClassicStyles";
    var RATINGS_STYLE = "RatingsStyle";
}

//score zoom