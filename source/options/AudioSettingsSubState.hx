package options;

class AudioSettingsSubState extends BaseOptionsMenu
{
	public function new()
    {
        title = 'Audio Settings';
        rpcTitle = 'Audio Settings Menu'; //for Discord Rich Presence
    
        var option:Option = new Option('Pause Screen Song:',
            "What song do you prefer for the Pause Screen?",
            'pauseMusic',
            'string',
            'Tea Time',
            ["None", 'Breakfast', 'Tea Time']);
        addOption(option);

        var option:Option = new Option('Miss Volume',
            'How loud should be the miss sound?',
            'missVolume',
            'percent',
            0.2);
        addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 0.2;
		option.changeValue = 0.01;
		option.decimals = 1;
    
        var option:Option = new Option('Hitsound Volume',
            'How loud should be the hitsound?',
            'hitsoundVolume',
            'percent',
            0);
        addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 1;

        super();
    }
}