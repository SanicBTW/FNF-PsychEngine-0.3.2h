# Psych Engine 0.3.2h

# What is this?

This is another fork of Psych Engine 0.3.2h that I made to add Android compatibility and more features (because I like 0.3.2h a lot and shit is easier to port to HTML5)

This was originally a base for mod ports but a youtube comment on one of my videos showing a gameplay of one of my ports asked for a build of the OG game with this engine so I decided to do it

# Features

- Android compatibility ([Using M.A.Jigsaw Android Controls](https://github.com/MAJigsaw77/FNF-Android-Porting) though it uses an old version lol)
- Base Psych Stuff
- Camera movement on note direction
- Accuracy based on ms (Coming from 0.5.2h)
- Multiple inputs (I don't know if this is a good idea)
- Low memory usage (Apparently)
- A bunch of options to customize the engine (Might add more)
- Some sick features from PE 0.5.2h
- A really cool screen to ask for permissions (Storage Access to add some cool shit)
- A new loading screen (For HTML5 users)
- New note splash texture

# Update changelog (1.0.1)

### i wrote it here because i will forger after some time :skull:

- Updated the game over screen
- - Snaps camera to bf (can be disabled)
- - Now shows the stage (can be disabled too)
- Fixed note splash offset (again)
- Hopefully fix the camera bug (fixes [issue 9](https://github.com/SanicBTW/FNF-PsychEngine-0.3.2h/issues/9) but gives back deprecation errors)
- Add mashing violations (from kade engine, this wasnt added before because i was dumb, now its back) - ONLY FOR KADE INPUT
- (code shit) Moved character groups to FlxSpriteGroup from FlxTypedGroup (coming from 0.5.2h)
- Slightly moved the Y coordinate from the FPS counter

# Ideas (1.0.1)

- maybe a rewrite on storage access 
- a screen to download songs maybe?
- Clean up the fucking preferences state (never)

# Special thanks

HTML5 Players - For testing latest changes

Dulce - For beta testing the Android version

# Issues

- Lime 8.0.0 seems to have issues with rendering sometimes (Some stuff like FlxText's might seem a little bit more pixelated )