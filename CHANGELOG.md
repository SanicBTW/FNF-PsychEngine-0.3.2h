# Changelog
All notable changes will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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