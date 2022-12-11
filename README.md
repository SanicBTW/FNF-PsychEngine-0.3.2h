# Psych Engine 0.3.2h - HXS-Forever Branch

## This branch focuses on porting "Forever Engine" WIP Rewrite Modding system to Psych Engine

- Q: Why not Lua? Lua is coming all the way from 0.3.2h probably and supports more mods from Psych
- A: Well I wanted to make this actually different from every other fork, maybe there is a fork about adding advanced hscript  support to the latest Psych version but I wanted to test out if I could port more Forever stuff into Psych
- Lua will be added as well but in future updates

- Currently works only on sys targets, seems to be that HTML5 has issues trying to run the same function twice

## Current Progress

- Module Code:
- - Works fine but I might need to change some stuff
- - Needs null check everywhere to avoid crashes
- - Paths need to access libraries

- Stage: (ON HOLD)
- - Works fine on all targets except HTML5, currently working on a fix
- - When the stage isn't found it won't crash
- - Extended usage (added Lullaby's code and mixed with default one)

- Notes:
- - This part will use Forever Engine implementation as it seems to be more softcoded

- Events:
- - Finished, needs to improve - Doesn't work on HTML5

- Lyrics: 
- - Why not, it will use Lullaby's implementation

# All credits go to Yoshubs and everyone who has worked on "Forever Engine" or "Forever Engine Legacy"