package notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

// rewrite soon
class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;

	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		super(x, y);

		var skin:String = 'noteSplashes';
		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
			skin = PlayState.SONG.splashSkin;

		loadAnims(skin);

		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = SaveData.get(ANTIALIASING);
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0)
	{
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		if (texture == null)
		{
			texture = 'noteSplashes';
			if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0)
				texture = PlayState.SONG.splashSkin;
		}

		if (textureLoaded != texture)
		{
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(-26.2, -17);
	}

	public function playAnim(note:Int = 0)
	{
		visible = true;
		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if (animation.curAnim != null)
			animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String)
	{
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3)
		{
			animation.addByPrefix("note1-" + i, "note impact " + i + " blue", 24, false);
			animation.addByPrefix("note2-" + i, "note impact " + i + " green", 24, false);
			animation.addByPrefix("note0-" + i, "note impact " + i + " purple", 24, false);
			animation.addByPrefix("note3-" + i, "note impact " + i + " red", 24, false);
		}
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
			if (animation.curAnim.finished)
				visible = false;

		super.update(elapsed);
	}
}
