package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
//import io.newgrounds.NG;
import lime.app.Application;
class OffsetEditor extends MusicBeatState{
    var char:String = 'dad';
    var character:Character;
    var animSelected:String = "";
    var animList:Array<String> = [];
    var animNumber = 0;
    var animText:FlxTypedGroup<FlxText>;
    var multiplyer = 1;
    public function new(char:String = 'dad'){
        super();
        this.char = char; 
    }
    override function create(){
        FlxG.sound.music.stop();

        character = new Character(0, 0, char);
        character.screenCenter();
        character.debugMode = true;
        add(character);

        animText = new FlxTypedGroup<FlxText>();
		add(animText);

        trace(char);

        loadOffsets();

        super.create();
    }
    function loadOffsets(){
        var daLoop:Int = 0;

		for (anim => offsets in character.animOffsets)
		{
            if(anim != "singLEFT" && daLoop == 1){
                anim = "singLEFT";
                offsets = character.animOffsets[anim];
            }
            if(anim != "singUP" && daLoop == 3){
                anim = "singUP";
                offsets = character.animOffsets[anim];
            }
            if(anim != "singRIGHT" && daLoop == 4){
                anim = "singRIGHT";
                offsets = character.animOffsets[anim];
            }
            var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
            text.ID = daLoop;
			animText.add(text);

			animList.push(anim);

			daLoop++;
		}
        character.x = character.animOffsets[animList[0]][0];
        character.y = character.animOffsets[animList[0]][1];
        animSelected = animList[0];
    }
    function updateText(){
        animText.forEach(function(txt:FlxText)
        {
            var daLoop:Int = 0;
            for (anim => offsets in character.animOffsets)
            {
                if(anim != "singLEFT" && daLoop == 1){
                    anim = "singLEFT";
                    offsets = character.animOffsets[anim];
                }
                if(anim != "singUP" && daLoop == 3){
                    anim = "singUP";
                    offsets = character.animOffsets[anim];
                }
                if(anim != "singRIGHT" && daLoop == 4){
                    anim = "singRIGHT";
                    offsets = character.animOffsets[anim];
                }
                if(txt.ID == daLoop){
                    txt.text = anim + ": " + offsets;
                }
                daLoop++;
            }
        });
    }
    function editOffsetTxt(){
        var offsets:Array<String> = [];
        //offsets.insert(999, character.animOffsets[animList[0]][0]);
        for(i in 0...animList.length){
            if (i > 9) break;
            offsets.insert(999, character.animOffsets[animList[i]][0]);
            offsets.insert(999, character.animOffsets[animList[i]][1]);
        }
        try{
            sys.io.File.saveContent(Paths.txt('characters/offsets/$char'), CoolUtil.coolTextFileExport(offsets));
        }catch(e){
            trace("offset file does not exist");
        }
    }
    override function update(elapsed:Float){
        if (animNumber < 0)
			animNumber = animList.length - 1;

		if (animNumber >= animList.length)
			animNumber = 0;
        if(controls.ACCEPT){
            character.playAnim(animSelected, true);
        }
        if(controls.BACK){
            FlxG.switchState(new MainMenuState());
        }
        if(controls.UP_P){
            animNumber -= 1;
            animSelected = animList[animNumber];
            character.x = character.animOffsets[animList[animNumber]][0];
            character.y = character.animOffsets[animList[animNumber]][1];
            editOffsetTxt();
            character.playAnim(animSelected, true);
        }
        if(FlxG.keys.pressed.F){
            character.y += 1 * multiplyer;
            character.addOffset(animSelected, character.x, character.y);
            updateText();
            editOffsetTxt();
        }if(FlxG.keys.pressed.J){
            character.y -= 1 * multiplyer;
            character.addOffset(animSelected, character.x, character.y);
            updateText();
            editOffsetTxt();
        }
        if(FlxG.keys.pressed.K){
            character.x += 1 * multiplyer;
            character.addOffset(animSelected, character.x, character.y);
            updateText();
            editOffsetTxt();
        }if(FlxG.keys.pressed.D){
            character.x -= 1 * multiplyer;
            character.addOffset(animSelected, character.x, character.y);
            updateText();
            editOffsetTxt();
        }
        if(FlxG.keys.pressed.SHIFT){
            multiplyer = 10;
        }else{
            multiplyer = 1;
        }
        animText.forEach(function(txt:FlxText)
        {
            txt.color = FlxColor.BLUE;
            if (txt.ID == animNumber)
                txt.color = FlxColor.RED;
        });
        if(controls.DOWN_P){
            animNumber += 1;
            animSelected = animList[animNumber];
            character.x = character.animOffsets[animList[animNumber]][0];
            character.y = character.animOffsets[animList[animNumber]][1];
            editOffsetTxt();
            character.playAnim(animSelected, true);
        }
        super.update(elapsed);
    }
}