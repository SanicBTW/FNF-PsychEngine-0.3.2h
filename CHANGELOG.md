# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2_UNRELEASED-14] - 21-10-2022
### Added
- Local settings file
- Online Events
- Custom function to load raw inputs for songs
- Support for local songs events
- Support for characters coming from internal storage (REALLY BAD)
### Changed
- PocketBase API (moved from fnf_charts collection to funkin collection to add events)
- Some code on loading Internal Storage songs 
- Storage Access code
### Fixed
- Events system (Kinda?)

## [1.2_UNRELEASED-13] - 19-10-2022
### Added
- Avoid hitsound lag
- Local Storage settings file
### Changed
- Paths updated to 0.5.2h kind of code
### Removed
- 0.5.2h Prompt
- Storage Access and moved it to Paths

## [1.2_UNRELEASED-12] - 19-10-2022
### Added
- Null check on Note Skins
### Fixed
- Online songs request support for System targets
- Permissions prompt not sending you to Title State
- Ugh chart
- Stress cutscene
### Changed
- Moved from FLXAnimate to Flixel-TextureAtlas, see project.xml for tutorial

## [1.2_UNRELEASED-11] - 19-10-2022
### Fixed
- Not blocking inputs on song selection state

## [1.2_UNRELEASED-10] - 18-10-2022
### Added
- Some funky alpha fade in and out on cutscenes
- Miss camera displacements
- A hint on Freeplay text to show the key to open the online song selection screen
- Old event pushing system (Because I'm getting a bunch of errors for not checking > -1 on song generation bruh)
- A check to avoid breaking the accept event on the online song screen
### Changed
- Set Persistent Update to false when selecting a song on online (WHY IS IT NOT WORKING AAAAAA)

## [1.2_UNRELEASED-9] - 18-10-2022
### Added
- Online song selection screen (A lot of progress for HTML5, needs to be improved)
- A new prompt for permissions for fetching songs
- 0.5.2h Prompt (I don't know why, also it was kind of rewritten and better formatted)
- An "S" button for the Android pad (not tested)
- Background color changing on beat on Loading State (kinda buggy and laggy)
- A selector (indicator) on buttons in the Prompt
- Custom Loading State for the online song selection (to avoid having to modify some base code and breaking it I will just copy it and modify it)
### Changed
- Some prompt code (Void->Void to String->Void to return the prompt name)
- MusicBeatSubstate extends FlxSubState to FlxUISubState
- Set Fixed Timestep to false by default
### Fixed
- Not setting back the clear libraries array to default values to avoid cleaning up an already cleaned up library
- Not setting SONG to null when cleaning cache
### Removed
- Up and down button type on the Prompt

## [1.2_UNRELEASED-8] - 16-10-2022
### Added
- FlxAnimate (modified some of its code because it wasn't compiling) if you want it [here it is](https://hastebin.com/ubofamivam.php) - apparently it was because of the Haxe version, sorry :P
### Fixed
- Slightly fixed Stress Cutscene

## [1.2_UNRELEASED-7] - 15-10-2022
### Removed
- The Memory Management
### Changed
- Some code for library cleaning and loading screen

## [1.2_UNRELEASED-6] - 15-10-2022
### Changed
- Improved the Memory Management code

## [1.2_UNRELEASED-5] - 15-10-2022
### Added
- A class to manage memory (Just to manage cache, not anything too special)
### Changed
- The audio increase decimals
- How assets / libraries are loaded
- Progress bar scale on Loading State
### Removed
- The options left selector because it looks bad

## [1.2_UNRELEASED-4] - 15-10-2022
### Changed
- Moved to 0.5.2h Preferences
- Moved to 0.5.2h Keybinds code
### Removed
- Judgement counter

## [1.2_UNRELEASED-3] - 15-10-2022
### Added
- Judgement counter
- OSU! Mania Input simulation option
- Different ratings style

## [1.2_UNRELEASED-2] - 15-10-2022
### Fixed
- Camera positions on Week 7 cutscenes
- Null check on last section for camera follow
### Removed
- The cutscene for Stress as AnimateAtlas keeps giving errors

## [1.2_UNRELEASED-1] - 14-10-2022
### Added
- Week 7 with everything working (almost there)
- Some countdown tween that moves the sprite down
### Fixed
- Countdowns not displaying properly

## [1.1.?] - 14-10-2022
### Changed
- Moved back the Y pos of the FPS Counter
- Properly set Android controls visible when needed
- Remove health bonification when getting a "Sick!" or "Good" rating
- Remove the slight alpha increase on lift notes

## [1.1.0] - 13-10-2022
### Added
- Lift notes to simulate OSU! Mania input (Doesn't work on botplay, only for Kade input)
- Mashing violations (Only for Kade input)
- The possibility to change the FPS and Memory counters font
### Fixed
- Note splash offset
- https://github.com/SanicBTW/FNF-PsychEngine-0.3.2h/issues/9
### Changed
- The Y pos of the FPS Counter
- Game Over screen, camera snaps to boyfriend (can be disabled)
- Event handling updated to 0.5.2h

## [1.0.0] - 9-10-2022
### Added
- Everything