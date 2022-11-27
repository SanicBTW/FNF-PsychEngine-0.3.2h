package notes;

import haxe.exceptions.NotImplementedException;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import notes.NoteUtils as NU;

// from forever engine legacy, modified
class UIStaticArrow extends FlxSprite
{
	private var colorSwap:ColorSwap;

	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	public var texture(default, set):String = null;

	public var arrowType:Int = 0;
	public var initialX:Int;
	public var initialY:Int;

	public var setAlpha:Float = 0.8;
	public var resetAnim:Float = 0;
	public var direction:Float = 90;
	public var isPixel:Bool = false;

	public function new(x:Float, y:Float, arrowType:Int = 0, isPixel:Bool = false)
	{
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		this.arrowType = arrowType;
		this.isPixel = isPixel;
		super(x, y);

		texture = '';
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}

		if (animation.curAnim.name == "confirm" && !isPixel)
			centerOrigin();

		super.update(elapsed);
	}

	private function set_texture(value:String):String
	{
		if (texture != value)
			reloadNote();
		texture = value;
		return value;
	}

	public function reloadNote()
	{
		var skin:String = texture;
		if (texture.length < 1)
		{
			skin = PlayState.SONG.arrowSkin;
			if (skin == null || skin.length < 1)
				skin = "NOTE_assets";
		}

		var lastAnim:String = null;
		if (animation.curAnim != null)
			lastAnim = animation.curAnim.name;

		var check:Dynamic = NU.nullCheck(skin);
		if (check[0] != "ext")
		{
			skin = check;
			if (isPixel)
			{
				loadGraphic(Paths.image('pixelUI/$skin'), true, 17, 17);
				loadPixelAnims();
				setGraphicSize(Std.int(width * NU.daPixelZoom));
				antialiasing = false;
			}
			else
			{
				frames = Paths.getSparrowAtlas(skin);
				loadAnims();
				setGraphicSize(Std.int(width * 0.7));
				antialiasing = SaveData.get(ANTIALIASING);
			}
		}
		else
		{
			if (isPixel)
				throw new NotImplementedException();
			else
			{
				frames = check[2];
				loadAnims();
				setGraphicSize(Std.int(width * 0.7));
				antialiasing = SaveData.get(ANTIALIASING);
			}
		}

		updateHitbox();

		if (lastAnim != null)
			playAnim(lastAnim, true);
	}

	private function loadPixelAnims()
	{
		animation.add('static', [arrowType]);
		animation.add('pressed', [4 + arrowType, 8 + arrowType], 12, false);
		animation.add('confirm', [12 + arrowType, 16 + arrowType], 24, false);
	}

	private function loadAnims()
	{
		var stringSect:String = NU.getArrowFromNum(arrowType);
		animation.addByPrefix('static', 'arrow${stringSect.toUpperCase()}');
		animation.addByPrefix('pressed', '$stringSect press', 24, false);
		animation.addByPrefix('confirm', '$stringSect confirm', 24, false);
	}

	// % 4 should be % keyAmount or stmh - soon
	public function playAnim(AnimName:String, Force:Bool = false)
	{
		if (AnimName == "confirm")
		{
			colorSwap.hue = SaveData.getHSV(arrowType, 0) / 360;
			colorSwap.saturation = SaveData.getHSV(arrowType, 1) / 100;
			colorSwap.brightness = SaveData.getHSV(arrowType, 2) / 100;
			alpha = 1;

			if (!isPixel)
				centerOrigin();
		}
		else
		{
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
			alpha = setAlpha;
		}

		animation.play(AnimName, Force);
		centerOffsets();
		centerOrigin();
	}
}
