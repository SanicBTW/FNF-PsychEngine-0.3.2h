package;

import lime.utils.Assets;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class Ratings
{
	// actual rating and timing shit

	// follows the timings.hx judgementsMap structure on Forever Engine Legacy
	public static var judgementsMap:Map<String, Array<Dynamic>> = 
	[
		"sick" => 
			[	
				0, 
				350, 
				100, 
				'SFC'
			],
		"good" => 
			[
				1, 
				150, 
				75, 
				'GFC'
			],
		"bad" => 
			[
				2, 
				0, 
				50, 
				'FC'
			],
		"shit" => 
			[
				3, 
				-50, 
				25,
			],
		"miss" => 
			[
				4, 
				-100, 
				-100, //idk if i should -1 on totalNotesHit uhh
			],
	];

	public static var ratingsMap:Map<String, Float> =
	[
		"You suck!" => 0.2,
		"Shit" => 0.4,
		"Bad" => 0.5,
		"Bruh" => 0.6,
		"Meh" => 0.69,
		"Nice" => 0.7,
		"Good" => 0.8,
		"Great" => 0.9,
		"Sick!" => 1,
		"Perfect!" => 1
	];

	public static var timingWindows:Array<Dynamic> = 
	[
		[SaveData.get(SICK_WINDOW), "sick"],
		[SaveData.get(GOOD_WINDOW), "good"],
		[SaveData.get(BAD_WINDOW), "bad"],
		[SaveData.get(SHIT_WINDOW), "shit"],
		[180, "miss"]
	];

	public static var accuracy:Float;
	public static var trueAccuracy:Float;

	public static var smallestRating:String;
	public static var ratingString:String;
	public static var ratingFC:String;

	public static var notesHit:Int = 0;

	public static var sicks:Int = 0;
	public static var goods:Int = 0;
	public static var bads:Int = 0;
	public static var shits:Int = 0;
	public static var misses:Int = 0;

	// lets fucking go, simplified af
	public static function judgeNote(ms:Float)
	{
		for (i in 0...timingWindows.length)
		{
			if (ms <= timingWindows[Math.round(Math.min(i, timingWindows.length - 1))][0] * Conductor.timeScale)
			{
				return timingWindows[Math.round(Math.min(i, timingWindows.length - 1))][1];
			}
		}

		return 'miss';
	}

	public static function callReset()
	{
		sicks = 0;
		goods = 0;
		bads = 0;
		shits = 0;
		misses = 0;

		accuracy = 0.001;
		trueAccuracy = 0;

		smallestRating = "sick";

		switch (SaveData.get(SCORE_TEXT_STYLE))
		{
			case 'Engine' | 'Forever':
				ratingString = "N/A";
			case 'Psych':
				ratingString = "?";
		}

		ratingFC = "";

		notesHit = 0;
	}

	public static function updateAccuracy(judgement:Int, isSus:Bool = false, susCount:Int = 1)
	{
		if (!isSus)
		{
			notesHit++;
			accuracy += (Math.max(0, judgement));
		}
		else
			accuracy += (Math.max(0, judgement) / susCount);

		trueAccuracy = (accuracy / notesHit);

		updateFC();
		updateRating();
	}

	public static function updateFC()
	{
		ratingFC = "";
		if (judgementsMap.get(smallestRating)[3] != null)
			ratingFC = judgementsMap.get(smallestRating)[3];
		else
		{
			if (misses > 0 && misses < 10)
				ratingFC = "SDCB";
			else if (misses >= 10)
				ratingFC = "Clear";
		}

		PlayState.instance.uiHUD.updateScore();
	}

	public static function updateRating()
	{
		for (rating => threshold in ratingsMap)
		{
			if (trueAccuracy / 100 < threshold)
			{
				ratingString = rating;
				break;
			}
		}
	}

	// this manages sprite shit too

	// tf bruh ??? :sob:
	public static function preparePos()
	{
		var coolText:FlxText = new FlxText(0, 0, 0, '', 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		basePos = coolText.x;
	}

	private static var basePos:Float = 0;
	public static function generateCombo(number:String, allSicks:Bool, isPixel:Bool, negative:Bool, createdColor:FlxColor, scoreInt:Int):FlxSprite
	{
		var width = 100;
		var height = 140;
		var path = Paths.getLibraryPath('${SaveData.get(COMBOS_STYLE)}/combo${isPixel ? "-pixel" : ""}.png', "UILib");
		if (SaveData.get(COMBOS_STYLE) == "SimplyLove" && isPixel)
			path = Paths.getLibraryPath('Default/combo-pixel.png', "UILib");
		if (!Assets.exists(path))
			path = path.replace('-pixel', "");
		var graphic = Paths.getGraphic(path);

		if (isPixel)
		{
			width = 10;
			height = 12;
		}

		var newSprite:FlxSprite = new FlxSprite().loadGraphic(graphic, true, width, height);
		newSprite.alpha = 1;
		newSprite.screenCenter();
		newSprite.x = basePos + (43 * scoreInt) - 90;
		newSprite.y += 80;

		newSprite.visible = (!SaveData.get(HIDE_HUD));
		newSprite.x += SaveData.get(COMBO_OFFSET)[2];
		newSprite.y -= SaveData.get(COMBO_OFFSET)[3];

		newSprite.color = FlxColor.WHITE;
		if (negative)
			newSprite.color = createdColor;

		newSprite.animation.add('base', [
			(Std.parseInt(number) != null ? Std.parseInt(number) + 1 : 0) + (!allSicks ? 0 : 11)
		], 0, false);
		newSprite.animation.play('base');

		if (isPixel)
			newSprite.setGraphicSize(Std.int(newSprite.width * PlayState.daPixelZoom));
		else
		{
			newSprite.antialiasing = SaveData.get(ANTIALIASING);
			newSprite.setGraphicSize(Std.int(newSprite.width * 0.5));
		}

		newSprite.updateHitbox();
		newSprite.acceleration.y = FlxG.random.int(200, 300);
		newSprite.velocity.x = FlxG.random.float(-5, 5);
		newSprite.velocity.y -= FlxG.random.int(140, 160);

		return newSprite;
	}

	public static function generateLegacyCombo(number:Int, isPixel:Bool, daLoop:Int /* how the fuck do i call this */):FlxSprite
	{
		var path = Paths.image('${isPixel ? "pixelUI/" : ""}num$number${isPixel ? "-pixel" : ""}');
		var graphic = Paths.getGraphic(path);

		var newSprite:FlxSprite = new FlxSprite().loadGraphic(graphic);
		newSprite.alpha = 1;
		newSprite.screenCenter();
		newSprite.x = basePos + (43 * daLoop) - 90;
		newSprite.y += 80;

		newSprite.visible = (!SaveData.get(HIDE_HUD));
		newSprite.x += SaveData.get(COMBO_OFFSET)[2];
		newSprite.y -= SaveData.get(COMBO_OFFSET)[3];

		if (isPixel)
			newSprite.setGraphicSize(Std.int(newSprite.width * PlayState.daPixelZoom));
		else
		{
			newSprite.antialiasing = SaveData.get(ANTIALIASING);
			newSprite.setGraphicSize(Std.int(newSprite.width * 0.5));
		}

		newSprite.updateHitbox();
		newSprite.acceleration.y = FlxG.random.int(200, 300);
		newSprite.velocity.x = FlxG.random.float(-5, 5);
		newSprite.velocity.y -= FlxG.random.int(140, 160);

		return newSprite;
	}

	public static function generateRating(ratingName:String, perfectSick:Bool, timing:String, isPixel:Bool):FlxSprite
	{
		var width = 500;
		var height = 163;
		var path = Paths.getLibraryPath('${SaveData.get(RATINGS_STYLE)}/judgements${isPixel ? "-pixel" : ""}.png', "UILib");
		if (SaveData.get(RATINGS_STYLE) == "SimplyLove" && isPixel)
			path = Paths.getLibraryPath('Default/judgements-pixel.png', "UILib");
		if (!Assets.exists(path))
			path = path.replace('-pixel', "");
		var graphic = Paths.getGraphic(path);

		if (isPixel)
		{
			width = 72;
			height = 32;
		}

		var rating:FlxSprite = new FlxSprite().loadGraphic(graphic, true, width, height);
		rating.alpha = 1;
		rating.screenCenter();
		rating.x = basePos - 40;
		rating.y -= 60;

		rating.visible = (!SaveData.get(HIDE_HUD));
		rating.x += SaveData.get(COMBO_OFFSET)[0];
		rating.y -= SaveData.get(COMBO_OFFSET)[1];

		rating.animation.add('base', [
			Std.int((judgementsMap.get(ratingName)[0] * 2) + (perfectSick ? 0 : 2) + (timing == "late" ? 1 : 0))
		], 24, false);
		rating.animation.play('base');

		if (isPixel)
			rating.setGraphicSize(Std.int(rating.width * PlayState.daPixelZoom * 0.7));
		else
		{
			rating.antialiasing = SaveData.get(ANTIALIASING);
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			if (SaveData.get(SMALL_RATING_SIZE))
			{
				rating.updateHitbox();
				rating.setGraphicSize(Std.int(rating.width * 0.7));
			}
		}

		rating.updateHitbox();
		rating.acceleration.y = 550;
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.velocity.y -= FlxG.random.int(140, 175);

		return rating;
	}

	public static function generateLegacyRating(ratingName:String, isPixel:Bool):FlxSprite
	{
		var path = Paths.getLibraryPath('${SaveData.get(LEGACY_RATINGS_STYLE)}/$ratingName${isPixel ? "-pixel" : ""}.png', "ClassicUILib");
		var graphic = Paths.getGraphic(path);

		var rating:FlxSprite = new FlxSprite().loadGraphic(graphic);
		rating.alpha = 1;
		rating.screenCenter();
		rating.x = basePos - 40;
		rating.y -= 60;

		rating.visible = (!SaveData.get(HIDE_HUD));
		rating.x += SaveData.get(COMBO_OFFSET)[0];
		rating.y -= SaveData.get(COMBO_OFFSET)[1];

		if (isPixel)
			rating.setGraphicSize(Std.int(rating.width * PlayState.daPixelZoom * 0.7));
		else
		{
			rating.antialiasing = SaveData.get(ANTIALIASING);
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			if (SaveData.get(SMALL_RATING_SIZE))
			{
				rating.updateHitbox();
				rating.setGraphicSize(Std.int(rating.width * 0.7));
			}
		}

		rating.updateHitbox();
		rating.acceleration.y = 550;
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.velocity.y -= FlxG.random.int(140, 175);

		return rating;
	}
}
