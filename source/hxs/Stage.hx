package hxs;

import flixel.FlxSprite;
import flixel.FlxBasic;
import hxs.ScriptHandler.ForeverModule;
import haxe.ds.StringMap;
import flixel.group.FlxGroup.FlxTypedGroup;

class Stage extends FlxTypedGroup<FlxBasic>
{
    private var stageBuild:ForeverModule;
    public function new(stage:String)
    {
        super();

        var exposure:StringMap<Dynamic> = new StringMap<Dynamic>();
        exposure.set("add", function(object:FlxBasic)
        {
            if (object is FlxSprite) cast(object, FlxSprite).antialiasing = SaveData.get(ANTIALIASING);
            add(object);
        });
        exposure.set("stage", this);
        stageBuild = ScriptHandler.loadModule('stages/$stage/$stage', 'stages/$stage', exposure);
        if (stageBuild.exists("onCreate"))
            stageBuild.get("onCreate")();
        trace('Module Stage $stage loaded');
    }

    override public function update(elapsed:Float)
    {
        if (stageBuild.exists("onUpdate"))
            stageBuild.get("onUpdate")(elapsed);
    }
}