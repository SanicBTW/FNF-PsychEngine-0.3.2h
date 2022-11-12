package;

import Conductor.BPMChangeEvent;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import openfl.system.System;
#if android
import android.AndroidControls;
import android.flixel.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
#end

class MusicBeatState extends FlxUIState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public var notificationCamera:FlxCamera;
	public var notificationGroup:FlxTypedGroup<Notification>;

	// private static var instance:MusicBeatState;
	#if android
	var virtualPad:FlxVirtualPad;
	var androidControls:AndroidControls;
	var trackedinputsUI:Array<FlxActionInput> = [];
	var trackedinputsNOTES:Array<FlxActionInput> = [];

	public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode)
	{
		virtualPad = new FlxVirtualPad(DPad, Action);
		add(virtualPad);

		controls.setVirtualPadUI(virtualPad, DPad, Action);
		trackedinputsUI = controls.trackedinputsUI;
		controls.trackedinputsUI = [];
	}

	public function removeVirtualPad()
	{
		if (trackedinputsUI != [])
			controls.removeFlxInput(trackedinputsUI);

		if (virtualPad != null)
			remove(virtualPad);
	}

	public function addAndroidControls()
	{
		androidControls = new AndroidControls();

		switch (AndroidControls.getMode())
		{
			case 0 | 1 | 2: // RIGHT_FULL | LEFT_FULL | CUSTOM
				controls.setVirtualPadNOTES(androidControls.virtualPad, RIGHT_FULL, NONE);
			case 3: // BOTH_FULL
				controls.setVirtualPadNOTES(androidControls.virtualPad, BOTH_FULL, NONE);
			case 4: // HITBOX
				controls.setHitBox(androidControls.hitbox);
			case 5: // KEYBOARD
		}

		trackedinputsNOTES = controls.trackedinputsNOTES;
		controls.trackedinputsNOTES = [];

		var camControls = new flixel.FlxCamera();
		FlxG.cameras.add(camControls);
		camControls.bgColor.alpha = 0;

		androidControls.cameras = [camControls];
		androidControls.visible = false;
		add(androidControls);
	}

	public function removeAndroidControls()
	{
		if (trackedinputsNOTES != [])
			controls.removeFlxInput(trackedinputsNOTES);

		if (androidControls != null)
			remove(androidControls);
	}

	public function addPadCamera()
	{
		if (virtualPad != null)
		{
			var camControls = new flixel.FlxCamera();
			FlxG.cameras.add(camControls);
			camControls.bgColor.alpha = 0;
			virtualPad.cameras = [camControls];
		}
	}
	#end

	override function destroy()
	{
		#if android
		if (trackedinputsNOTES != [])
			controls.removeFlxInput(trackedinputsNOTES);

		if (trackedinputsUI != [])
			controls.removeFlxInput(trackedinputsUI);
		#end

		super.destroy();

		#if android
		if (virtualPad != null)
		{
			virtualPad = FlxDestroyUtil.destroy(virtualPad);
			virtualPad = null;
		}

		if (androidControls != null)
		{
			androidControls = FlxDestroyUtil.destroy(androidControls);
			androidControls = null;
		}
		#end
	}

	override function create()
	{
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new CustomFadeTransition(0.7, true));

		System.gc();

		FlxTransitionableState.skipNextTransOut = false;

		super.create();

		if (notificationCamera == null)
			notificationCamera = new FlxCamera();

		notificationCamera.bgColor = 0x0;

		FlxG.cameras.add(notificationCamera, false);

		if (notificationGroup == null)
			notificationGroup = new FlxTypedGroup<Notification>();

		notificationGroup.cameras = [notificationCamera];
		add(notificationGroup);

		// instance = this;
	}

	override function update(elapsed:Float)
	{
		updateSB();
		updateNotifications();
		checkKeyFuncs();

		super.update(elapsed);
	}

	private function updateSB() // update steps and beats
	{
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}
	}

	private function updateNotifications()
	{
		var dumb:Int = 0;
		if (notificationGroup != null)
		{
			notificationGroup.forEachAlive(function(notification:Notification)
			{
				notification.scrollFactor.set();
				notification.y = 20 + ((notification.box.height + 20) * dumb);

				if (notification.shouldDie)
				{
					notificationGroup.remove(notification, true);
					notification.kill();
					notification.destroy();
				}

				dumb++;
			});
		}
	}

	private function checkKeyFuncs()
	{
		if (FlxG.keys.pressed.CONTROL)
			if (FlxG.mouse.wheel != 0)
				FlxG.sound.changeVolume(FlxG.mouse.wheel * 0.1);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - SaveData.get(NOTE_OFFSET)) - lastChange.songTime) / lastChange.stepCrochet;

		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function switchState(nextState:FlxState)
	{
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if (!FlxTransitionableState.skipNextTransIn)
		{
			leState.openSubState(new CustomFadeTransition(0.6, false));
			if (nextState == FlxG.state)
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.resetState();
				};
			}
			else
			{
				CustomFadeTransition.finishCallback = function()
				{
					FlxG.switchState(nextState);
				};
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState()
	{
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState
	{
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

	public function sectionHit():Void
	{
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
