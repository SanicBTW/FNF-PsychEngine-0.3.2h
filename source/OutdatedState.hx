package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedState extends MusicBeatState
{
	var updatePrompt:Prompt;

	public static var leftState:Bool = false;

	override function create()
	{
		super.create();

		FlxG.mouse.visible = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		updatePrompt = new Prompt('Engine Outdated!',
			"Your current version is outdated. Press OK to go to the Github page otherwise press CANCEL to ignore\n\nNewest ver "
			+ TitleState.updateVer
			+ "\nCurrent ver "
			+ Application.current.meta.get('version'));
		updatePrompt.infoTxt.size = 16;
		updatePrompt.titleTxt.y -= 10;
		updatePrompt.screenCenter();
		add(updatePrompt);

		updatePrompt.b1Callback = function()
		{
			trace("Redirecting");
			FlxG.sound.play(Paths.sound('cancelMenu'));
			CoolUtil.browserLoad('https://github.com/SanicBTW/FNF-PsychEngine-0.3.2h');
			FlxTween.tween(updatePrompt, {alpha: 0}, 1, {
				onComplete: function(twn:FlxTween)
				{
					FlxG.mouse.visible = false;
					MusicBeatState.switchState(new MainMenuState());
				}
			});
		}

		updatePrompt.b2Callback = function()
		{
			trace("Alright!");
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxTween.tween(updatePrompt, {alpha: 0}, 1, {
				onComplete: function(twn:FlxTween)
				{
					FlxG.mouse.visible = false;
					MusicBeatState.switchState(new MainMenuState());
				}
			});
		}
	}
}
