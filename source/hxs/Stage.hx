package hxs;

import flixel.FlxSprite;
import flixel.FlxBasic;
import hxs.ScriptHandler.ForeverModule;
import haxe.ds.StringMap;
import flixel.group.FlxGroup.FlxTypedGroup;

class Stage extends FlxTypedGroup<FlxBasic>
{
    public function new(stage:String)
    {
        super();

        var exposure:StringMap<Dynamic> = new StringMap<Dynamic>();
        exposure.set("add", addTo);
        exposure.set("stage", this);
        var stageBuild:ForeverModule = ScriptHandler.loadModule('stages/$stage/$stage', 'stages/$stage', exposure);
        if (stageBuild.exists("onCreate"))
            stageBuild.get("onCreate")();
        trace('Module Stage $stage loaded');
    }

    public function addTo(object:FlxBasic)
    {
        trace("adding");
        if (object is FlxSprite)
            cast(object, FlxSprite).antialiasing = SaveData.get(ANTIALIASING);
        add(object);
    }
}