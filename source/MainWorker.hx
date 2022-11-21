package;

import haxe.Timer;
import js.html.ErrorEvent;
import js.html.MessageEvent;
import js.html.URL;
import js.html.Blob;
import js.html.Worker;

//https://stackoverflow.com/a/6454685 

// this class manages the main worker (js only atm, maybe cpp support soon???)
class MainWorker
{
    // yeah i want this code to be idented too okay?
    private static var workerCode:String = 
    '
        function parseNotes(e)
        {
            var toData = [];
            var int = 0;
            var map = e[2];
            for(let i = e[0]; i < e[1]; i++)
            {
                toData[int] = 
                [
                    parseInt(line(map[i], 2, ",")),
                    convertNote(line(map[i], 0, ",")),
                    parseFloat(line(map[i], 5, ",")) - parseFloat(line(map[i], 2, ","))
                ];

                if (toData[int][2] < 0)
                    toData[int][2] = 0;

                int++;
            }
            int = 0;

            self.postMessage(toData);
        }

        function makeChart(e)
        {
            var song = e[0];
            var data = e[1];

            var sectionNote = 0;
            for (let section = 0;; section++)
            {
                song.notes[section] = 
                {
                    typeOfSection: 0,
                    sectionBeats: 4,
                    sectionNotes: [],
                    mustHitSection: true,
                    gfSection: false,
                    altAnim: false,
                    changeBPM: false,
                    bpm: song.bpm
                };

                for (let note = 0; note < data.length; note++)
                {
                    if 
                    (
                        data[note][0] <= ((section + 1) * (4 * (1000 * 60 / song.bpm)))
                        &&
                        data[note][0] > ((section) * (4 * (1000 * 60 / song.bpm)))
                    )
                    {
                        song.notes[section].sectionNotes[sectionNote] = data[note];
                        sectionNote++;
                    }
                }
                sectionNote = 0;

                if (data[data.length - 1] == song.notes[section].sectionNotes[song.notes[section].sectionNotes.length - 1])
                {
                    self.postMessage(song);
                    break;
                }
            }
        }

        function numberArray(min, max)
        {
            var shit = [];
            for (let i = min; i < max + 1; i++)
                shit.push(i);

            return shit;
        }

        function line(string, index, split)
        {
            var arr = string.split(split);
            return arr[index];
        }

        function convertNote(from_note)
        {
            from_note = parseInt(from_note);
            var noteArray = 
            [
                numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511),
                numberArray(0, 127), numberArray(128, 255), numberArray(256, 383), numberArray(384, 511)
            ];

            for (let i = 0; i < noteArray.length; i++)
                for (let i2 = 0; i2 < noteArray[i].length; i2++)
                    if (noteArray[i][i2] == from_note)
                        return i;

            return 0;
        }

        self.onmessage = function(E)
        {
            var args = E.data.task.split(" ");
            switch(args[0])
            {
                case "Execute":
                    switch(args[1])
                    {
                        case "Parse":
                            parseNotes(E.data.args);
                            break;
                        case "Make_Chart":
                            makeChart(E.data.args);
                            break;
                        default:
                            self.postMessage("Couldnt find a function to execute (executing " + args[1] + ")");
                            break;
                    }
                    break;
                default:
                    self.postMessage("No argument called " + args[0]);
                    break;
            }
        }
    ';

    private static var worker:Worker = null;

    public static var onMessageCB(default, set):Dynamic = null;

    private static function set_onMessageCB(value:Dynamic):Dynamic
    {
        if (worker != null)
        {
            // just to be sure
            worker.removeEventListener('message', (onMessageCB != null ? onMessageCB : onMessage));
            worker.addEventListener('message', value);
            if (onMessageCB != value)
            {
                if (value == "r")
                    onMessageCB = onMessage;
                else
                    onMessageCB = value;
            }
        }
        return value;
    }

    public static function startWorker()
    {
        var blob = new Blob([workerCode], { type: 'text/javascript' });
        if (worker == null)
            worker = new Worker(URL.createObjectURL(blob));

        // wtf is onmessageerror tf
        worker.addEventListener('message', onMessage);
        worker.addEventListener('error', onError);

        // people say that this starts the worker dunno if its true tho
        worker.postMessage({task: ''});
    }

    private static function onMessage(E:MessageEvent)
    {
        trace("MAINWORKER: " + E.data);
    }

    private static function onError(E:ErrorEvent)
    {
        trace("MAINWORKER EXC: " + E.message + " AT " + E.lineno + ":" + E.colno);
    }

    // maybe do some lowercase here or in js code??
    public static function execute(run:String, ?args:Null<Array<Dynamic>>)
        worker.postMessage({task: "Execute " + run, args: args});
}