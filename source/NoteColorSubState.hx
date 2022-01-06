package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import MusicBeatState;
import lime.utils.Assets;
class NoteColorSubState extends FlxSubState
{
	var textMenuItems:Array<String> = ['Press Esc to go back.'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;

    var babyArrow:FlxSprite = new FlxSprite(0, 200);


	public static var MUSICBEATSTATE:MusicBeatState;
	public function new()
	{
		super();
		
		grpOptionsTexts = new FlxTypedGroup<Alphabet>();
		add(grpOptionsTexts);

        for(i in 0...4){
            babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
            babyArrow.animation.addByPrefix('green', 'arrowUP');
            babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
            babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
            babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
    
            babyArrow.antialiasing = true;
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
            switch (Math.abs(i))
            {
                case 0:
                    babyArrow.x += Note.swagWidth * 0;
                    babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                    babyArrow.animation.addByPrefix('pressed', 'A press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'A confirm', 24, false);
                case 1:
                    babyArrow.x += Note.swagWidth * 1;
                    babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                    babyArrow.animation.addByPrefix('pressed', 'B press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'B confirm', 24, false);
                case 2:
                    babyArrow.x += Note.swagWidth * 2;
                    babyArrow.animation.addByPrefix('static', 'arrowUP');
                    babyArrow.animation.addByPrefix('pressed', 'C press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'C confirm', 24, false);
                case 3:
                    babyArrow.x += Note.swagWidth * 3;
                    babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                    babyArrow.animation.addByPrefix('pressed', 'D press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'D confirm', 24, false);
            }
            babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * 1.5);
        }

		selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
			var optionText:Alphabet = new Alphabet(20, 20 + (i * 200), textMenuItems[i], true, false);
			optionText.ID = i;
			
            optionText.x = 10;
            optionText.y = 600;
			grpOptionsTexts.add(optionText);
		}
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
	
			grpOptionsTexts.forEach(function(txt:Alphabet)
			{
				txt.color = FlxColor.WHITE;
				if (txt.ID == curSelected)
					txt.color = FlxColor.YELLOW;
				else {
					txt.color = FlxColor.WHITE;
				}
			});	
			if (MUSICBEATSTATE.controls.BACK)
			{
				/*switch (textMenuItems[curSelected])
				{	
					case "Back":
						FlxG.sound.play(Paths.sound('confirmMenu'));
						FlxG.state.openSubState(new NoteColorSubState());
				} */
                FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.state.openSubState(new NoteColorSubState());
			}
		}
}
