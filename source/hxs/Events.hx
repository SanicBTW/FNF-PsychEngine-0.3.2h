package hxs;

import haxe.ds.StringMap;
import lime.utils.Assets;
import hxs.ScriptHandler.ForeverModule;
using StringTools;

typedef EventNote =
{
    strumTime:Float,
    event:String,
    value1:String,
    value2:String
}

class Events
{
    public static var eventList:Array<String> = [];
    public static var loadedModules:Map<String, ForeverModule> = [];
    
    public static function obtainEvents()
    {
        loadedModules.clear();
        eventList = [];
        var tempEventArray:Array<String> = getEventFiles();

        var futureEvents:Array<String> = [];
        var futureSubEvents:Array<String> = [];

        for (event in tempEventArray)
        {
            if (event.contains("."))
            {
                event = event.substring(0, event.indexOf('.', 0));
                loadedModules.set(getName(event), ScriptHandler.loadModule('$event', "events", ""));
                futureEvents.push(getName(event));
            }
            else
            {
                if (PlayState.SONG != null && Paths.formatToSongPath(PlayState.SONG.song) == getName(event))
                {
                    var internalEvents:Array<String> = getDirEvFiles(getName(event));
                    for (subEvent in internalEvents)
                    {
                        subEvent = subEvent.substring(0, subEvent.indexOf('.', 0));
                        loadedModules.set(getName(subEvent), ScriptHandler.loadModule('$event/$subEvent', "events", ""));
                        futureSubEvents.push(getName(subEvent));
                    }
                }
            }
        }

        futureEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));
        futureSubEvents.sort(function(a, b) return Reflect.compare(a.toLowerCase(), b.toLowerCase()));

        for (i in futureSubEvents)
            eventList.push(i);
        futureEvents.insert(0, '');
        for (i in futureEvents)
            eventList.push(i);

        futureEvents = [];
        futureSubEvents = [];

        eventList.insert(0, '');
    }

    public static function returnDescription(event:String)
    {
        if (loadedModules.get(event) != null)
        {
            var module:ForeverModule = loadedModules.get(event);
            if (module.exists('returnDescription'))
                return module.get('returnDescription')();
        }
        return '';
    }

    private static function getEventFiles()
    {
        var retArray:Array<String> = [];

        var lib = Assets.getLibrary('events');
        for(asset in lib.list(null))
        {
            retArray.push(asset);
        }

        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var files = features.StorageAccess.getFolderFiles(EVENTS);
            for (file in files)
            {
                var path = features.StorageAccess.makePath(EVENTS, file);
                retArray.push(path);
            }
        }
        #end

        return retArray;
    }

    private static function getDirEvFiles(directory:String)
    {
        var retArray:Array<String> = [];

        //dunno if this is working
        var lib = Assets.getLibrary('events');
        for(asset in lib.list(null))
        {
            if (asset.contains(directory))
                retArray.push(asset);
        }

        #if STORAGE_ACCESS
        if (SaveData.get(ALLOW_FILESYS))
        {
            var mainPath = haxe.io.Path.join([features.StorageAccess.getFolderPath(EVENTS), directory]);
            var files = sys.FileSystem.readDirectory(mainPath);
            for (file in files)
            {
                retArray.push(file);
            }
        }
        #end

        return retArray;
    }

    // to return the event name instead of the path to it
    private static function getName(fullString:String)
    {
        if (fullString.contains("assets/"))
            return fullString.replace("assets/events/", "");
        #if STORAGE_ACCESS
        else
            return fullString.replace('${features.StorageAccess.getFolderPath(EVENTS)}/', "");
        #end

        return '';
    }
}