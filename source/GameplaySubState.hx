package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import MusicBeatState;
import lime.utils.Assets;
class GameplaySubState extends FlxSubState
{
	var textMenuItems:Array<String> = ['FPS', 'Back'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;


	var botplayOptionsEnabledTxt:Alphabet;
	var ghostTappingEnabledTxt:Alphabet;

    var fpsCounter:Alphabet;

	var FPS:Int = Std.parseInt(CoolUtil.coolTextFileString(Paths.txt('options/fps')));
	var fpsText:FlxText;

	public static var MUSICBEATSTATE:MusicBeatState;
	public function new()
	{
		super();
		
		grpOptionsTexts = new FlxTypedGroup<Alphabet>();
		add(grpOptionsTexts);


		selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
			var optionText:Alphabet = new Alphabet(20, 20 + (i * 100), textMenuItems[i], true, false);
			optionText.ID = i;

			optionText.isMenuItem = true;
			optionText.targetY = i;
			
            trace(optionText.text);
			grpOptionsTexts.add(optionText);
		}
		fpsText = new FlxText(950, 30, 0, "", 80);
		fpsText.setFormat(Paths.font("phantommuffin.ttf"), 80, FlxColor.WHITE, RIGHT);
		fpsText.scrollFactor.set();
		add(fpsText);
		/*botplayOptionsEnabledTxt = new Alphabet(400, 70, "", false, false);
		botplayOptionsEnabledTxt.scrollFactor.set();
		add(botplayOptionsEnabledTxt);

		ghostTappingEnabledTxt = new Alphabet(400, 20, "", false, false);
		ghostTappingEnabledTxt.scrollFactor.set();
		add(ghostTappingEnabledTxt); */

		/*if(botplayOnOrOffCurrent == "botplay"){
			botplayOnOrOff = "On";
		}else{
			botplayOnOrOff = "Off";
		} 
		if(ghostTappingOnOrOffCurrent == "ghost"){
			ghostTappingOnOrOff = "On";
		}else{
			ghostTappingOnOrOff = "Off";
		} 
		botplayOptionsEnabledTxt.text = botplayOnOrOff;
		ghostTappingEnabledTxt.text = ghostTappingOnOrOff; */
	}
	override function update(elapsed:Float)
		{
			super.update(elapsed);
	
			if (MUSICBEATSTATE.controls.UP_P)
				changeSelection(-1);
				//curSelected -= 1;
	
			if (MUSICBEATSTATE.controls.DOWN_P)
				changeSelection(1);
				//curSelected += 1;

			if(MUSICBEATSTATE.controls.BACK){
				FlxG.state.openSubState(new OptionsSubState());
			}	
			if (curSelected < 0)
				curSelected = textMenuItems.length - 1;
	
			if (curSelected >= textMenuItems.length)
				curSelected = 0;
	
			grpOptionsTexts.forEach(function(txt:Alphabet)
			{
				txt.color = FlxColor.WHITE;
				if (txt.ID == curSelected)
					txt.color = FlxColor.YELLOW;
				else {
					txt.color = FlxColor.WHITE;
				}
			});	
			if (MUSICBEATSTATE.controls.ACCEPT)
			{
				switch (textMenuItems[curSelected])
				{	
					case "Back":
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.state.openSubState(new OptionsSubState());
					case "Note colors":
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.state.openSubState(new NoteColorSubState());
				}
			}
			fpsText.text = "FPS: " + Std.string(FPS);
			if(MUSICBEATSTATE.controls.LEFT){
				if(textMenuItems[curSelected] == "FPS"){
					FPS -= 1;
					sys.io.File.saveContent(Paths.txt('options/fps'), Std.string(FPS));
					FlxG.updateFramerate = Std.parseInt(CoolUtil.coolTextFileString(Paths.txt('options/fps')));
					FlxG.drawFramerate = Std.parseInt(CoolUtil.coolTextFileString(Paths.txt('options/fps')));
					
				}
			}
			if(MUSICBEATSTATE.controls.RIGHT){
				if(textMenuItems[curSelected] == "FPS"){
					FPS += 1;
					sys.io.File.saveContent(Paths.txt('options/fps'), Std.string(FPS));
					FlxG.updateFramerate = Std.parseInt(CoolUtil.coolTextFileString(Paths.txt('options/fps')));
					FlxG.drawFramerate = Std.parseInt(CoolUtil.coolTextFileString(Paths.txt('options/fps')));
				}
			}
		}
	function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu', 'preload'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;
		else if (curSelected >= textMenuItems.length)
			curSelected = 0;

		var stuff:Int = 0;

		for (item in grpOptionsTexts.members)
		{
			item.targetY = stuff - curSelected;
			stuff ++;

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
