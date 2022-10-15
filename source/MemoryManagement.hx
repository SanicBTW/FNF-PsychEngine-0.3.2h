package;

import openfl.system.System;
import openfl.Assets;

class MemoryManagement
{
    private static var libraries:Array<String> = ["shared", "UILib"];

    public static function pushLibrary(library:String)
    {
        libraries.push(library);
    }

    public static function getLibraries(callback:String->Void)
    {
        for(i in 0...libraries.length)
            callback(libraries[i]);
    }

    public static function clearLibrariesCache()
    {
        getLibraries(function(library)
        {
            trace("Removed " + library + " from cache");
            Assets.cache.clear(library);
        });

        libraries = ["shared", "UILib"]; //set it back to the default values

        PlayState.inst = null;
        PlayState.voices = null;

        System.gc();
    }
}