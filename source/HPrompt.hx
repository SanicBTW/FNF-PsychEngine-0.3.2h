package;
import flixel.*;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIPopup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * @author ShadowMario
 * @co-author SanicBTW
 */
class HPrompt extends MusicBeatSubstate //imagine rewriting this FOR NOTHING, coming from 0.5.2h
{
    //for selecting shit
	var selected = 0;
    public var okCallback:Void->Void;
    public var cancelCallback:Void->Void;
    var goAnyway:Bool = false;

    //ui
    var text:String = "";
    var UI_box:FlxUIPopup;
    var panel:FlxSprite;
    var panelBG:FlxSprite;
    var buttonAccept:FlxButton;
    var buttonNo:FlxButton;
    var cornerSize:Int = 10; //for rounded corners shit

    public function new(promptText:String = "", defaultSelected:Int = 0, okCallback:Void->Void, cancelCallback:Void->Void, acceptOnDefault:Bool = false, option1:String = null, option2:String = null)
    {
        this.selected = defaultSelected;
        this.okCallback = okCallback;
        this.cancelCallback = cancelCallback;
        this.text = promptText;
        this.goAnyway = acceptOnDefault;

        var op1 = "OK";
        var op2 = "CANCEL";

        if(option1 != null) op1 = option1;
        if(option2 != null) op2 = option2;

        buttonAccept = new FlxButton(473.3, 450, op1, function()
        {
            if(this.okCallback != null)
            {
                this.okCallback();
                close();
            }
        });

        buttonNo = new FlxButton(633.3, 450, op2, function()
        {
            if(this.cancelCallback != null)
            {
                this.cancelCallback();
                close();
            }
        });

        super();
    }

    //WHY IS THE ORIGINAL CODE SO BADLY FORMATTED FUCK
    override public function create()
    {
        super.create();

        if(goAnyway)
        {
            if(okCallback != null)
            {
                okCallback();
                close();
            }
        }
        else
        {
            panel = new FlxSprite(0, 0);
            panelBG = new FlxSprite(0, 0);
            makeSelectorGraphic(panel, 300, 150, 0xFF999999);
            makeSelectorGraphic(panelBG, 302, 150, 0xFF000000);

            panel.scrollFactor.set();
            panel.screenCenter();

            panelBG.scrollFactor.set();
            panelBG.screenCenter();

            add(panelBG);
            add(panel);
            add(buttonAccept);
            add(buttonNo);

            var textShit:FlxText = new FlxText(buttonNo.width * 2, panel.y, 300, text, 16);
            textShit.alignment = "center";
            textShit.scrollFactor.set();
            textShit.screenCenter();
            add(textShit);

            buttonAccept.screenCenter();
            buttonNo.screenCenter();

            buttonAccept.x -= buttonNo.width / 1.5;
            buttonAccept.y = panel.y + panel.height - 30;
            buttonNo.x += buttonNo.width / 1.5;
            buttonNo.y = panel.y + panel.height - 30;
        }
    }

    //this is from the original code
    function makeSelectorGraphic(panel:FlxSprite,w,h,color:FlxColor)
	{
		panel.makeGraphic(w, h, color);
		panel.pixels.fillRect(new Rectangle(0, 190, panel.width, 5), 0x0);
		
		panel.pixels.fillRect(new Rectangle(0, 0, cornerSize, cornerSize), 0x0);														 //top left
		drawCircleCornerOnSelector(panel,false, false,color);
		panel.pixels.fillRect(new Rectangle(panel.width - cornerSize, 0, cornerSize, cornerSize), 0x0);							 //top right
		drawCircleCornerOnSelector(panel,true, false,color);
		panel.pixels.fillRect(new Rectangle(0, panel.height - cornerSize, cornerSize, cornerSize), 0x0);							 //bottom left
		drawCircleCornerOnSelector(panel,false, true,color);
		panel.pixels.fillRect(new Rectangle(panel.width - cornerSize, panel.height - cornerSize, cornerSize, cornerSize), 0x0); //bottom right
		drawCircleCornerOnSelector(panel,true, true,color);
	}

	function drawCircleCornerOnSelector(panel:FlxSprite,flipX:Bool, flipY:Bool,color:FlxColor)
	{
		var antiX:Float = (panel.width - cornerSize);
		var antiY:Float = flipY ? (panel.height - 1) : 0;
		if(flipY) antiY -= 2;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 1), Std.int(Math.abs(antiY - 8)), 10, 3), color);
		if(flipY) antiY += 1;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 2), Std.int(Math.abs(antiY - 6)),  9, 2), color);
		if(flipY) antiY += 1;
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 3), Std.int(Math.abs(antiY - 5)),  8, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 4), Std.int(Math.abs(antiY - 4)),  7, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 5), Std.int(Math.abs(antiY - 3)),  6, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 6), Std.int(Math.abs(antiY - 2)),  5, 1), color);
		panel.pixels.fillRect(new Rectangle((flipX ? antiX : 8), Std.int(Math.abs(antiY - 1)),  3, 1), color);
	}
}