package options;

class MiscSettingsSubState extends BaseOptionsMenu
{
    public function new()
    {
        title = 'Miscellaneous Settings';
        rpcTitle = "Miscellaneous Settings Menu";

        var option:Option = new Option('Old songs import',
            'If enabled the engine will add songs by detecting them on songs/data folders',
            OLD_SONG_SYSTEM, 'bool', false);
        addOption(option);

        super();
    }
}