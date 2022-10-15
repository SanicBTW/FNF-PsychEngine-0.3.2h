package;

import openfl.system.System;
import openfl.Assets;

class MemoryManagement
{
    private static var toLoad:Map<String, LibraryType> = new Map();
    private static var loaded:Array<String> = [];

    public static function addToLoadQueue(lib:String, type:LibraryType)
    {
        toLoad.set(lib, type);
        trace("Added: " + lib + " type: " + type + " to the load queue");
    }

    public static function removeFromLoadQueue(lib:String, pushLoaded:Bool = true)
    {
        toLoad.remove(lib);
        if(pushLoaded == true)
        {
            loaded.push(lib);
            trace("Removed: " + lib + " and added it to loaded libs");
        }
        else
        {
            trace("Removed: " + lib + " and it wasn't added to loaded libs");
        }
    }

    public static function clearLibraryCache()
    {
        for(i in 0...loaded.length)
        {
            trace("Removed " + loaded[i] + " from cache");
            Assets.cache.clear(loaded[i]);
        }

        loaded = [];
        toLoad.clear();

        PlayState.inst = null;
		PlayState.voices = null;

        System.gc();
    }

    //i dont want to make the map and array public idk why
    public static function getLoadQueue(callback:Array<Dynamic>->Void)
    {
        for(libName => libType in toLoad)
        {
            callback([libName, libType]);
        }
    }

    //istg im gonna kms
    public static function pushToLoaded(libLoaded:String)
    {
        if(!loaded.contains(libLoaded))
        {
            loaded.push(libLoaded);
            trace("Manually pushed " + libLoaded + " to loaded array");
        }
    }
}

@:enum abstract LibraryType(String) to String
{
    var SONG;
    var LIBRARY;
}