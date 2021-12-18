package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.transition.FlxTransitionableState;

class OptionsSubState extends MusicBeatSubstate
{
	var textMenuItems:Array<String> = ['Controls', 'Preferences', 'Back'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;

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

			grpOptionsTexts.add(optionText);
		}
		grpOptionsTexts.forEach(function(txt:Alphabet)
		{				
			if (txt.ID != 0)
				txt.alpha = 0.6;
		});
	}


	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UP_P)
			changeSelection(-1);
			//curSelected -= 1;

		if (controls.DOWN_P)
			changeSelection(1);
			//curSelected += 1;

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;

		if (curSelected >= textMenuItems.length)
			curSelected = 0;

		grpOptionsTexts.forEach(function(txt:Alphabet)
		{
			txt.color = FlxColor.WHITE;

			if (txt.ID == curSelected)
				txt.color = FlxColor.YELLOW;
		});

		if (controls.ACCEPT)
		{
			switch (textMenuItems[curSelected])
			{
				case "Controls":
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.state.closeSubState();
					FlxG.state.openSubState(new ControlsSubState());
				case "Preferences":
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.state.closeSubState();
					FlxG.state.openSubState(new Options());
				/*case "Gameplay":
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.state.closeSubState();
					FlxG.state.openSubState(new GameplaySubState());
				*/
				case "Back":
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new MainMenuState());
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

			item.alpha = 0.6;

			if (item.targetY == 0)
				item.alpha = 1;
		}

	}
}
