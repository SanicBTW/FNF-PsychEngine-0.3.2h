package features;

// just to save shit lol
class OnlineItem
{
    public var songName:String = "";
    public var chartPath:String = "";
    public var eventPath:String = "";
    public var instPath:String = "";
    public var voicesPath:String = "";

    public var charDataShit:Array<String> = [];
    public var charGraphicShit:Array<String> = [];

    public function new (songName, chartPath, eventPath, instPath, voicesPath, charDataShit, charGraphicShit)
    {
        this.songName = songName;
        this.chartPath = chartPath;
        this.eventPath = eventPath;
        this.instPath = instPath;
        this.voicesPath = voicesPath;
        this.charDataShit = charDataShit;
        this.charGraphicShit = charGraphicShit;
    }
}

typedef Funkin = 
{
    var id:String;
    var song:String;
    var chart:String;
    var events:String;
    var inst:String;
    var voices:String;
}

typedef Funkin_Chars = 
{
    var id:String;
    var char_data:Array<String>;
    var char_graphic:Array<String>;
    var song:String;
}