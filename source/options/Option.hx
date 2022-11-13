package options;

import Controls;
import flash.text.TextField;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import lime.utils.Assets;

using StringTools;

class Option
{
	private var child:Alphabet;

	public var text(get, set):String;
	public var onChange:Void->Void = null;

	public var type(get, default):String = 'bool';

	public var showBoyfriend:Bool = false;
	public var scrollSpeed:Float = 50;

	private var variable:SaveData.Settings = null;

	public var defaultValue:Dynamic = null;

	public var curOption:Int = 0;
	public var options:Array<String> = null;
	public var changeValue:Dynamic = 1;
	public var minValue:Dynamic = null;
	public var maxValue:Dynamic = null;
	public var decimals:Int = 1;

	public var displayFormat:String = '%v';
	public var description:String = '';
	public var name:String = 'Unknown';

	public function new(name:String, description:String = '', variable:SaveData.Settings, type:String = 'bool', defaultValue:Dynamic = 'null variable value',
			?options:Array<String> = null)
	{
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;
		this.options = options;

		if (defaultValue == 'null variable value')
		{
			switch (type)
			{
				case 'bool':
					defaultValue = false;
				case 'int' | 'float':
					defaultValue = 0;
				case 'percent':
					defaultValue = 1;
				case 'string':
					defaultValue = '';
					if (options.length > 0)
						defaultValue = options[0];
			}
		}

		if (getValue() == null)
			setValue(defaultValue);

		switch (type)
		{
			case 'string':
				var num:Int = options.indexOf(getValue());
				if (num > -1)
					curOption = num;

			case 'percent':
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;
		}
	}

	public function change()
	{
		if (onChange != null)
			onChange();
	}

	public function getValue():Dynamic
	{
		return SaveData.get(variable);
	}

	public function setValue(value:Dynamic)
	{
		SaveData.set(variable, value);
	}

	public function setChild(child:Alphabet)
	{
		this.child = child;
	}

	private function get_text()
	{
		if (child != null)
			return child.text;
		return null;
	}

	private function set_text(newValue:String = '')
	{
		if (child != null)
			child.changeText(newValue);
		return null;
	}

	private function get_type()
	{
		var newValue:String = 'bool';
		switch (type.toLowerCase().trim())
		{
			case 'int' | 'float' | 'percent' | 'string':
				newValue = type;
			case 'integer':
				newValue = 'int';
			case 'str':
				newValue = 'string';
			case 'fl':
				newValue = 'float';
		}
		type = newValue;
		return type;
	}
}
