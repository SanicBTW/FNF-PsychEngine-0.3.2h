package options;

import openfl.text.TextFormat;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;

		var option:Option = new Option('Memory Counter',
			'If unchecked, hides Memory Counter.',
			'showMemory',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeMemoryCounter;

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Opponent Note Splashes',
			"If enabled, note splashes will show on opponent note hit",
			"opponentNoteSplash",
			"bool",
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);
		
		var option:Option = new Option('Hide Song Length',
			"If checked, the bar showing how much time is left\nwill be hidden.",
			'hideTime',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Icon Boping',
			"If checked, icons bop",
			"iconBoping",
			"bool",
			true);
		addOption(option);

		var option:Option = new Option('Score Text Design:',
			"Type of formatting on score text\nEngine: Score Misses Accuracy Rating (Full Combo Rating)\nPsych: Score Misses Rating (Accuracy) - Full Combo Rating",
			"scoreTextDesign",
			"string",
			"Engine",
			["Engine", "Psych"]);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit',
			"If unchecked, disables the Score text zooming\neverytime you hit a note.",
			'optScoreZoom', //dumb ass
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack\nsaving on System Memory and making them easier to read",
			'comboStacking',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Counters Font:',
			'Change the FPS Counter and Memory Counter fonts',
			'counterFont',
			'string',
			"Funkin",
			["Funkin", "VCR OSD Mono", "Sans", "Pixel"]);
		addOption(option);
		option.onChange = updateFont;

		super();
	}

	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
		{
			Main.fpsVar.visible = ClientPrefs.showFPS;
			if(Main.fpsVar.alpha == 0)
				Main.tweenFPS();
		}
	}

	function onChangeMemoryCounter()
	{
		if(Main.memoryVar != null)
		{
			Main.memoryVar.visible = ClientPrefs.showMemory;
			if(Main.memoryVar.alpha == 0)
				Main.tweenMemory();
		}
	}

	function updateFont()
	{
		var formatSize:Int = 12;
		var propername:String = ClientPrefs.counterFont;
		switch(ClientPrefs.counterFont)
		{
			case "Funkin":
				formatSize = 18;
			case "VCR OSD Mono":
				formatSize = 16;
			case "Pixel":
				formatSize = 10;
				propername = "Pixel Arial 11 Bold";
			case "Sans":
				propername = "_sans";
		}

		Main.fpsVar.defaultTextFormat = new TextFormat(propername, formatSize, 0xFFFFFF);
		Main.fpsVar.embedFonts = true;

		Main.memoryVar.defaultTextFormat = new TextFormat(propername, formatSize, 0xFFFFFF);
		Main.memoryVar.embedFonts = true;
	}
}