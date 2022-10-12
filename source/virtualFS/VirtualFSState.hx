package virtualFS;

import openfl.media.Sound;

class VirtualFSState extends MusicBeatState
{
    private var virtFS:VirtualFileSystem;
    var sound:Sound;

    override function create()
    {
        super.create();

        virtFS = new VirtualFileSystem();
        virtFS.uploadFile();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(virtFS.done)
        {
            sound.loadCompressedDataFromByteArray(virtFS.storage.data.help[0], virtFS.storage.data.help[1]);
            sound.play();
        }
    }
}