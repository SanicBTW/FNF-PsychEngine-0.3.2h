// from plasma engine, check it out
// modified
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

enum NotificationType
{
	Error;
	Warn;
	Warning;
	Info;
	Information;
}

class Notification extends FlxSpriteGroup
{
	public var box:FlxSprite;

	var icon:FlxSprite;

	var title:FlxText;
	var description:FlxText;

	public var shouldDie:Bool = false;

	var scales = [3, 3];

	/**
		Creates a new notification with a title of `title`, description of `description`, and type of `type`.

		@param title             The title of this notification.
		@param description       The description of this notification.
		@param type              The type of this notification. (Can be `Error`, `Warn`, or `Info`.)
	**/
	public function new(title:String, ?description:String, type:NotificationType = Info)
	{
		super();

		// in case paths has another level
		box = new FlxSprite().loadGraphic(Paths.getPreloadPath("images/notificationBox.png"));
		box.scale.set(scales[0], scales[1]);
		box.updateHitbox();
		box.x = FlxG.width - (box.width - 100);
		add(box);

		icon = new FlxSprite(box.x + 13, box.y + 13);
		icon.loadGraphic(Paths.getPreloadPath('images/notificationIcons.png'), true, 16, 16);
		icon.animation.add("warn", [0], 24);
		icon.animation.add("error", [1], 24);
		icon.animation.add("info", [2], 24);

		switch (type)
		{
			case Error:
				icon.animation.play("error");
			case Warn | Warning:
				icon.animation.play("warn");
			case Info | Information:
				icon.animation.play("info");
		}

		icon.scale.set(scales[0], scales[1]);
		icon.updateHitbox();
		add(icon);

		this.title = new FlxText(icon.x + (icon.width + 5), icon.y - 5, 0, title);
		this.title.setFormat(Paths.font("vcr.ttf"), 20);
		this.title.antialiasing = SaveData.get(ANTIALIASING);
		add(this.title);

		this.description = new FlxText(this.title.x, this.title.y + 30, 0, description);
		this.description.setFormat(Paths.font("vcr.ttf"), 14);
		this.description.antialiasing = SaveData.get(ANTIALIASING);
		add(this.description);

		x = box.width;

		FlxTween.tween(this, {x: 0}, 1, {ease: FlxEase.cubeOut});
		die(4);
	}

	public function die(delay:Float = 4)
	{
		FlxTween.tween(this, {x: box.width}, 1, {
			ease: FlxEase.cubeIn,
			startDelay: delay,
			onComplete: function(twn:FlxTween)
			{
				shouldDie = true;
			}
		});
	}
}
