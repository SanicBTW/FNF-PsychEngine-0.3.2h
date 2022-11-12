package options;

class InputSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Input Settings';
		rpcTitle = 'Input Settings Menu';

		var option:Option = new Option('Input Handling:', "With which input do you want to handle keypresses?", INPUT_TYPE, "string", "Kade 1.5.3",
			["Kade 1.5.3", "Psych 0.4.2"]);
		addOption(option);

		var option:Option = new Option('OSU! Mania Simulation',
			"If enabled, you must stop holding on a sustain note\nat the correct moment.\nThis simulates OSU! Mania input kind of", OSU_MANIA_SIMULATION,
			"bool", true);
		addOption(option);

		var option:Option = new Option('Rating Offset', 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.',
			RATING_OFFSET, 'int', 0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option('Sick! Hit Window', 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.', SICK_WINDOW, 'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option('Good Hit Window', 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', GOOD_WINDOW, 'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option('Bad Hit Window', 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', BAD_WINDOW, 'int', 135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option('Shit Hit Window', 'Changes the amount of time you have\nfor hitting a "Shit" in milliseconds.', SHIT_WINDOW, "int",
			166);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 166;
		addOption(option);

		var option:Option = new Option('Safe Frames', 'Changes how many frames you have for\nhitting a note earlier or late.', SAFE_FRAMES, 'float', 10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}
}
