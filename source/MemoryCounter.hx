package;

import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

class MemoryCounter extends TextField
{
    var memPeak:Float = 0;

    public function new(xPos:Float, yPos:Float)
    {
        super();

        x = xPos;
        y = yPos;
        width = 200;
        height = 70;

        selectable = false;

        defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF);
        text = "";

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    function onEnterFrame(_) 
    {
        var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;
        if(mem > memPeak)
            memPeak = mem;

        if(visible)
        {
            text = "Memory: " + mem + " MB\nPeak Memory: " + memPeak + " MB";
        }
    }
}