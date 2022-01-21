package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import MusicBeatState;
import lime.utils.Assets;
import flixel.util.FlxSave;
class AchivementState extends MusicBeatState
{
	var textMenuItems:Array<String> = CoolUtil.coolTextFile(Paths.txt('achivementsList'));
	var textMenuItemsDescpritions:Array<String> = CoolUtil.coolTextFile(Paths.txt('achivementsDescriptions'));

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;

	var descText:FlxText;

    var save = new FlxSave();

	public static var MUSICBEATSTATE:MusicBeatState;
	public function new()
	{
		super();

		#if desktop
		DiscordClient.changePresence("Checking Achievements", null);
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		
		grpOptionsTexts = new FlxTypedGroup<Alphabet>();
		add(grpOptionsTexts);

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("phantommuffin.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

        save.bind("AchivementData");

		selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
            var optionText:Alphabet;
			if(save.data.achivementsGotten == null){
				save.data.achivementsGotten = [""];
				save.flush();
			}
			try{
				if(save.data.achivementsGotten.contains(textMenuItems[i])){
					trace("Yay");
					optionText = new Alphabet(20, 20 + (i * 100), textMenuItems[i], false, false);
				}else{
					optionText = new Alphabet(20, 20 + (i * 100), '???', false, false);
				}
			}catch(e){
				optionText = new Alphabet(20, 20 + (i * 100), '???', false, false);
				trace("Bruh, wtf");
			}
			optionText.ID = i;

			optionText.isMenuItem = true;
			optionText.targetY = i;

			optionText.x = 500;
			
			grpOptionsTexts.add(optionText);
			changeSelection();
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
				FlxG.switchState(new MainMenuState());
			}	
			if (curSelected < 0)
				curSelected = textMenuItems.length - 1;
	
			if (curSelected >= textMenuItems.length)
				curSelected = 0;
			for (item in grpOptionsTexts.members)
			{
				item.x = 500;
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

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
			if(save.data.achivementsGotten.contains(item.text) && item.targetY == 0){
				descText.text = textMenuItemsDescpritions[textMenuItems.indexOf(item.text)];
			}else if(item.targetY == 0){
				descText.text = "???";
			}
		}

	}
}
