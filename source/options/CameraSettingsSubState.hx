package options;

class CameraSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Camera Settings';
		rpcTitle = 'Camera Settings Menu';

		var option:Option = new Option('Camera Zooms', "If unchecked, the camera won't zoom in on a beat hit.", CAMERA_ZOOMS, "bool", true);
		addOption(option);

		var option:Option = new Option("Smooth Camera Zooms", "If you want Psych cam zooms or Kade cam zooms", SMOOTH_CAMERA_ZOOMS, "bool", true);
		addOption(option);

		var option:Option = new Option("Camera Movement", "Moves the camera to the strum direction", CAMERA_MOVEMENT, "bool", true);
		addOption(option);

		var option:Option = new Option("Snap Camera when Game Over", "Snaps the camera on BF when he is dead", SNAP_CAMERA_ON_GAMEOVER, "bool", true);
		addOption(option);

		super();
	}
}
