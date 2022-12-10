package hxs;

import hxs.ScriptHandler.ForeverModule;
import hxs.Events.PlacedEvent;
import flixel.FlxG;
import flixel.math.FlxMath;
import Section.SwagSection;
import Song.SwagSong;
import notes.Note;

class ChartLoader
{
    public static function generateChart(songData:SwagSong, type:String = "Chart", state:PlayState, isPixel:Bool = false):Dynamic
    {
        var unspawnNotes:Array<Note> = [];
        var noteData:Array<SwagSection> = songData.notes;

        switch(type)
        {
            default:
                var eventCount:Int = 0;
                for (section in noteData)
                {
                    for (songNotes in section.sectionNotes)
                    {
                        switch(songNotes[1])
                        {
                            default:
                                var daStrumTime:Float = songNotes[0];
                                var daNoteData:Int = Std.int(songNotes[1]);
                                var gottaHitNote:Bool = section.mustHitSection;
                                
                                if (songNotes[1] > 3) //numb of keys
                                    gottaHitNote = !section.mustHitSection;

                                var oldNote:Note;
                                if (unspawnNotes.length > 0)
                                    oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
                                else
                                    oldNote = null;

                                var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, isPixel);
                                swagNote.mustPress = gottaHitNote;
                                swagNote.sustainLength = songNotes[2];
                                swagNote.gfNote = (section.gfSection && (songNotes[1] < 4)); //numb of keys?
                                // might change with forever note supp
                                swagNote.noteType = songNotes[3];
                                if (!Std.isOfType(songNotes[3], String))
                                    swagNote.noteType = ChartingState.noteTypeList[songNotes[3]];
                                swagNote.scrollFactor.set();

                                var susLength:Float = swagNote.sustainLength;
                                susLength = susLength / Conductor.stepCrochet;
                                unspawnNotes.push(swagNote);

                                var floorSus:Int = Math.floor(susLength);
                                if (floorSus > 0)
                                {
                                    for (susNote in 0...floorSus + 2)
                                    {
                                        oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
            
                                        var sustainNote:Note = new Note(daStrumTime
                                            + (Conductor.stepCrochet * susNote)
                                            + (Conductor.stepCrochet / FlxMath.roundDecimal(state.songSpeed, 2)), daNoteData,
                                            oldNote, true, false, isPixel);
                                        sustainNote.mustPress = gottaHitNote;
                                        sustainNote.gfNote = (section.gfSection && (songNotes[1] < 4));
                                        sustainNote.noteType = swagNote.noteType;
                                        sustainNote.scrollFactor.set();
            
                                        unspawnNotes.push(sustainNote);
            
                                        if (sustainNote.mustPress)
                                            sustainNote.x += FlxG.width / 2;
            
                                        if (SaveData.get(OSU_MANIA_SIMULATION) && susLength < susNote)
                                            sustainNote.isLiftNote = true;
                                    }
                                }

                                swagNote.mustPress = gottaHitNote;
                                
                                if (swagNote.mustPress)
                                    swagNote.x += FlxG.width / 2;
                            case -1:
                                pushEvent(songNotes, state.eventList);
                        }
                    }
                }
                if (eventCount > 0)
                    trace(eventCount);

            case 'event':
                var eventList:Array<PlacedEvent> = [];
                for (section in noteData)
                {
                    for (songNotes in section.sectionNotes)
                    {
                        pushEvent(songNotes, eventList);
                    }
                }
                return eventList;
        }

        return unspawnNotes;
    }

    // make compatible with psych events shit
    public static function pushEvent(note:Array<Dynamic>, myEventList:Array<PlacedEvent>)
    {
        var daStrumTime:Float = note[0] + SaveData.get(NOTE_OFFSET);
        if (Events.eventList.contains(note[2]))
        {
            var mySelectedEvent:String = Events.eventList[Events.eventList.indexOf(note[2])];
            if (mySelectedEvent != null)
            {
                var module:ForeverModule = Events.loadedModules.get(note[2]);
                var delay:Float = 0;
                if (module.exists("returnDelay"))
                    delay = module.get("returnDelay")();

                var myEvent:PlacedEvent =
                {
                    timestamp: daStrumTime + (delay * Conductor.stepCrochet),
                    params: [note[3], note[4]],
                    eventName: note[2]
                };

                if (module.exists("initFunction"))
                    module.get("initFunction")(myEvent.params);

                myEventList.push(myEvent);
            }
        }
    }
}