package options;

import openfl.text.TextFormat;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; // for Discord Rich Presence

		var option:Option = new Option('FPS Counter', 'If unchecked, hides FPS Counter.', SHOW_FRAMERATE, 'bool', true);
		addOption(option);
		option.onChange = onChangeFPSCounter;

		var option:Option = new Option('Memory Counter', 'If unchecked, hides Memory Counter.', SHOW_MEMORY, 'bool', true);
		addOption(option);
		option.onChange = onChangeMemoryCounter;

		var option:Option = new Option('Note Splashes', "If unchecked, hitting \"Sick!\" notes won't show particles.", NOTE_SPLASHES, 'bool', true);
		addOption(option);

		var option:Option = new Option('Opponent Note Splashes', "If enabled, note splashes will show on opponent note hit", OPPONENT_NOTE_SPLASHES, "bool",
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD', 'If checked, hides most HUD elements.', HIDE_HUD, 'bool', false);
		addOption(option);

		var option:Option = new Option('Hide Song Length', "If checked, the bar showing how much time is left\nwill be hidden.", HIDE_TIME, 'bool', false);
		addOption(option);

		var option:Option = new Option('Flashing Lights', "Uncheck this if you're sensitive to flashing lights!", FLASHING, 'bool', true);
		addOption(option);

		var option:Option = new Option('Icon Boping', "If checked, icons bop", ICON_BOPING, "bool", true);
		addOption(option);

		var option:Option = new Option('Score Text Design: ',
			"Type of formatting on score text\nEngine: S M A R (FCR)\nPsych: S M R (A) - FCR\nForever: S A [FCR] CB R", SCORE_TEXT_STYLE, "string", "Engine",
			["Engine", "Psych", "Forever"]);
		addOption(option);

		var option:Option = new Option('Score Text Zoom on Hit', "If unchecked, disables the Score text zooming\neverytime you hit a note.",
			SCORE_ZOOM, // dumb ass
			'bool', true);
		addOption(option);

		var option:Option = new Option('Combo Stacking',
			"If unchecked, Ratings and Combo won't stack\nsaving on System Memory and making them easier to read", COMBO_STACKING, 'bool', true);
		addOption(option);

		var option:Option = new Option('Counters Font:', 'Change the FPS Counter and Memory Counter fonts', COUNTERS_FONT, 'string', "Funkin",
			["Funkin", "VCR OSD Mono", "Sans", "Pixel"]);
		addOption(option);
		option.onChange = updateFont;

		super();
	}

	function onChangeFPSCounter()
	{
		if (Main.fpsVar != null)
		{
			Main.fpsVar.visible = SaveData.get(SHOW_FRAMERATE);
			if (Main.fpsVar.alpha == 0)
				Main.tweenFPS();
		}
	}

	function onChangeMemoryCounter()
	{
		if (Main.memoryVar != null)
		{
			Main.memoryVar.visible = SaveData.get(SHOW_MEMORY);
			if (Main.memoryVar.alpha == 0)
				Main.tweenMemory();
		}
	}

	function updateFont()
	{
		var formatSize:Int = 12;
		var propername:String = SaveData.get(COUNTERS_FONT);
		switch (SaveData.get(COUNTERS_FONT))
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
