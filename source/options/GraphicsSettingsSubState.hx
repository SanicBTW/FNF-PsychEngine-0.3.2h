package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu';

		var option:Option = new Option('Low Quality', 'If checked, disables some background details,\ndecreases loading times and improves performance.',
			LOW_QUALITY, 'bool', false);
		addOption(option);

		var option:Option = new Option('Anti-Aliasing', 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			ANTIALIASING, 'bool', true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing;
		addOption(option);

		#if !html5
		var option:Option = new Option('Framerate', "Pretty self explanatory, isn't it?", FPS, 'int', 60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 350;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('Small Ratings', "If enabled, the ratings sprite will be small", SMALL_RATING_SIZE, "bool", true);
		addOption(option);

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; // Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; // Don't judge me ok
			if (sprite != null && (sprite is FlxSprite) && !(sprite is FlxText))
				sprite.antialiasing = SaveData.get(ANTIALIASING);
		}
	}

	function onChangeFramerate()
	{
		if (SaveData.get(FPS) > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = SaveData.get(FPS);
			FlxG.drawFramerate = SaveData.get(FPS);
		}
		else
		{
			FlxG.drawFramerate = SaveData.get(FPS);
			FlxG.updateFramerate = SaveData.get(FPS);
		}
	}
}
