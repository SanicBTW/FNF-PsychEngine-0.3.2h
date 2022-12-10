package hxs;

import hxs.StrumLine.ReceptorData;
import hxs.ScriptHandler.ForeverModule;
import flixel.FlxSprite;
import haxe.Json;

class Note extends FlxSprite
{
    public var strumTime:Float = 0;
	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var gfNote:Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;

	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
    public var noteSpeed(default, set):Float;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var ratingDisabled:Bool = false;

	public var noAnimation:Bool = false;
	public var distance:Float = 2000;

	public var hitsoundDisabled:Bool = false;
	public var isLiftNote:Bool = false;
	public var isPixel:Bool = false;

    public static var scriptCache:Map<String, ForeverModule> = [];
    public static var dataCache:Map<String, ReceptorData> = [];
    public var receptorData:ReceptorData;
    public var noteModule:ForeverModule;

    private function set_noteSpeed(value:Float):Float
    {
        if (noteSpeed != value)
        {
            noteSpeed = value;
            updateSustainScale();
        }
        return noteSpeed;
    }

	private function set_noteType(value:String):String
	{
		noteSplashTexture = PlayState.SONG.splashSkin;
		if (noteData > -1 && noteData < SaveData.get(ARROW_HSV).length)
		{
			colorSwap.hue = SaveData.getHSV(noteData, 0) / 360;
			colorSwap.saturation = SaveData.getHSV(noteData, 1) / 100;
			colorSwap.brightness = SaveData.getHSV(noteData, 2) / 100;
		}

		if (noteData > -1 && noteType != value)
		{
			switch(value)
			{
				case 'No Animation':
					noAnimation = true;
				case 'GF Sing':
					gfNote = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

    public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, ?isPixel:Bool = false)
    {
        super();

		if (prevNote == null)
			prevNote = this;

		y -= 2000;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		this.noteData = noteData;
		this.strumTime = strumTime;
		this.isPixel = isPixel;
		if (!inEditor)
			this.strumTime += SaveData.get(NOTE_OFFSET);

        if (noteData > -1)
        {
            colorSwap = new ColorSwap();
            shader = colorSwap.shader;
            loadNote(noteType);
        }
    }

    public function loadNote(noteType:String)
    {
        receptorData = returnNoteData(noteType);
        noteModule = returnNoteScript(noteType);

        noteModule.interp.variables.set('note', this);
        noteModule.interp.variables.set('getNoteDirection', getNoteDirection);
        noteModule.interp.variables.set('getNoteColor', getNoteColor);

        var genScript:String = isSustainNote ? 'generateSustain' : 'generateNote';
        if (noteModule.exists(genScript))
            noteModule.get(genScript)();

        antialiasing = receptorData.antialiasing;
        setGraphicSize(Std.int(frameWidth * receptorData.size));
        updateHitbox();
    }

    public function updateSustainScale()
    {
        if (isSustainNote)
		{
			alpha = 0.6;
			if (prevNote != null && prevNote.exists)
			{
				if (prevNote.isSustainNote)
				{
					prevNote.scale.y = (prevNote.width / prevNote.frameWidth) * ((Conductor.stepCrochet / 100) * (1.07 / prevNote.receptorData.size)) * noteSpeed;
					prevNote.updateHitbox();
					offsetX = prevNote.offsetX;
				}
				else
					offsetX = ((prevNote.width / 2) - (width / 2));
			}
		}
    }

    public static function returnNoteData(noteType:String):ReceptorData
	{
		if (!dataCache.exists(noteType))
		{
			trace('Getting Note $noteType NoteData');
			dataCache.set(noteType, cast Json.parse(Paths.getPreloadPath('notetypes/$noteType.json')));
		}
		return dataCache.get(noteType);
	}

    public static function returnNoteScript(noteType:String):ForeverModule
	{
		if (!scriptCache.exists(noteType))
		{
			trace('Getting Note $noteType Module');
			scriptCache.set(noteType, ScriptHandler.loadModule('notetypes/$noteType/$noteType', 'notetypes/$noteType/$noteType'));
		}
		return scriptCache.get(noteType);
	}

	function getNoteDirection()
		return receptorData.actions[noteData];

	function getNoteColor()
		return receptorData.colors[noteData];

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * earlyHitMult)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
					wasGoodHit = true;
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}