package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import MusicBeatState;
import Options;

class PreferencesSubState extends FlxSubState
{
	var textMenuItems:Array<String> = ['Ghost Tapping', 'Back'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<FlxText>;

	//var ghostTappingOptionEnabledTxt:FlxText;

	var OPTIONS:Options;

	var ghostTappingOnOrOff:String = "On";

	public static var MUSICBEATSTATE:MusicBeatState;
	public function new()
	{
		super();
		
		grpOptionsTexts = new FlxTypedGroup<FlxText>();
		add(grpOptionsTexts);


		selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
			var optionText:FlxText = new FlxText(20, 20 + (i * 50), 0, textMenuItems[i], 32);
			optionText.ID = i;
			grpOptionsTexts.add(optionText);
		}
		/*ghostTappingOptionEnabledTxt = new FlxText(350, 20, 0, "", 32);
		ghostTappingOptionEnabledTxt.scrollFactor.set();
		add(ghostTappingOptionEnabledTxt); */
	}
	override function update(elapsed:Float)
		{
			super.update(elapsed);
	
			if (MUSICBEATSTATE.controls.UP_P)
				curSelected -= 1;
	
			if (MUSICBEATSTATE.controls.DOWN_P)
				curSelected += 1;

			if(MUSICBEATSTATE.controls.BACK){
				FlxG.state.openSubState(new OptionsSubState());
			}	
			if (curSelected < 0)
				curSelected = textMenuItems.length - 1;
	
			if (curSelected >= textMenuItems.length)
				curSelected = 0;
	
			grpOptionsTexts.forEach(function(txt:FlxText)
			{
				txt.color = FlxColor.WHITE;
	
				if (txt.ID == curSelected)
					txt.color = FlxColor.YELLOW;
			});
			//ghostTappingOptionEnabledTxt.text = ghostTappingOnOrOff;

			/*if(OPTIONS.ghostTappingEnabled == true){
				ghostTappingOnOrOff = "On";
			}else{
				ghostTappingOnOrOff = "Off";
			} */
	
			if (MUSICBEATSTATE.controls.ACCEPT)
			{
				switch (textMenuItems[curSelected])
				{
					case "Ghost Tapping":
						if(OPTIONS.ghostTappingEnabled == true){
							OPTIONS.ghostTappingEnabled = false;
						}else{
							OPTIONS.ghostTappingEnabled = true;
						}
					case "Back":
						FlxG.state.openSubState(new OptionsSubState());
				}
			}
		}
}
