#if VIRTUAL_FS
//this was going to be the virtual file sys code but ended up discarding it
package virtualFS;

import flixel.FlxG;
import js.html.Storage;

using StringTools;

class Old
{
    private static var mainPath:String = "sanicbtw_pe_virtualFS:";
    private static var virtFSVersion:String = "0.0.1";
    private static var storage:Storage;

    public function new() 
    {
        if(getItem("fsVersion") != virtFSVersion)
        {
            clear();
            setItem("fsVersion", virtFSVersion);
        }
    }

    private static function getItem(key:String, returnType:ReturnTypes = STRING):Dynamic
    {
        var theReturn:Dynamic = "";

        if(storage.getItem(mainPath + formatString(key)) == null)
            setItem(formatString(key), "");

        var item = storage.getItem(mainPath + formatString(key));
        FlxG.log.add("wants " + item + " parsed to " + returnType + " from " + formatString(key));
        switch(returnType)
        {
            case BOOL:
                theReturn = DumbParser.parseBool(item);
            case FLOAT:
                theReturn = DumbParser.parseFloat(item);
            case INT:
                theReturn = DumbParser.parseInt(item);
            case STRING:
                theReturn = item;
        }
        return theReturn;
    }
    
    private static function setItem(key:String, value:Dynamic)
    {
        storage.setItem(mainPath + formatString(key), value);
        FlxG.log.add("created/updated item at " + formatString(key) + " with value " + value);
    }

    private static function removeItem(key:String)
    {
        storage.removeItem(formatString(key));
        FlxG.log.add("removed " + formatString(key));
    }

    private static function clear()
    {
        FlxG.log.add("removed " + storage.length);
        storage.clear();
    }

    private static function formatString(s:String):String
    {
        return s.toLowerCase().split(" ").join("-").trim();
    }
}

@:enum abstract ReturnTypes(String) to String
{
    var BOOL;
    var STRING;
    var INT;
    var FLOAT;
}
#end