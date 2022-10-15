package options;

using StringTools;

class CameraSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Camera Settings';
		rpcTitle = 'Camera Settings Menu'; //for Discord Rich Presence

        var option:Option = new Option('Camera Zooms',
            "If unchecked, the camera won't zoom in on a beat hit.",
            "camZooms",
            "bool",
            true);
        addOption(option);

        var option:Option = new Option("Smooth Camera Zooms",
            "If you want Psych cam zooms or Kade cam zooms",
            "smoothCamZoom",
            "bool",
            true);
        addOption(option);

        var option:Option = new Option("Camera Movement",
            "Moves the camera to the strum direction",
            "cameraMovement",
            "bool",
            true);
        addOption(option);

        var option:Option = new Option("Snap Camera when Game Over",
            "Snaps the camera on BF when he is dead",
            "snapCameraOnGameover",
            "bool",
            true);
        addOption(option);

		super();
	}
}