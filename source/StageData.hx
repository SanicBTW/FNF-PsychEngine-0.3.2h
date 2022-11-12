package;

import Song;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets;

using StringTools;

typedef StageFile =
{
	var directory:String;
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
	var hide_girlfriend:Bool;
	var camera_boyfriend:Array<Float>;
	var camera_opponent:Array<Float>;
	var camera_girlfriend:Array<Float>;
	var camera_speed:Null<Float>;
}

class StageData
{
	public static var forceNextDirectory:String = null;

	public static function loadDirectory(SONG:SwagSong)
	{
		var stage:String = '';
		if (SONG.stage != null)
		{
			stage = SONG.stage;
		}
		else if (SONG.song != null)
		{
			switch (SONG.song.toLowerCase().replace(' ', '-'))
			{
				case 'spookeez' | 'south' | 'monster':
					stage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					stage = 'limo';
				case 'cocoa' | 'eggnog':
					stage = 'mall';
				case 'winter-horrorland':
					stage = 'mallEvil';
				case 'senpai' | 'roses':
					stage = 'school';
				case 'thorns':
					stage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					stage = "tank";
				default:
					stage = 'stage';
			}
		}
		else
		{
			stage = 'stage';
		}

		var stageFile:StageFile = getStageFile(stage);
		if (stageFile == null)
		{ // preventing crashes
			forceNextDirectory = '';
		}
		else
		{
			forceNextDirectory = stageFile.directory;
		}
	}

	public static function getStageFile(stage:String):StageFile
	{
		#if STORAGE_ACCESS
		if (SaveData.get(ALLOW_FILESYS))
		{
			var extStage = features.StorageAccess.getStage(stage);
			if (extStage != null)
				return extStage;
		}
		else
			return getStageFromAssets(stage);
		#else
		return getStageFromAssets(stage);
		#end

		return getStageFromAssets(stage);
	}

	private static function getStageFromAssets(stage:String)
	{
		var path = Paths.getPreloadPath('stages/' + stage + '.json');

		if (Assets.exists(path))
			return cast Json.parse(Assets.getText(path));
		else
			return null;
	}
}
