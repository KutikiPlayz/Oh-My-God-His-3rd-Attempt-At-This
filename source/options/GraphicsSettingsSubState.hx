package options;

import openfl.Lib;
import objects.Character;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			'bool'); //Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			'bool');
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Shaders', //Name
			"If unchecked, disables shaders.\nIt's used for some visual effects, and also CPU intensive for weaker PCs.", //Description
			'shaders',
			'bool');
		addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a shitty Graphics Card.", //Description
			'cacheOnGPU',
			'bool');
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Resolution',
			"Pretty self explanatory, isn't it?",
			'resolutionOption',
			'int');
		addOption(option);

		option.minValue = 0;
		option.maxValue = 4;
		option.defaultValue = 0;
		option.displayFormat = getResolution(ClientPrefs.data.resolutionOption, true);
		option.onChange = function() {
			var resolution = getResolution(ClientPrefs.data.resolutionOption);
			ClientPrefs.data.resolution = resolution;
			option.displayFormat = getResolution(ClientPrefs.data.resolutionOption, true);

			var resArray:Array<Int> = cast resolution;
			FlxG.resizeWindow(resArray[0], resArray[1]);
			FlxG.resizeGame(resArray[0], resArray[1]);

			var displaySize = Lib.application.window.display.bounds;
			Lib.application.window.move(Std.int(displaySize.width / 2 - resArray[0] / 2), Std.int(displaySize.height / 2 - resArray[1] / 2));
		};

		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerateOption',
			'int');
		addOption(option);

		option.minValue = 0;
		option.maxValue = 5;
		option.defaultValue = 0;
		option.displayFormat = getFramerate(ClientPrefs.data.framerateOption, true);
		option.onChange = function() {
			var framerate = getFramerate(ClientPrefs.data.framerateOption);
			ClientPrefs.data.framerate = framerate;
			option.displayFormat = framerate == 999 ? 'Uncapped' : '$framerate FPS';
	
			if(ClientPrefs.data.framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = ClientPrefs.data.framerate;
				FlxG.drawFramerate = ClientPrefs.data.framerate;
			}
			else
			{
				FlxG.drawFramerate = ClientPrefs.data.framerate;
				FlxG.updateFramerate = ClientPrefs.data.framerate;
			}
		};
		#end

		super();
		insert(1, boyfriend);
	}

	function getResolution(option:Int, asText:Bool = false):Any {
		var resolution:Any;
		if (asText) resolution = "1280 x 720 HD";
		else resolution = [1280, 720];
		switch (option) {
			case 0:
				if (asText) resolution = "640 x 360";
				else resolution = [640, 360];
			case 1:
				if (asText) resolution = "1280 x 720 HD";
				else resolution = [1280, 720];
			case 2:
				if (asText) resolution = "1920 x 1080 Full HD";
				else resolution = [1920, 1080];
			case 3:
				if (asText) resolution = "2560 x 1440 2K";
				else resolution = [2560, 1440];
			case 4:
				if (asText) resolution = "3840 x 2160 4K";
				else resolution = [3840, 2160];
		}
		return resolution;
	}

	function getFramerate(option:Int, asText:Bool = false):Any {
		var framerate = "";
		switch (option) {
			case 0:
				framerate = "60" + (asText ? " FPS" : "");
			case 1:
				framerate = "75" + (asText ? " FPS" : "");
			case 2:
				framerate = "120" + (asText ? " FPS" : "");
			case 3:
				framerate = "144" + (asText ? " FPS" : "");
			case 4:
				framerate = "240" + (asText ? " FPS" : "");
			case 5:
				framerate = asText ? "Uncapped" : "999";
		}
		return asText ? framerate : Std.parseInt(framerate);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}