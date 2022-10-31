package substates;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class SubstatesMenu extends MusicBeatSubstate
{
    var grpSubShit:FlxTypedGroup<Alphabet>;
    var menuItems:Array<String> = ["Reset Score", "Gameplay Changers"];
    var curSelected:Int = 0;
    var args:Array<Dynamic>;

    public function new(args:Array<Dynamic> = null)
    {
        super();

        this.args = args;

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.6;
        bg.scrollFactor.set();
        add(bg);

        grpSubShit = new FlxTypedGroup<Alphabet>();
        add(grpSubShit);

        for (i in 0...menuItems.length)
        {
            var subText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
            subText.isMenuItem = true;
            subText.targetY = i;
            grpSubShit.add(subText);
        }

        changeSelection();

        #if android
		addVirtualPad(UP_DOWN, A_B);
		addPadCamera();
		#end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.UI_UP_P)
            changeSelection(-1);
        if (controls.UI_DOWN_P)
            changeSelection(1);

        if (controls.ACCEPT)
        {
            switch(menuItems[curSelected])
            {
                case "Reset Score":
                    if (args == null)
                        return;
                    openSubState(new ResetScoreSubState(args[0], args[1], args[3]));
                case "Gameplay Changers":
                    openSubState(new GameplayChangersSubstate());
            }
        }

        if (controls.BACK)
        {
            FlxTransitionableState.skipNextTransOut = true;
            FlxG.resetState();
            FlxG.sound.play(Paths.sound('cancelMenu'), 1);
            close();
        }
    }

    override function destroy()
    {
        #if android
        removeVirtualPad();
        #end

        super.destroy();
    }

    function changeSelection(change:Int = 0)
    {
        curSelected += change;

        if (curSelected < 0)
            curSelected = menuItems.length - 1;
        if (curSelected >= menuItems.length)
            curSelected = 0;

        var fuck:Int = 0;

        for (item in grpSubShit.members)
        {
            item.targetY = fuck - curSelected;
            fuck++;

            item.alpha = 0.6;

            if (item.targetY == 0)
                item.alpha = 1;
        }
    }

    override function closeSubState()
    {
        changeSelection(0);
        persistentUpdate = true;
        super.closeSubState();
    }

    override function openSubState(SubState:FlxSubState)
    {
        persistentUpdate = false;
		super.openSubState(SubState);
    }
}