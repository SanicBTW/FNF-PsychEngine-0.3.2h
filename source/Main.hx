package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.tweens.FlxTween;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextFormat;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = features.PermissionsPrompt;
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var fpsVar:FPS;
	public static var memoryVar:MemoryCounter;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		SaveData.loadDefaultKeys();
		FlxGraphic.defaultPersist = true;
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		fpsVar = new FPS(10, 8, 0xFFFFFF);
		fpsVar.width = gameWidth; //lmfao what
		addChild(fpsVar);
		if (fpsVar != null)
		{
			fpsVar.visible = SaveData.get(SHOW_FRAMERATE);
			fpsVar.alpha = 0;
		}

		memoryVar = new MemoryCounter(10, 20);
		memoryVar.width = gameWidth; //lmfao what
		addChild(memoryVar);
		if (memoryVar != null)
		{
			memoryVar.visible = SaveData.get(SHOW_MEMORY);
			memoryVar.alpha = 0;
		}

		// what
		Lib.current.stage.align = TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		FlxG.fixedTimestep = false; // when going leaving playstate there is not set timestep back to true so lets just set it to false globally
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = true;
		#if !android
		FlxG.autoPause = false;
		#end
		FlxG.log.redirectTraces = true;
	}

	// deez comin from fof repo, i liked it
	public static function tweenFPS(show:Bool = true, duration:Float = 1)
	{
		if (SaveData.get(SHOW_FRAMERATE) && fpsVar != null)
		{
			if (show)
			{
				FlxTween.tween(fpsVar, {alpha: 1}, duration);
			}
			else
			{
				FlxTween.tween(fpsVar, {alpha: 0}, duration);
			}
		}
	}

	public static function tweenMemory(show:Bool = true, duration:Float = 1)
	{
		if (SaveData.get(SHOW_MEMORY) && memoryVar != null)
		{
			if (show)
			{
				FlxTween.tween(memoryVar, {alpha: 1}, duration);
			}
			else
			{
				FlxTween.tween(memoryVar, {alpha: 0}, duration);
			}
		}
	}

	// goofy name "counters_font" tf bro
	public static function setFonts()
	{
		var size:Int = 12;
		var name:String = SaveData.get(COUNTERS_FONT);
		switch (SaveData.get(COUNTERS_FONT))
		{
			case "Funkin":
				size = 18;
			case "VCR OSD Mono":
				size = 18;
			case "Pixel":
				size = 10;
				name = "Pixel Arial 11 Bold";
			case "Sans":
				name = "_sans";
		}

		fpsVar.defaultTextFormat = new TextFormat(name, size, 0xFFFFFF);
		fpsVar.embedFonts = true;

		memoryVar.defaultTextFormat = new TextFormat(name, size, 0xFFFFFF);
		memoryVar.embedFonts = true;
	}
}