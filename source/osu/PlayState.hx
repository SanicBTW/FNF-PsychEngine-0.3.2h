package osu;

import Section.SwagSection;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
#if windows
import Discord.DiscordClient;
#end
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import Song.SwagSong;

//just a copy of the playstate but with strums only lol
class OSUPlayState extends MusicBeatState
{
    public static var ratingStuff:Array<Dynamic> = 
    [
		['F', 0.2], //From 0% to 19%
		['E', 0.4], //From 20% to 39%
		['E+', 0.5], //From 40% to 49%
		['B', 0.6], //From 50% to 59%
		['B+', 0.69], //From 60% to 68%
		['Nicee', 0.7], //69%
		['A', 0.8], //From 70% to 79%
		['A+', 0.9], //From 80% to 89%
		['S', 1], //From 90% to 99%
		['S+', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

    public static var SONG:SwagSong = null;
    public var vocals:FlxSound;
	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;
	private var lastSection:Int = 0;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

    private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

    private var health:Float = 1;
	private var combo:Int = 0;

    var songPercent:Float = 0;
	private var timeBarBG:AttachedSprite;
	private var timeBar:FlxBar;
	private var generatedMusic:Bool = false;
	private var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;

    public static var practiceMode:Bool = false;
	public static var cpuControlled:Bool = false;

    var botplaySine:Float = 0;
	var botplayTxt:FlxText;

    public var camHUD:FlxCamera;
	public var camOther:FlxCamera;

    public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;

    var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

    public static var deathCounter:Int = 0;

    var songLength:Float = 0;

    public static var displaySongName:String = "";

	#if desktop
	// Discord RPC variables
	var difficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

    public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

    public static var inst:Dynamic = null;
	public static var voices:Dynamic = null;
	public static var lastRating:FlxSprite;
	public static var lastScore:Array<FlxSprite> = [];

    var mashViolations:Int = 0;

	override public function create()
	{
		super.create();

		PauseSubState.songName = null;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		practiceMode = false;
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		persistentUpdate = true;
		persistentDraw = true;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		var songName:String = SONG.song;
		displaySongName = StringTools.replace(songName, '-', ' ');

		#if desktop
		difficultyText = 'Hard';
		detailsText = "OSU! Mode";
		detailsPausedText = "Paused - " + detailsText;
		#end

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(-278, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll)
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		//UI Will change I promise
		timeTxt = new FlxText(42 + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("funkin.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if (ClientPrefs.downScroll)
			timeTxt.y = FlxG.height - 45;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; // How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;	

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		//Health bar indicator would be like some red vignette or something

		scoreTxt = new FlxText(0, FlxG.height * 0.89 + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("funkin.otf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("funkin.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if (ClientPrefs.downScroll)
		{
			botplayTxt.y = timeBarBG.y - 78;
		}

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		#if android
		addAndroidControls();
		androidControls.visible = false;
		addPadCamera();
		#end

		startingSong = true;
		updateTime = true;

		startCountdown();
		//RecalculateRating();

		if (ClientPrefs.missVolume > 0)
		{
			CoolUtil.precacheSound('missnote1');
			CoolUtil.precacheSound('missnote2');
			CoolUtil.precacheSound('missnote3');
		}

		if (ClientPrefs.hitsoundVolume > 0)
			CoolUtil.precacheSound('hitsound');

		if (PauseSubState.songName != null)
			CoolUtil.precacheMusic(PauseSubState.songName);
		else if (ClientPrefs.pauseMusic != null)
			CoolUtil.precacheMusic(Paths.formatToSongPath(ClientPrefs.pauseMusic));

		#if desktop
		DiscordClient.changePresence(detailsText, displaySongName + " (" + difficultyText + ")", " ");
		#end

		CustomFadeTransition.nextCamera = camOther;
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	function startCountdown()
	{
		if(startedCountdown)
			return;

		#if android
		androidControls.visible = true;
		#end

		generateStaticArrows();

		for (i in 0...opponentStrums.length)
		{
			opponentStrums.members[i].visible = false;
		}

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			var antialias:Bool = ClientPrefs.globalAntialiasing;

			switch(swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ready"));
					ready.cameras = [camHUD];
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.screenCenter();
					ready.antialiasing = antialias;
					insert(members.indexOf(notes), ready);
					FlxTween.tween(ready, {y: ready.y + 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("set"));
					set.cameras = [camHUD];
					set.scrollFactor.set();
					set.updateHitbox();
					set.screenCenter();
					set.antialiasing = antialias;
					insert(members.indexOf(notes), set);
					FlxTween.tween(set, {y: set.y + 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("go"));
					go.cameras = [camHUD];
					go.scrollFactor.set();
					go.updateHitbox();
					go.screenCenter();
					go.antialiasing = antialias;
					insert(members.indexOf(notes), go);
					FlxTween.tween(go, {y: go.y + 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
			}

			if (generatedMusic)
			{
				notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
			}

			swagCounter += 1;
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong()
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		FlxG.sound.playMusic(inst, 1, false);
		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if (paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		DiscordClient.changePresence(detailsText, displaySongName + " (" + difficultyText + ")", " ", true, songLength);
		#end
	}

	function generateSong(dataPath:String)
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(voices);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(inst));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var daBeats:Int = 0;

		for(section in noteData)
		{
			for(songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1)
				{
					var strumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if(songNotes[1] > 3)
						gottaHitNote = !section.mustHitSection;

					var oldNote:Note;
					if(unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(strumTime, daNoteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set();

					var sustLength:Float = swagNote.sustainLength;

					sustLength = sustLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSust:Int = Math.floor(sustLength);
					
					if(floorSust > 0)
					{
						for(sustNote in 0...floorSust + 2)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(strumTime
								+ (Conductor.stepCrochet * sustNote)
								+ (Conductor.stepCrochet / FlxMath.roundDecimal(SONG.speed, 2)), daNoteData,
								oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.scrollFactor.set();

							unspawnNotes.push(sustainNote);

							if(sustainNote.mustPress)
								sustainNote.x += FlxG.width / 2;

							if(sustLength < sustNote)
								sustainNote.isLiftNote = true;
						}
					}

					if(swagNote.mustPress)
						swagNote.x += FlxG.width / 2;
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function generateStaticArrows()
	{
		for(i in 0...4)
		{
			var babyArrow:StrumNote = new StrumNote(-278, strumLine.y, i);

			var skin:String = 'NOTE_assets';
			if (SONG.arrowSkin != null && SONG.arrowSkin.length > 1)
				skin = SONG.arrowSkin;

			if(Paths.getSparrowAtlas(skin) == null)
				skin = "NOTE_assets";

			babyArrow.frames = Paths.getSparrowAtlas(skin);
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

			babyArrow.antialiasing = ClientPrefs.globalAntialiasing;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circInOut});

			babyArrow.ID = i;

			playerStrums.add(babyArrow);

			babyArrow.playAnim('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * 0); //huh

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if(paused)
		{
			if(FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if(!startTimer.finished)
				startTimer.active = false;
			if(finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			super.openSubState(SubState);
		}
	}

	override function closeSubState()
	{
		if(paused)
		{
			if(FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if(!startTimer.finished)
				startTimer.active = true;
			if(finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			paused = false;

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, displaySongName
					+ " ("
					+ difficultyText
					+ ")", " ", true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + difficultyText + ")", " ");
			}
			#end
		}

		super.closeSubState();
	}

	override function onFocus()
	{
		#if windows
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, displaySongName
					+ " ("
					+ difficultyText
					+ ")", " ", true,
					songLength
					- Conductor.songPosition
					- ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, displaySongName + " (" + difficultyText + ")", " ");
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost()
	{
		#if windows
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + difficultyText + ")", " ");
		}
		#end

		if (!paused && startedCountdown && canPause && ClientPrefs.pauseOnFocusLost)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			openSubState(new PauseSubState(0, 0));

			#if windows
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + difficultyText + ")", " ");
			#end
		}
		
		super.onFocusLost();
	}

	function resyncVocals()
	{
		if(finishTimer != null)
			return;

		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		scoreTxt.text = getScoreTextFormat();

		if(cpuControlled)
		{
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 * Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			openSubState(new PauseSubState(0, 0));

			#if windows
			DiscordClient.changePresence(detailsPausedText, displaySongName + " (" + difficultyText + ")", " ");
			#end
		}

		
	}
}