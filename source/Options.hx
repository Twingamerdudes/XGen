package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import MusicBeatState;
import lime.utils.Assets;
import flixel.util.FlxSave;
class Options extends FlxSubState
{
	var textMenuItems:Array<String> = ['Ghost Tapping', 'Botplay', 'EARSE DATA', 'Back'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;


	var botplayOptionsEnabledTxt:Alphabet;
	var ghostTappingEnabledTxt:Alphabet;


	var botplayOnOrOff:String = "On";
	var ghostTappingOnOrOff:String = "On";

	var botplayOnOrOffCurrent:String = Assets.getText(Paths.txt('options/botplay'));
	var ghostTappingOnOrOffCurrent:String = Assets.getText(Paths.txt('options/ghost'));

	public static var MUSICBEATSTATE:MusicBeatState;
	public function new()
	{
		super();
		
		#if desktop
		DiscordClient.changePresence("In Options Menu", null);
		#end

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
			
			grpOptionsTexts.add(optionText);
		}
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
				var optionsFileBot:String = Assets.getText(Paths.txt('options/botplay'));
				var optionsFileGhost:String = Assets.getText(Paths.txt('options/ghost'));
				if (txt.ID == curSelected)
					txt.color = FlxColor.YELLOW;
				else if (txt.ID == 2)
					txt.color = FlxColor.RED;
				else if(txt.ID == 0 && optionsFileGhost == "ghost")
					txt.color = FlxColor.GREEN;
				else if(txt.ID == 1 && optionsFileBot == "botplay")
					txt.color = FlxColor.GREEN;
				else {
					txt.color = FlxColor.WHITE;
				}
			});	
			if (MUSICBEATSTATE.controls.ACCEPT)
			{
				switch (textMenuItems[curSelected])
				{
					case "Botplay":
						FlxG.sound.play(Paths.sound('confirmMenu'));
						var optionsFile:String = Assets.getText(Paths.txt('options/botplay'));
						trace(optionsFile);
						if(optionsFile != "botplay"){
							trace("here");
							optionsFile = "botplay";
							sys.io.File.saveContent(Paths.txt('options/botplay'), optionsFile);
						}else{
							trace("should be removed");
							optionsFile = "";
							sys.io.File.saveContent(Paths.txt('options/botplay'), optionsFile);
						}
						if(optionsFile == "botplay"){
							botplayOnOrOff = "On";
						}else{
							botplayOnOrOff = "Off";
						} 
						//botplayOptionsEnabledTxt.text = botplayOnOrOff;
					case "Ghost Tapping":
						FlxG.sound.play(Paths.sound('confirmMenu'));
						var optionsFile:String = Assets.getText(Paths.txt('options/ghost'));
						trace(optionsFile);
						if(optionsFile != "ghost"){
							trace("here");
							optionsFile = "ghost";
							sys.io.File.saveContent(Paths.txt('options/ghost'), optionsFile);
						}else{
							trace("should be removed");
							optionsFile = "";
							sys.io.File.saveContent(Paths.txt('options/ghost'), optionsFile);
						}
						if(optionsFile == "ghost"){
							ghostTappingOnOrOff = "On";
						}else{
							ghostTappingOnOrOff= "Off";
						} 
					case "EARSE DATA":
						FlxG.sound.play(Paths.sound('confirmMenu'));
						sys.io.File.saveContent(Paths.txt('options/ghost'), "ghost");
						ghostTappingOnOrOff = "On";
						sys.io.File.saveContent(Paths.txt('options/botplay'), "");
						botplayOnOrOff = "Off";
						var save = new FlxSave();
						save.bind("AchivementData");
						save.data.achivementsGotten = [""];
						save.flush();
						sys.io.File.saveContent(Paths.txt('options/keybinds/left'), 'A');
						sys.io.File.saveContent(Paths.txt('options/keybinds/down'), 'S');
						sys.io.File.saveContent(Paths.txt('options/keybinds/up'), 'W');
						sys.io.File.saveContent(Paths.txt('options/keybinds/right'), 'D');
						FlxG.updateFramerate = 60;
						FlxG.drawFramerate = 60;
						//ghostTappingEnabledTxt.text = ghostTappingOnOrOff;
					case "Back":
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.state.openSubState(new OptionsSubState());
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
