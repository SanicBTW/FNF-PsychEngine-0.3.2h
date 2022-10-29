package;

import features.StorageAccess;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			var fullPath:String = "";
			var file:Dynamic = null;
			#if STORAGE_ACCESS
			if (ClientPrefs.allowFileSys)
			{
				fullPath = haxe.io.Path.join([StorageAccess.getFolderPath(IMAGES), name + ".png"]);

				if (!StorageAccess.exists(fullPath))
				{
					name = "icons/icon-" + char;
					fullPath = haxe.io.Path.join([StorageAccess.getFolderPath(IMAGES), name + ".png"]);
				}
				if (!StorageAccess.exists(fullPath))
				{
					fullPath = "assets/images/";
					if (!Paths.fileExists('images/' + name + '.png', IMAGE))
						name = 'icons/icon-' + char; // Older versions of psych engine's support
					if (!Paths.fileExists('images/' + name + '.png', IMAGE))
						name = 'icons/icon-face'; // Prevents crash from missing icon
					fullPath += name + ".png";
				}

				if (fullPath.contains("assets/"))
					file = AssetManager.returnGraphic(fullPath, false);
				else
					file = AssetManager.returnGraphic(fullPath, true);
			}
			else
			{
				fullPath = "assets/images/";
				if (!Paths.fileExists('images/' + name + '.png', IMAGE))
					name = 'icons/icon-' + char; // Older versions of psych engine's support
				if (!Paths.fileExists('images/' + name + '.png', IMAGE))
					name = 'icons/icon-face'; // Prevents crash from missing icon
				fullPath += name + ".png";
				file = AssetManager.returnGraphic(fullPath, false);
			}
			#else
			fullPath = "assets/images/";
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-' + char; // Older versions of psych engine's support
			if (!Paths.fileExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-face'; // Prevents crash from missing icon
			fullPath += name + ".png";
			file = AssetManager.returnGraphic(fullPath, false);
			#end

			loadGraphic(file); // Load stupidly first for getting the file size
			loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); // Then load it fr
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();

			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if (char.endsWith('-pixel'))
			{
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String
	{
		return char;
	}
}
