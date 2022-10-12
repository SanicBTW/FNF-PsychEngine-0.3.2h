#if VIRTUAL_FS
package virtualFS;

import flixel.FlxG;
import flixel.util.FlxSave;
import openfl.net.FileReference;
import openfl.events.Event;

using StringTools;

class VirtualFileSystem
{
    public var storage:FlxSave;
    public var done:Bool = false;

    public function new() 
    {
        storage = new FlxSave();
        storage.bind("virtualFileSystem", "sanicbtw");
        storage.flush();
    }

    public function uploadFile()
    {
        var fr:FileReference = new FileReference();
        fr.addEventListener(Event.SELECT, _onSelect, false, 0, true);
        fr.browse();
    }

    private function _onSelect(E:Event)
    {
        var fr:FileReference = cast(E.target, FileReference);
        fr.addEventListener(Event.COMPLETE, _onLoad, false, 0, true);
        fr.load();
    }

    private function _onLoad(E:Event)
    {
        var fr:FileReference = cast E.target;
        fr.removeEventListener(Event.COMPLETE, _onLoad);
        storage.data.help = [fr.data, fr.data.length];
        storage.flush();
        done = true;
    }
}
#end