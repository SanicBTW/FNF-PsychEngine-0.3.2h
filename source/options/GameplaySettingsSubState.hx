package options;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu';

		var option:Option = new Option('Downscroll', 'If checked, notes go Down instead of Up, simple enough.', DOWN_SCROLL, 'bool', false);
		addOption(option);

		var option:Option = new Option('Middlescroll', 'If checked, your notes get centered.', MIDDLE_SCROLL, 'bool', false);
		addOption(option);

		var option:Option = new Option('Ghost Tapping', "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			GHOST_TAPPING, 'bool', true);
		addOption(option);

		var option:Option = new Option('Freestyle BF', "If enabled, BF will sing in the strum direction\nonly works with Ghost Tapping", FREESTYLE_BF, "bool",
			true);
		addOption(option);

		var option:Option = new Option("Pause game when focus lost", "When changing application, the game will pause", PAUSE_ON_FOCUS_LOST, "bool", true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button', "If checked, pressing Reset won't do anything.", NO_RESET, 'bool', false);
		addOption(option);

		super();
	}
}
