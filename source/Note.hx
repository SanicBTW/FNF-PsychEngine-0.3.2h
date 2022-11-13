package;

import flixel.graphics.FlxGraphic;
import notes.UIStaticArrow;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

typedef EventNote =
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

// rewrite soon - goofiest external support
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

	private var earlyHitMult:Float = 0.5;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

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
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; // 9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var distance:Float = 2000;

	public var hitsoundDisabled:Bool = false;

	public var isLiftNote:Bool = false;

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

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String
	{
		noteSplashTexture = PlayState.SONG.splashSkin;
		// amount of keys ig
		colorSwap.hue = SaveData.getHSV(noteData % 4, 0) / 360;
		colorSwap.saturation = SaveData.getHSV(noteData % 4, 1) / 100;
		colorSwap.brightness = SaveData.getHSV(noteData % 4, 2) / 100;

		if (noteData > -1 && noteType != value)
		{
			switch (value)
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

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;

		y -= 2000;
		this.strumTime = strumTime;
		if (!inEditor)
			this.strumTime += SaveData.get(NOTE_OFFSET);

		this.noteData = noteData;

		if (noteData > -1)
		{
			texture = '';
			colorSwap = new ColorSwap();
			shader = colorSwap.shader;

			x += swagWidth * (noteData % 4);
			if (!isSustainNote)
				animation.play('${UIStaticArrow.getColorFromNum(noteData)}Scroll');
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

			animation.play('${UIStaticArrow.getColorFromNum(noteData)}holdend');

			updateHitbox();

			offsetX -= width / 2;

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play('${UIStaticArrow.getColorFromNum(noteData)}hold');

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
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		}
		else if (!isSustainNote)
			earlyHitMult = 1;
		x += offsetX;
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
	var lastNoteScaleToo:Float = 1;

	public var originalHeightForCalcs:Float = 6;

	// the fuck
	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
	{
		if (prefix == null)
			prefix = '';
		if (texture == null)
			texture = '';
		if (suffix == null)
			suffix = '';

		var skin:String = texture;
		if (texture.length < 1)
		{
			skin = PlayState.SONG.arrowSkin;
			if (skin == null || skin.length < 1)
			{
				skin = 'NOTE_assets';
			}
		}

		var lastScaleY:Float = scale.y;

		var animName:String = null;
		if (animation.curAnim != null)
		{
			animName = animation.curAnim.name;
		}

		var daCheck:Dynamic = nullCheck(skin);
		if (daCheck[0] != "ext")
		{
			skin = daCheck;
			var arraySkin:Array<String> = skin.split('/');
			arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;
	
			var blahblah:String = arraySkin.join('/');
			if (PlayState.isPixelStage)
			{
				if (isSustainNote)
				{
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
					width = width / 4;
					height = height / 2;
					originalHeightForCalcs = height;
					loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
				}
				else
				{
					loadGraphic(Paths.image('pixelUI/' + blahblah));
					width = width / 4;
					height = height / 5;
					loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
				}
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				loadPixelNoteAnims();
				antialiasing = false;
	
				if (isSustainNote)
				{
					offsetX += lastNoteOffsetXForPixelAutoAdjusting;
					lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
					offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
				}
			}
			else
			{
				frames = Paths.getSparrowAtlas(blahblah);
				loadNoteAnims();
				antialiasing = SaveData.get(ANTIALIASING);
			}
		}
		else
		{
			if (PlayState.isPixelStage)
			{
				if (isSustainNote)
				{
					loadGraphic(daCheck[1]);
					width = width / 4;
					height = height / 2;
					originalHeightForCalcs = height;
					loadGraphic(daCheck[1], true, Math.floor(width), Math.floor(height));
				}
				else
				{
					loadGraphic(daCheck[1]);
					width = width / 4;
					height = height / 5;
					loadGraphic(daCheck[1], true, Math.floor(width), Math.floor(height));
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				loadPixelNoteAnims();
				antialiasing = false;

				if (isSustainNote)
				{
					offsetX += lastNoteOffsetXForPixelAutoAdjusting;
					lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
					offsetX -= lastNoteOffsetXForPixelAutoAdjusting;
				}
			}
			else
			{
				frames = daCheck[2];
				loadNoteAnims();
				antialiasing = SaveData.get(ANTIALIASING);
			}
		}
		
		if (isSustainNote)
			scale.y = lastScaleY;
		updateHitbox();

		if (animName != null)
			animation.play(animName, true);

		if (inEditor)
		{
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims()
	{
		animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('purpleScroll', 'purple0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix('greenholdend', 'green hold end');
			animation.addByPrefix('redholdend', 'red hold end');
			animation.addByPrefix('blueholdend', 'blue hold end');

			animation.addByPrefix('purplehold', 'purple hold piece');
			animation.addByPrefix('greenhold', 'green hold piece');
			animation.addByPrefix('redhold', 'red hold piece');
			animation.addByPrefix('bluehold', 'blue hold piece');
		}

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
	}

	function loadPixelNoteAnims()
	{
		if (isSustainNote)
		{
			animation.add('purpleholdend', [PURP_NOTE + 4]);
			animation.add('greenholdend', [GREEN_NOTE + 4]);
			animation.add('redholdend', [RED_NOTE + 4]);
			animation.add('blueholdend', [BLUE_NOTE + 4]);

			animation.add('purplehold', [PURP_NOTE]);
			animation.add('greenhold', [GREEN_NOTE]);
			animation.add('redhold', [RED_NOTE]);
			animation.add('bluehold', [BLUE_NOTE]);
		}
		else
		{
			animation.add('greenScroll', [GREEN_NOTE + 4]);
			animation.add('redScroll', [RED_NOTE + 4]);
			animation.add('blueScroll', [BLUE_NOTE + 4]);
			animation.add('purpleScroll', [PURP_NOTE + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// copied from psych x kade
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

	function nullCheck(textureCheck:String):Dynamic
	{
		var skin = "NOTE_assets";

		#if STORAGE_ACCESS
		if (SaveData.get(ALLOW_FILESYS))
		{
			var extArrows = features.StorageAccess.getArrowTexture(textureCheck);
			if (extArrows != null)
				return ["ext", extArrows[0], extArrows[1]];
			else
				skin = UIStaticArrow.nullCheckAssets(textureCheck);
		}
		else
			skin = UIStaticArrow.nullCheckAssets(textureCheck);
		#else
		skin = UIStaticArrow.nullCheckAssets(textureCheck);
		#end

		return skin;
	}
}
