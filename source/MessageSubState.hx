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

class MessageSubState extends MusicBeatState
{
	var message = CoolUtil.coolTextFile(Paths.txt('message'));
	public static var leftStateMessage:Bool = false;
	override function create()
	{
		super.create();

		var txt:FlxText = new FlxText(0, 0, FlxG.width,message[0],32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.fromRGB(200, 200, 200), CENTER);
		txt.borderColor = FlxColor.BLACK;
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			leftStateMessage = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}

