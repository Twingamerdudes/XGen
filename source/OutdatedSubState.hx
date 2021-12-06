/*package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		var ver = "v" + Application.current.meta.get('version');
		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"HEY! You're running an outdated version of the game!\nCurrent version is "
			+ ver
			+ " while the most recent version is "
			+ NGio.GAME_VER
			+ "! Press Space to go to itch.io, or ESCAPE to ignore this!!",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.openURL("https://ninja-muffin24.itch.io/funkin");
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
} */
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	public static var needVer:String = "your mum";
	public static var currChanges:String = "not used, yay (I think).";

	private var bgColors:Array<String> = ['#314d7f', '#4e7093', '#70526e', '#594465'];
	private var colorRotation:Int = 1;

	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.imageJpg('bruh2', 'shared'));
		bg.scale.x *= 1.55;
		bg.scale.y *= 1.55;
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		var txt:FlxText = new FlxText(0, 0, FlxG.width,
			"XGen has updated, you should be on "
			+ needVer
			+ "\n But your on "
			+ MainMenuState.xGenVersion
			+ "."
			+ "Go and get the new version, trust me, it's more dope then your pp."
			+ " Press enter to get directed to new version, "
			+ "Or be a pussy and press escape to contiune playing on this outdate version.",
			32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);

		FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			FlxTween.color(bg, 2, bg.color, FlxColor.fromString(bgColors[colorRotation]));
			if (colorRotation < (bgColors.length - 1))
				colorRotation++;
			else
				colorRotation = 0;
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			fancyOpenURL("https://github.com/Twingamerdudes/XGen/blob/main/CHANGELOG.md");
		}
		else if (controls.ACCEPT)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}

