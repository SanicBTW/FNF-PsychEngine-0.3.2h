package hxs;

import hxs.ScriptHandler.ForeverModule;
import hxs.Events.EventNote;
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
                                pushEvent(songNotes, state.eventList, state);
                        }
                    }
                }
                if (eventCount > 0)
                    trace(eventCount);

            case 'event':
                var eventsList:Array<EventNote> = [];
                for (event in songData.events)
                {
                    pushEvent(event, eventsList, state);
                }
                return eventsList;
        }

        return unspawnNotes;
    }

    public static function pushEvent(eventShit:Array<Dynamic>, myEventList:Array<EventNote>, state:PlayState)
    {
        for (i in 0...eventShit[1].length)
        {
            var newEventNote:Array<Dynamic> = [eventShit[0], eventShit[1][i][0], eventShit[1][i][1], eventShit[1][i][2]];
            var subEvent:EventNote =
            {
                strumTime: newEventNote[0] + SaveData.get(NOTE_OFFSET),
                event: newEventNote[1],
                value1: newEventNote[2],
                value2: newEventNote[3]
            };

            if (Events.eventList.contains(subEvent.event))
            {
                var mySelectedEvent:String = Events.eventList[Events.eventList.indexOf(subEvent.event)];
                if (mySelectedEvent != null)
                {
                    var module:ForeverModule = Events.loadedModules.get(subEvent.event);
                    var delay:Float = 0;
                    if (module.exists("returnDelay"))
                        delay = module.get("returnDelay")();

                    subEvent.strumTime -= delay;

                    if (module.exists("initFunction"))
                        module.get("initFunction")(subEvent.value1, subEvent.value2);
                    
                    myEventList.push(subEvent);
                    state.eventPushed(subEvent);
                }
            }
        }
    }
}