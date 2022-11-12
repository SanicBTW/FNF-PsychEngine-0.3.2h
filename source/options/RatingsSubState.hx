package options;

class RatingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = "Ratings Settings";
		rpcTitle = "Ratings Settings Menu";

		var option:Option = new Option('Use Legacy Ratings', 'If checked, it will use the old rating system (FNF)\nand not the Forever one',
			USE_CLASSIC_COMBOS, 'bool', false);
		addOption(option);

		var option:Option = new Option('Legacy Ratings Style:', 'If the option above is checked, this will change the style of ratings', LEGACY_RATINGS_STYLE,
			'string', 'Classic', ['Classic', 'Kade New', 'Kade Old']);
		addOption(option);

		var option:Option = new Option('Combos&Ratings Style:', "The style of Combos and Ratings (Forever), this doesn't affect\nLegacy Ratings style",
			RATINGS_STYLE, "string", "Default", ["Default", "SimplyLove"]);
		addOption(option);

		super();
	}
}
