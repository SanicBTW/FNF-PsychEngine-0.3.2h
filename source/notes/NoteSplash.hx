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
		setPosition(x - NoteUtils.swagWidth * 0.95, y - NoteUtils.swagWidth);
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
			setOffsets(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
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
		var check:Dynamic = NoteUtils.noteSplashNullCheck(skin);
		if (check[0] != null)
		{
			frames = check[1];
			NoteUtils.setPSplashAnims(this); // forced, probably the universal is the psych anims
		}
		else
		{
			frames = Paths.getSparrowAtlas(check);
			NoteUtils.setSplashAnims(this);
		}
	}

	function setOffsets(skin:String)
	{
		var offsets = NoteUtils.getNoteSplashOffset(skin);
		offset.set(offsets[1], offsets[2]);
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
			if (animation.curAnim.finished)
				visible = false;

		super.update(elapsed);
	}
}
