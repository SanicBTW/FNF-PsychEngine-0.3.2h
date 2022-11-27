package;

import flixel.math.FlxMath;
import flixel.FlxG;
import Section.SwagSection;
import haxe.exceptions.NotImplementedException;
import Song.SwagSong;
import notes.Note;
import notes.NoteUtils as NU;

// totally not another thing stolen from forever 
class ChartLoader
{
    public static function generateChart(songData:SwagSong, isPixel:Bool, songSpeed:Float, typeOfChart:ChartTypes = FNF):Array<Note>
    {
        var unspawnNotes:Array<Note> = [];
        var noteData:Array<SwagSection> = [];

        noteData = songData.notes;
        switch(typeOfChart)
        {
            case FNF:
                for (section in noteData)
                {
                    for (songNotes in section.sectionNotes)
                    {
                        var daStrumTime:Float = songNotes[0] /* - SaveData.get(NOTE_OFFSET) apparently this is handled by note?*/;
                        var daNoteData:Int = Std.int(songNotes[1]); //what if no %4

                        var gottaHitNote:Bool = section.mustHitSection;

                        if (songNotes[1] > 3)
                            gottaHitNote = !section.mustHitSection;

                        var oldNote:Note;
                        if (unspawnNotes.length > 0)
                            oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
                        else
                            oldNote = null;

                        var swagNote:Note = NU.returnDefaultNote({texture: null, library: null, isPixel: isPixel}, {strumTime: daStrumTime, noteData: daNoteData, prevNote: null, sustainNote: false, inEditor: false});
                        swagNote.mustPress = gottaHitNote;
                        swagNote.sustainLength = songNotes[2];
                        swagNote.gfNote = (section.gfSection && (songNotes[1] < 4));
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

                                var sustainNote:Note = NU.returnDefaultNote({texture: null, library: null, isPixel: isPixel}, {strumTime: daStrumTime
                                    + (Conductor.stepCrochet * susNote)
                                    + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), noteData: daNoteData, prevNote: oldNote, sustainNote: true, inEditor: false});
                                
                                unspawnNotes.push(sustainNote);

                                if (sustainNote.mustPress)
                                    sustainNote.x += FlxG.width / 2;

                                if (SaveData.get(OSU_MANIA_SIMULATION) && susLength < susNote)
                                    sustainNote.isLiftNote = true;
                            }
                        }

                        if (swagNote.mustPress)
                            swagNote.x += FlxG.width / 2;
                    }
                }
            case OSU: // i deleted the beatmap converter lol
                throw new NotImplementedException();
        }

        return unspawnNotes;
    }
}

enum ChartTypes
{
    OSU;
    FNF;
}