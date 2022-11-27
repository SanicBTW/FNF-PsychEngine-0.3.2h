package notes; 

import flixel.FlxSprite;
import notes.NoteUtils as NU;
import PlayState;

using StringTools;

typedef EventNote = 
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

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
	public var lowPriority:Bool = false;

	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var ratingDisabled:Bool = false;
	/* what are these for
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; //9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick*/

	public var noAnimation:Bool = false;
	public var distance:Float = 2000;

	public var hitsoundDisabled:Bool = false;
	public var isLiftNote:Bool = false;

	// for textures
	public var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	public var originalHeightForCalcs:Float = 6;
	public var texture:String = ''; // dumb fix?

	private function set_multSpeed(value:Float):Float
	{
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		return value;
	}

	public function resizeByRatio(ratio:Float)
	{
		if (isSustainNote && !animation.curAnim.name.endsWith("end"))
		{
			scale.y *= ratio;
			updateHitbox();
		}
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

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false)
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
		if (!inEditor)
			this.strumTime += SaveData.get(NOTE_OFFSET);

		if (noteData > -1)
		{
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += NU.swagWidth * noteData;
			if (!isSustainNote)
				animation.play('${NU.getColorFromNum(noteData)}Scroll');
		}

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;
			multAlpha = 0.6;
			hitsoundDisabled = true;
			if (SaveData.get(DOWN_SCROLL))
				flipY = true;

			offsetX += width / 2;
			copyAngle = false;

			animation.play('${NU.getColorFromNum(noteData)}holdend');
			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				animation.play('${NU.getColorFromNum(noteData)}holdend');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				if (PlayState.instance != null)
					prevNote.scale.y *= PlayState.instance.songSpeed;

				if (PlayState.isPixelStage)
				{
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height);
				}

				prevNote.updateHitbox();
			}

			if (PlayState.isPixelStage)
			{
				scale.y *= NU.daPixelZoom;
				updateHitbox();
			}
		}
		else if (!isSustainNote)
			earlyHitMult = 1;
		x += offsetX;
	}

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
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
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

			if (strumTime <= Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
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