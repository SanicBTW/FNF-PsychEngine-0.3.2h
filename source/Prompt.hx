package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Prompt extends FlxSpriteGroup
{
	public var titleTxt:FlxText;
	public var infoTxt:FlxText;

	// For ok cancel stuff
	private var okcBtns:FlxSprite;
	private var okButtonReg:FlxSprite;
	private var cancelButtonReg:FlxSprite;

	private var upBtn:FlxSprite;
	private var downBtn:FlxSprite;

	// I changed these to avoid having to make more callbacks
	// button 1 is the ok button or the up button
	public var b1Callback:Void->Void = function()
	{
		trace("Pressed ok button or up button");
	}

	// button 2 is the cancel button or the down button
	public var b2Callback:Void->Void = function()
	{
		trace("Pressed cancel button or down button");
	}

	private var executeCb:Void->Void = null;

	public function new(title:String = "Placeholder", info:String = "Placeholder", buttonType:ButtonType = OK_CANCEL)
	{
		super();

		var bg = new FlxSprite().loadGraphic(Paths.image("ui/promptbg"));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		// i didnt understand this one, why is it above 100 and the info text is below 50 :skull:
		titleTxt = new FlxText(bg.x + 105, bg.y + 30, bg.width - 132, title, 25);
		titleTxt.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.BLACK, LEFT);
		titleTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(titleTxt);

		infoTxt = new FlxText(bg.x + 12, titleTxt.y + 50, bg.width - 32, info, 20);
		infoTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.BLACK, LEFT);
		infoTxt.antialiasing = ClientPrefs.globalAntialiasing;
		add(infoTxt);

		switch (buttonType)
		{
			case OK_CANCEL:
				okcBtns = new FlxSprite(bg.x + 15, bg.y + 260);
				okcBtns.frames = Paths.getSparrowAtlas('ui/prompt_buttons');
				okcBtns.animation.addByIndices('but0', 'buttons', [0], '', 0);
				okcBtns.animation.addByIndices('but1', 'buttons', [1], '', 0);
				okcBtns.animation.play('but0', true);
				okcBtns.antialiasing = ClientPrefs.globalAntialiasing;
				add(okcBtns);

				okButtonReg = new FlxSprite(okcBtns.x, okcBtns.y).makeGraphic(Std.int(okcBtns.width / 2), Std.int(okcBtns.height), FlxColor.TRANSPARENT);
				add(okButtonReg);

				cancelButtonReg = new FlxSprite(okcBtns.x + (okcBtns.width / 2),
					okcBtns.y).makeGraphic(Std.int(okcBtns.width / 2), Std.int(okcBtns.height), FlxColor.TRANSPARENT);
				add(cancelButtonReg);
			case UP_DOWN:
				downBtn = new FlxSprite(bg.x + 15, bg.y + 275).loadGraphic(Paths.image("ui/butt_graph0001"));
				downBtn.antialiasing = ClientPrefs.globalAntialiasing;
				add(downBtn);

				upBtn = new FlxSprite(downBtn.x + 285, downBtn.y).loadGraphic(Paths.image("ui/butt_graph0002"));
				upBtn.antialiasing = ClientPrefs.globalAntialiasing;
				add(upBtn);
			case NONE:
				// do nothing
		}
	}

	override function update(elapsed:Float)
	{
		if (okcBtns != null && okButtonReg != null && cancelButtonReg != null)
		{
			if (FlxG.mouse.overlaps(okButtonReg) || FlxG.mouse.overlaps(cancelButtonReg))
			{
				var prevAnim = okcBtns.animation.curAnim.name;
				okcBtns.animation.play(FlxG.mouse.overlaps(okButtonReg) ? "but0" : "but1", true);
				if (okcBtns.animation.curAnim.name == "but0" && prevAnim == "but1")
				{
					executeCb = b1Callback;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (okcBtns.animation.curAnim.name == "but1" && prevAnim == "but0")
				{
					executeCb = b2Callback;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (FlxG.mouse.justPressed)
				{
					executeCb();
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			}
		}

		if (upBtn != null && downBtn != null)
		{
			if (FlxG.mouse.overlaps(upBtn))
			{
				upBtn.alpha = 1;
				// bruh wtf - its to avoid setting the execute callback to the same thing all the time lol
				if (executeCb != b1Callback)
				{
					executeCb = b1Callback;
				}

				if (FlxG.mouse.justPressed)
				{
					executeCb();
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			else
			{
				upBtn.alpha = 0.6;
			}

			if (FlxG.mouse.overlaps(downBtn))
			{
				downBtn.alpha = 1;
				if (executeCb != b2Callback)
				{
					executeCb = b2Callback;
				}

				if (FlxG.mouse.justPressed)
				{
					executeCb();
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			else
			{
				downBtn.alpha = 0.6;
			}
		}

		super.update(elapsed);
	}
}

@:enum abstract ButtonType(String) to String
{
	var OK_CANCEL;
	var UP_DOWN;
	var NONE;
}
