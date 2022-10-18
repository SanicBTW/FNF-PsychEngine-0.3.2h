package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Prompt extends FlxSpriteGroup
{
	// UI
	public var titleTxt:FlxText;
	public var infoTxt:FlxText;
	private var okcBtns:FlxSprite;
	private var okButtonReg:FlxSprite;
	private var cancelButtonReg:FlxSprite;

	private var upBtn:FlxSprite;
	private var downBtn:FlxSprite;

	private var selector:FlxSprite;
	private var selectorSine:Float = 0; //totally not from botplaysine

	// Functions on pressing buttons
	// button 1 is the ok button or the up button
	public var b1Callback:String->Void = function(promptName:String)
	{
		trace("Pressed ok button or up button, prompt name: " + promptName);
	}

	// button 2 is the cancel button or the down button
	public var b2Callback:String->Void = function(promptName:String)
	{
		trace("Pressed cancel button or down button, prompt name: " + promptName);
	}

	// the callback to execute
	private var executeCb:String->Void = null;

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

				// base the x and y pos of the selector on the ok button as its the main button? uh
				selector = new FlxSprite(okButtonReg.x, okButtonReg.y).makeGraphic(Std.int(okButtonReg.width), Std.int(okButtonReg.height), FlxColor.GRAY);
				selector.alpha = 0.5;
				add(selector);

			/* rewrite
			case UP_DOWN:
				downBtn = new FlxSprite(bg.x + 15, bg.y + 275).loadGraphic(Paths.image("ui/butt_graph0001"));
				downBtn.antialiasing = ClientPrefs.globalAntialiasing;
				add(downBtn);

				upBtn = new FlxSprite(downBtn.x + 285, downBtn.y).loadGraphic(Paths.image("ui/butt_graph0002"));
				upBtn.antialiasing = ClientPrefs.globalAntialiasing;
				add(upBtn);*/
			case NONE:
				// do nothing
		}
	}

	override function update(elapsed:Float)
	{
		if (selector != null)
		{
			selectorSine += 200 * elapsed;
			selector.alpha = 0.5 * Math.sin((Math.PI * selectorSine) / 200);
		}

		if (okcBtns != null && okButtonReg != null && cancelButtonReg != null)
		{
			#if !android
			if (FlxG.mouse.overlaps(okButtonReg) || FlxG.mouse.overlaps(cancelButtonReg))
			{
				executeCb = (FlxG.mouse.overlaps(okButtonReg) ? b1Callback : b2Callback);

				if (FlxG.mouse.overlaps(okButtonReg) && okcBtns.animation.curAnim.name == "but1")
				{
					changeAnim("but0");
					selector.x = okButtonReg.x;
				}
				if (FlxG.mouse.overlaps(cancelButtonReg) && okcBtns.animation.curAnim.name == "but0")
				{
					changeAnim("but1");
					selector.x = cancelButtonReg.x;
				}

				if (FlxG.mouse.justPressed)
				{
					executeCb(this.titleTxt.text);
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
			}
			#else
			for (touch in FlxG.touches.list)
			{
				if (touch.overlaps(okButtonReg) || touch.overlaps(cancelButtonReg))
				{
					executeCb = (touch.overlaps(okButtonReg) ? b1Callback : b2Callback);

					if (touch.overlaps(okButtonReg) && okcBtns.animation.curAnim.name == "but1")
						changeAnim("but0");
					if (touch.overlaps(cancelButtonReg) && okcBtns.animation.curAnim.name == "but0")
						changeAnim("but1");

					// to avoid pressing accidentaly on hovering lol
					if (touch.justReleased)
					{
						executeCb(this.titleTxt.text);
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}
				}
			}
			#end
		}

		/* shit code needs to be rewritten
		if (upBtn != null && downBtn != null)
		{
			#if !android
			if (FlxG.mouse.overlaps(upBtn))
			{
				upBtn.alpha = 1;
				// bruh wtf - its to avoid setting the execute callback to the same thing all the time lol
				if (executeCb != b1Callback)
					executeCb = b1Callback;

				if (FlxG.mouse.justPressed)
				{
					executeCb(this.titleTxt.text);
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
					executeCb = b2Callback;

				if (FlxG.mouse.justPressed)
				{
					executeCb(this.titleTxt.text);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			else
			{
				downBtn.alpha = 0.6;
			}
			#else
			for (touch in FlxG.touches.list)
			{
				if (touch.overlaps(upBtn))
				{
					upBtn.alpha = 1;

					// i doubt its actually working
					if (executeCb != b1Callback)
						executeCb = b1Callback;

					if (touch.justReleased)
					{
						executeCb(this.titleTxt.text);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
				}
				else
				{
					upBtn.alpha = 0.6;
				}

				if (touch.overlaps(downBtn))
				{
					downBtn.alpha = 1;

					if (executeCb != b2Callback)
						executeCb = b2Callback;

					if (touch.justReleased)
					{
						executeCb(this.titleTxt.text);
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
				}
				else
				{
					downBtn.alpha = 0.6;
				}
			}
			#end
		}*/

		super.update(elapsed);
	}

	// move to the old system cuz it works better
	function changeAnim(anim:String)
	{
		okcBtns.animation.play(anim, true);
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}

@:enum abstract ButtonType(String) to String
{
	var OK_CANCEL;
	var NONE;
}