package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.input.keyboard.FlxKey;
import flixel.group.FlxSpriteGroup;
import Options;
using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	var hidden:Bool = false;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var objects:FlxSpriteGroup;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;


	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var OPTIONS:Options;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	public var mania:Int = SONG.mania;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songAccuracy:Float = 0;
	var songComboBreaks:Int = 0;
	var songGrade:String = "?";

	var scoreTxt:FlxText;
	var gradeTxt:FlxText;
	var songNameTxt:FlxText;
	var comboBreaksTxt:FlxText;
	var accurayTxt:FlxText;
	var timerTxt:FlxText;


	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	function customNoteMiss(noteType:String){
			try{
				var noteEvents = CoolUtil.coolTextFile(Paths.txt('custom_notes/$noteType/$noteType-missed'));
				for(i in 0...noteEvents.length){
					if(noteEvents[i].contains("bf.die")){
						health -= 100;
					}
					if(noteEvents[i].contains("health -=")){
						health -= Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
					}
					if(noteEvents[i].contains("health +=")){
						health += Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
					}
					if(noteEvents[i].contains("health =")){
						health = Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
					}
					if(noteEvents[i].contains("drain =")){
						SONG.healthDrain = Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
					}
					if(noteEvents[i].contains("healthCheck") && !noteEvents[i].contains('!')){
						SONG.healthCheck = true;
					}
					if(noteEvents[i].contains("!healthCheck") && noteEvents[i].contains('!')){
						SONG.healthCheck = false;
					}
					if(noteEvents[i].contains("hideArrows")){
						hidden = true;
					}
					if(noteEvents[i].contains("showArrows")){
						hidden = false;
					}
					/*if(noteEvents[i].contains("anim.bf.")){
						trace(noteEvents[i].substring(noteEvents[i].indexOf('.') + 4));
						boyfriend.playAnim(noteEvents[i].substring(noteEvents[i].indexOf('.') + 4), true);
					} */
				}
			}			
	}
	/*function addGoals(){
		var BG:FlxSprite;
		var label:FlxText;
		var goalsText:FlxTypedGroup<FlxText>;
		BG = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width / 4), Std.int(FlxG.height / 2) + 500, 0xFF000000);
		BG.x = FlxG.width - BG.width;
		BG.alpha = 0.25;
		add(BG);

		label = new FlxText(965, 100, "Goals:", 30);
		label.setFormat(Paths.font("vcr.ttf"), 70, FlxColor.WHITE, RIGHT);
		label.scrollFactor.set();
		add(label);

		goalsText = new FlxTypedGroup<FlxText>();
		add(goalsText);

		for (i in 0...SONG.goals.length)
		{
			var goal:FlxText = new FlxText(20, 20 + (i * 50), 0, SONG.goals[i], 10);
			goal.ID = i;
			goalsText.add(goal);
		}
	} */
	function customNotePress(noteType:String){
		try{
			var noteEvents = CoolUtil.coolTextFile(Paths.txt('custom_notes/$noteType/$noteType-pressed'));
			for(i in 0...noteEvents.length){
				if(noteEvents[i].contains("bf.die")){
					health -= 100;
				}
				if(noteEvents[i].contains("health -=")){
					health -= Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
				}
				if(noteEvents[i].contains("health +=")){
					health += Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
				}
				if(noteEvents[i].contains("health =")){
					health = Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
				}
				if(noteEvents[i].contains("drain =")){
					SONG.healthDrain = Std.parseFloat(noteEvents[i].substring(noteEvents[i].indexOf('=') + 2));
				}
				if(noteEvents[i].contains("healthCheck") && !noteEvents[i].contains('!')){
					SONG.healthCheck = true;
				}
				if(noteEvents[i].contains("!healthCheck") && noteEvents[i].contains('!')){
					SONG.healthCheck = false;
				}
				if(noteEvents[i].contains("hideArrows")){
					hidden = true;
				}
				if(noteEvents[i].contains("showArrows")){
					hidden = false;
				}
				/*if(noteEvents[i].contains("anim.bf.")){
					trace(noteEvents[i].substring(noteEvents[i].indexOf('.') + 4));
					boyfriend.playAnim(noteEvents[i].substring(noteEvents[i].indexOf('.') + 4), true);
				} */
			}
		}			
}
	override public function create()
	{
		if(mania < 3 || mania > 5){
			mania = 4;
			SONG.mania = 4;
		}
		FlxG.mouse.visible = false;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			default:
				var bannedDifficulties:Array<String> = ['EASY', 'NORMAL', 'HARD'];
				var difficulties = CoolUtil.coolTextFile(Paths.txt('difficulties'));
				try{
					for(i in 0...difficulties.length){
						trace(difficulties[i].toLowerCase());
						trace(!difficulties[i].contains(bannedDifficulties[i]) && difficulties.indexOf(difficulties[i]) == storyDifficulty);
						if(difficulties[i] != bannedDifficulties[i] && difficulties.indexOf(difficulties[i]) == storyDifficulty){
							var name:String = difficulties[i].toLowerCase();
							var name2 = name;
							name = name.substring(0,0);
							name += name2.substring(1);
							storyDifficultyText = name;
						}
					}
				}catch(e){
					trace("Failed to load shit");
				}
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText + "\nScore: " + songScore;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")" + "\nScore: " + songScore, iconRPC);
		#end

		switch (SONG.song.toLowerCase().replace(' ', '-'))
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                      phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  //var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  //FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  //overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }
		          default:
		          {
					  if(SONG.song.toLowerCase() == 'bopeebo' || SONG.song.toLowerCase() == 'fresh' || SONG.song.toLowerCase() == 'dadbattle' || SONG.song.toLowerCase() == 'tutorial'){
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = true;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = true;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);


						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = true;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						add(stageCurtains);
					}else{
						var stageAssets = CoolUtil.coolTextFile(Paths.txt('stages/' + SONG.stage + "/" +  SONG.stage));
						curStage = SONG.stage;
						var tags:Array<String> = [];
						var widths:Array<String> = [];
						var heights:Array<String> = [];
						if(stageAssets[0].contains("camZoom:")){
							trace(stageAssets[0].substring(9));
							defaultCamZoom = Std.parseFloat(stageAssets[0].substring(9));
						} 
						//defaultCamZoom = 0.9;
						for(i in 0...stageAssets.length){
							if(stageAssets[i].contains("add:")){
								var asset:FlxSprite = new FlxSprite(Std.parseFloat(stageAssets[i].substring(stageAssets[i].indexOf(',') + 1, stageAssets[i].lastIndexOf(','))), Std.parseFloat(stageAssets[i].substring(stageAssets[i].lastIndexOf(',') + 1))).loadGraphic(Paths.image('stages/' + SONG.stage + '/' + stageAssets[i].substring(5, stageAssets[i].indexOf(','))));
								asset.antialiasing = true;
								if(stageAssets[i + 1].contains("scrollFactor:")){
									asset.scrollFactor.set(Std.parseFloat(stageAssets[i + 1].substring(14, stageAssets[i + 1].indexOf(','))), Std.parseFloat(stageAssets[i + 1].substring(stageAssets[i + 1].indexOf(',') + 1)));
								}else{
									asset.scrollFactor.set(0.9, 0.9);
								}
								tags.push(stageAssets[i].substring(5, stageAssets[i].indexOf(',')));
								widths.push(Std.string(asset.width));
								heights.push(Std.string(asset.height));
								if(stageAssets[i + 2].contains("GraphicSize:")){
									asset.setGraphicSize(Std.parseInt(stageAssets[i + 2].substring(13)));
									/*for(v in 0...stageAssets.length){
										if(stageAssets[i + 2].substring(13).contains(tags[v])){
											asset.setGraphicSize(Std.parseInt(widths[tags.indexOf(tags[v])]));
											break;
										}
									} */
								}
								//asset.scrollFactor.set(0.9, 0.9);
								asset.active = false;
								asset.updateHitbox();
								add(asset);
							}
							/*if(stageAssets[i].contains("addAnimatedSprite:")){
								trace(Paths.getSparrowAtlas('stages/' + SONG.stage + '/' + stageAssets[i].substring(19, stageAssets[i].indexOf(','))));
								var asset:FlxSprite = new FlxSprite(Std.parseFloat(stageAssets[i].substring(stageAssets[i].indexOf(',') + 1, stageAssets[i].lastIndexOf(','))), Std.parseFloat(stageAssets[i].substring(stageAssets[i].lastIndexOf(',') + 1)));
								asset.antialiasing = true;
								asset.frames = Paths.getSparrowAtlas('stages/' + SONG.stage + '/' + stageAssets[i].substring(19, stageAssets[i].indexOf(',')));
								asset.animation.addByPrefix('anim', 'animation', 24, false);
								if(stageAssets[i + 1].contains("scrollFactor:")){
									trace("x: " + stageAssets[i + 1].substring(14, stageAssets[i + 1].indexOf(',')) + " y: " + stageAssets[i + 1].substring(stageAssets[i + 1].indexOf(',') + 1));
									asset.scrollFactor.set(Std.parseFloat(stageAssets[i + 1].substring(14, stageAssets[i + 1].indexOf(','))), Std.parseFloat(stageAssets[i + 1].substring(stageAssets[i + 1].indexOf(',') + 1)));
								}else{
									asset.scrollFactor.set(0.9, 0.9);
								}
								tags.push(stageAssets[i].substring(19, stageAssets[i].indexOf(',')));
								widths.push(Std.string(asset.width));
								heights.push(Std.string(asset.height));
								if(stageAssets[i + 2].contains("GraphicSize:")){
									asset.setGraphicSize(Std.parseInt(stageAssets[i + 2].substring(13)));
									for(v in 0...stageAssets.length){
										if(stageAssets[i + 2].substring(13).contains(tags[v])){
											asset.setGraphicSize(Std.parseInt(widths[tags.indexOf(tags[v])]));
											break;
										}
									} 
								} 
								//asset.scrollFactor.set(0.9, 0.9);
								asset.active = false;
								asset.updateHitbox();
								animBG(asset);
								add(asset);
							} */
						}
					}
		          }
              }

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(/*healthBarBG.x + healthBarBG.width - 130 */ 500, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		/*timerTxt = new FlxText(healthBarBG.x + healthBarBG.width - 130  500, 500, 0, "", 20);
		timerTxt.setFormat(Paths.font("pixel.otf"), 16, FlxColor.WHITE, RIGHT);
		timerTxt.scrollFactor.set();
		add(timerTxt);
		*/

		gradeTxt = new FlxText(healthBarBG.x + healthBarBG.width + 30, healthBarBG.y + 30, 0, "", 20);
		gradeTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		gradeTxt.scrollFactor.set();
		add(gradeTxt);

		comboBreaksTxt = new FlxText(650, healthBarBG.y + 30, 0, "", 20);
		comboBreaksTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		comboBreaksTxt.scrollFactor.set();
		add(comboBreaksTxt);

		songNameTxt = new FlxText(/*healthBarBG.x + healthBarBG.width - 130 */ 50, healthBarBG.y + 30, 0, "", 20);
		songNameTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		songNameTxt.scrollFactor.set();
		add(songNameTxt);

		accurayTxt = new FlxText(healthBarBG.x + healthBarBG.width - 120, healthBarBG.y + 30, 0, "", 20);
		accurayTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		accurayTxt.scrollFactor.set();
		add(accurayTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		objects = new FlxSpriteGroup(0, 0);
		add(objects);

		var beatEventSettings:Array<String> = [];
		/*try{
			beatEventSettings  = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/beatEvent-Settings'));
		}catch(e){
			beatEventSettings[0] = null;
			trace("Could not find beatEvent-Settings");
		} */

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		/*if(beatEventSettings[0] == "objects are on HUD: true"){
			objects.cameras = [camHUD];
		} */
		//timerTxt.cameras = [camHUD];
		gradeTxt.cameras = [camHUD];
		songNameTxt.cameras = [camHUD];
		accurayTxt.cameras = [camHUD];
		comboBreaksTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);


		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song.replace(' ', '-')), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")" + "\nScore: " + songScore, iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song.replace(' ', '-')));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = 0;
				if(SONG.mania == 4){
					daNoteData = Std.int(songNotes[1] % 4);
				}else if(SONG.mania == 5){
					daNoteData = Std.int(songNotes[1] % 5);
				}

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;	
				var swagNote:Note;		
				//if(SONG.mania == 4)	{
				swagNote = new Note(daStrumTime, daNoteData, oldNote, null, songNotes[3], songNotes[4]);
				//}else{
					//if(daNoteData < 4){
						//swagNote = new Note(daStrumTime, daNoteData, oldNote, null, songNotes[3], songNotes[4]);
					//}else{
						//swagNote = new Note(daStrumTime, daNoteData + 1, oldNote, null, songNotes[3], songNotes[4]);
					//}
				//}
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, songNotes[3], songNotes[4]);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
					if(songNotes[3] == true && curStage != 'school' && curStage != 'schoolEvil'){
						sustainNote.x += 35;
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...mania)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('green2', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
					switch(mania){
						case 4:
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
						case 5:
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
									babyArrow.x += Note.swagWidth * 3;
									babyArrow.animation.addByPrefix('static', 'arrowUP');
									babyArrow.animation.addByPrefix('pressed', 'C press', 24, false);
									babyArrow.animation.addByPrefix('confirm', 'C confirm', 24, false);
								case 3:
									babyArrow.x += Note.swagWidth * 4;
									babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
									babyArrow.animation.addByPrefix('pressed', 'D press', 24, false);
									babyArrow.animation.addByPrefix('confirm', 'D confirm', 24, false);
								case 4:
									babyArrow.x += Note.swagWidth * 2;
									babyArrow.animation.addByPrefix('static', 'arrowSPACE');
									babyArrow.animation.addByPrefix('pressed', 'E press', 24, false);
									babyArrow.animation.addByPrefix('confirm', 'E confirm', 24, false);
							}
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				if(!PlayState.SONG.notes[Std.int(curStep / 16)].arrowsHidden){
					FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);

			new FlxTimer().start(2, function(tmr:FlxTimer){
				if(hidden == true || PlayState.SONG.notes[Std.int(curStep / 16)].arrowsHidden){
					babyArrow.alpha = 0;
				}else{
					babyArrow.alpha = 100;
				}
			}, 0);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")" + "\nScore: " + songScore, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")" + "\nScore: " + songScore, iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")" + "\nScore: " + songScore, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")" + "\nScore: " + songScore, iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if(Std.string(songAccuracy).contains("-")){
			songAccuracy = 0;
		}
		if(songAccuracy > 100){
			songAccuracy = 100;
		}
		if(songComboBreaks == 0){
			songAccuracy = 100;
		}
		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
			var save = new FlxSave();
			save.bind("AchivementData");
			if(!save.data.achivementsGotten.contains("Time Traveler")){
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
					save.data.achivementsGotten = null;
					save.data.achivementsGotten = new Array<String>();
				}
				save.data.achivementsGotten.push("Time Traveler");

				save.flush();
			}
		}
		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		if(songComboBreaks == 0){
			songGrade = "FC";
		}else if (songComboBreaks < 10){
			songGrade = "SDCB";
		}else{
			songGrade = "Clear";
		}

		super.update(elapsed);



		scoreTxt.text = "Score:" + songScore;
		gradeTxt.text = "(" + songGrade + ")";
		var time:String = FlxStringUtil.formatTime(songLength - Conductor.songPosition, false);
		if(time.length == 5){
			time = time.substring(0,1);
		}else if(time.length == 6){
			time = time.substring(0,2);
		}else if(time.length == 7){
			time = time.substring(0,3);
		}
		var timeList:Array<String>;
		//timerTxt.text = /*Std.string(Date.fromTime(songLength)) */ time;
		songNameTxt.text = "Playing: " + SONG.song + " on XGen 0.0.6";
		accurayTxt.text = "Accuracy: %" + songAccuracy;
		comboBreaksTxt.text = "Combo breaks: " + songComboBreaks;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#if debug
		if (FlxG.keys.justPressed.SIX)
			FlxG.switchState(new OffsetEditor(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			var save = new FlxSave();
			save.bind("AchivementData");
			if(!save.data.achivementsGotten.contains("Blue balls")){
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
					save.data.achivementsGotten = null;
					save.data.achivementsGotten = new Array<String>();
				}
				save.data.achivementsGotten.push("Blue balls");

				save.flush();
			}

			save.flush();

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.isDeath)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				var optionsFile:Array<String> = CoolUtil.coolTextFile(Paths.txt('options/botplay'));
				if(daNote.canBeHit && optionsFile.contains('botplay') && !daNote.isDeath){
					switch (Math.abs(daNote.noteData))
					{
						case 0:
							boyfriend.playAnim('singLEFT', true);
						case 1:
							boyfriend.playAnim('singDOWN', true);
						case 2:
							boyfriend.playAnim('singUP', true);
						case 3:
							boyfriend.playAnim('singRIGHT', true);
					}
					health += 0.023;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						if(!optionsFile.contains('botplay') && !daNote.isDeath){
							health -= 0.0475;
							noteMiss(daNote.noteData, daNote.isDeath, daNote.daType);
							vocals.volume = 0;
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		if(storyDifficultyText == "Hard"){
			var save = new FlxSave();
			save.bind("AchivementData");
			if(!save.data.achivementsGotten.contains("Hardcore")){
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
					save.data.achivementsGotten = null;
					save.data.achivementsGotten = new Array<String>();
				}
				save.data.achivementsGotten.push("Hardcore");

				save.flush();
			}

			save.flush();
		}
		
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}
		var achievementsList:Array<String> = CoolUtil.coolTextFile(Paths.txt('achivementsList'));
		var defaultAchievemnts:Array<String> = ["Friday Night", "Ez", "Spooky", "Go pico", "Simp", "Christmas cheer", "Weeb", "Hardcore", "Blue balls", "Time Traveler"];
		var save = new FlxSave();
		save.bind("AchivementData");
		for(i in 0...achievementsList.length){
			try{
				if(!achievementsList.contains(defaultAchievemnts[i])){
					var achievementName = achievementsList[i];
					trace(achievementName);
					var achievementGoal = CoolUtil.coolTextFileString(Paths.txt('achievements/$achievementName/$achievementName-goal'));
					if(achievementGoal.contains("difficulty ==") && storyDifficultyText.toLowerCase() == achievementGoal.substring(14).toLowerCase() && !save.data.achivementsGotten.contains(achievementName)){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push(achievementName);
	
						save.flush();
					}
					if(achievementGoal.contains("SongCompleted ==") && SONG.song == achievementGoal.substring(17) && !save.data.achivementsGotten.contains(achievementName)){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push(achievementName);
	
						save.flush();
					}
				}
			}catch(e){
				trace("Fuck");
			}
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				if(storyWeek == 1){
					var save = new FlxSave();
					save.bind("AchivementData");
					if(!save.data.achivementsGotten.contains("Ez")){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push("Ez");
	
						save.flush();
					}
				}
				if(storyWeek == 2){
					var save = new FlxSave();
					save.bind("AchivementData");
					if(!save.data.achivementsGotten.contains("Spooky")){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push("Spooky");
	
						save.flush();
					}
				}
				if(storyWeek == 3){
					var save = new FlxSave();
					save.bind("AchivementData");
					if(!save.data.achivementsGotten.contains("Go pico")){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push("Go pico");
	
						save.flush();
					}
				}
				if(storyWeek == 4){
					var save = new FlxSave();
					save.bind("AchivementData");
					if(!save.data.achivementsGotten.contains("Simp")){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push("Simp");
	
						save.flush();
					}
				}
				if(storyWeek == 5){
					var save = new FlxSave();
					save.bind("AchivementData");
					if(!save.data.achivementsGotten.contains("Christmas cheer")){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push("Christmas cheer");

						save.flush();
					}
				}
				
				if(storyWeek == 6){
					var save = new FlxSave();
					save.bind("AchivementData");
					if(!save.data.achivementsGotten.contains("Weeb")){
						FlxG.sound.play(Paths.sound('confirmMenu'));
						if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
							save.data.achivementsGotten = null;
							save.data.achivementsGotten = new Array<String>();
						}
						save.data.achivementsGotten.push("Weeb");
	
						save.flush();
					}
				}
				var achievementsList:Array<String> = CoolUtil.coolTextFile(Paths.txt('achivementsList'));
				var defaultAchievemnts:Array<String> = ["Friday Night", "Ez", "Spooky", "Go pico", "Simp", "Christmas cheer", "Weeb", "Hardcore", "Blue balls", "Time Traveler"];
				var save = new FlxSave();
				save.bind("AchivementData");
				for(i in 0...achievementsList.length){
					if(!achievementsList.contains(defaultAchievemnts[i])){
						var achievementName = achievementsList[i];
						var achievementGoal = CoolUtil.coolTextFileString(Paths.txt('achievements/$achievementName/$achievementName-goal'));
						if(achievementGoal.contains("difficulty ==") && storyDifficultyText.toLowerCase() == achievementGoal.substring(14).toLowerCase() && !save.data.achivementsGotten.contains(achievementName)){
							FlxG.sound.play(Paths.sound('confirmMenu'));
							if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
								save.data.achivementsGotten = null;
								save.data.achivementsGotten = new Array<String>();
							}
							save.data.achivementsGotten.push(achievementName);
	
							save.flush();
						}
						if(achievementGoal.contains("SongCompleted ==") && SONG.song.toLowerCase() == achievementGoal.substring(17).toLowerCase() && !save.data.achivementsGotten.contains(achievementName)){
							FlxG.sound.play(Paths.sound('confirmMenu'));
							if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
								save.data.achivementsGotten = null;
								save.data.achivementsGotten = new Array<String>();
							}
							save.data.achivementsGotten.push(achievementName);
	
							save.flush();
						}
						if(achievementGoal.contains("WeekCompleted ==") && Std.string(storyWeek) == achievementGoal.substring(17) && !save.data.achivementsGotten.contains(achievementName)){
							FlxG.sound.play(Paths.sound('confirmMenu'));
							if(save.data.achivementsGotten == null || save.data.achivementsGotten == ""){
								save.data.achivementsGotten = null;
								save.data.achivementsGotten = new Array<String>();
							}
							save.data.achivementsGotten.push(achievementName);
	
							save.flush();
						}
					}
				}
				

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					//NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';
				else if (storyDifficulty == 2)
					difficulty = '-hard';
				else{
					var bannedDifficulties:Array<String> = ['EASY', 'NORMAL', 'HARD'];
					var difficulties = CoolUtil.coolTextFile(Paths.txt('difficulties'));
					try{
						for(i in 0...difficulties.length){
							trace(difficulties[i].toLowerCase());
							trace(!difficulties[i].contains(bannedDifficulties[i]) && difficulties.indexOf(difficulties[i]) == storyDifficulty);
							if(difficulties[i] != bannedDifficulties[i] && difficulties.indexOf(difficulties[i]) == storyDifficulty){
								difficulty = '-' + difficulties[i].toLowerCase();
							}
						}
					}catch(e){
						trace("Failed to load shit");
					}
				}

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var accuracy:Float = 2.25;

		var daRating:String = "sick";

		if(Std.string(songAccuracy).contains("-")){
			songAccuracy = 0;
		}

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			accuracy = -2.25 - songComboBreaks - 0.5;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			accuracy = -1.15 - songComboBreaks - 1;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			if(songComboBreaks < 2){
				accuracy = 1.15 - songComboBreaks - 1;
			}else{
				accuracy = 0.5;
			}
		}if(songComboBreaks < 3 && accuracy == 2.25){
			accuracy = accuracy - songComboBreaks - 1;
		}else{
			accuracy = 1.2;
		}

		songScore += score;
		if(songAccuracy >= 0 && songAccuracy <= 100 && songAccuracy < 101 && songAccuracy > -1){
			if(accuracy < 0){
				songAccuracy -= accuracy;
			}else{
				songAccuracy += accuracy;
			}
			if(Std.string(songAccuracy).contains("100")){
				var songAccuracyString:String = Std.string(songAccuracy);
				songAccuracyString = songAccuracyString.substr(0,3);
				songAccuracy = Std.parseFloat(songAccuracyString);
			}
			if(Std.string(songAccuracy).length > 4){
				var songAccuracyString:String = Std.string(songAccuracy);
				songAccuracyString = songAccuracyString.substr(0,6);
				songAccuracy = Std.parseFloat(songAccuracyString);
			}
		}
		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
		try{
			var sectionEvents = CoolUtil.coolTextFile(Paths.txt(curSong.toLowerCase() + '/sectionEvent'));
			for(i in 0...sectionEvents.length){
				if(sectionEvents[i].contains(Std.string(curSection))){
					/*if(sectionEvents[i].contains("dad =")){
						dad = null;
						dad = new Character(100, 100, sectionEvents[i].substring(sectionEvents[i].indexOf('=') + 2));
						var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
						switch (SONG.player2)
						{
							case 'gf':
								dad.setPosition(gf.x, gf.y);
								gf.visible = false;
							if (isStoryMode)
							{
								camPos.x += 600;
								tweenCamIn();
							}

							case "spooky":
								dad.y += 200;
							case "monster":
								dad.y += 100;
							case 'monster-christmas':
								dad.y += 130;
							case 'dad':
								camPos.x += 400;
							case 'pico':
								camPos.x += 600;
								dad.y += 300;
							case 'parents-christmas':
								dad.x -= 500;
							case 'senpai':
								dad.x += 150;
								dad.y += 360;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
							case 'senpai-angry':
								dad.x += 150;
								dad.y += 360;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
							case 'spirit':
								dad.x -= 150;
								dad.y += 100;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
						}
					} */
					if(sectionEvents[i].contains("bf.die")){
						health -= 100;
					}
					if(sectionEvents[i].contains("health -=")){
						health -= Std.parseFloat(sectionEvents[i].substring(sectionEvents[i].indexOf('=') + 2));
					}
					if(sectionEvents[i].contains("health +=")){
						health += Std.parseFloat(sectionEvents[i].substring(sectionEvents[i].indexOf('=') + 2));
					}
					if(sectionEvents[i].contains("health =")){
						health = Std.parseFloat(sectionEvents[i].substring(sectionEvents[i].indexOf('=') + 2));
					}
					if(sectionEvents[i].contains("drain =")){
						SONG.healthDrain = Std.parseFloat(sectionEvents[i].substring(sectionEvents[i].indexOf('=') + 2));
					}
					if(sectionEvents[i].contains("healthCheck") && !sectionEvents[i].contains('!')){
						SONG.healthCheck = true;
					}
					if(sectionEvents[i].contains("!healthCheck") && sectionEvents[i].contains('!')){
						SONG.healthCheck = false;
					}
					if(sectionEvents[i].contains("hideArrows")){
						hidden = true;
					}
					if(sectionEvents[i].contains("showArrows")){
						hidden = false;
					}
					if(sectionEvents[i].contains("anim.bf.")){
						trace(sectionEvents[i].substring(sectionEvents[i].indexOf('.') + 4));
						boyfriend.playAnim(sectionEvents[i].substring(sectionEvents[i].indexOf('.') + 4), true);
					}
				}
			}
		}catch(e){
			trace("There is no fucking beat Event");
		}

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		if(SONG.mania == 4){
			controlArray = [leftP, downP, upP, rightP];
		}else if(SONG.mania == 5){
			controlArray = [leftP, downP, FlxG.keys.pressed.SPACE, upP, rightP];
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP || FlxG.keys.pressed.SPACE) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});
			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);
				// Jump notes
				if (possibleNotes.length >= 2)
				{
					var daNote = possibleNotes[0];
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck(daNote.isDeath, daNote.daType);
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}

					//this is already done in noteCheck / goodNoteHit
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 */
			}
			else
			{
				//var daNote = possibleNotes[0];
				badNoteCheck();
			}
		}
		if ((up || right || down || left || FlxG.keys.pressed.SPACE) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{	if(SONG.mania == 4){
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if (left)
									goodNoteHit(daNote);
							case 1:
								if (down)
									goodNoteHit(daNote);
							case 2:
								if (up)
									goodNoteHit(daNote);
							case 3:
								if (right)
									goodNoteHit(daNote);
						}
					}else if(SONG.mania == 5){
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 0:
								if (left)
									goodNoteHit(daNote);
							case 1:
								if (down)
									goodNoteHit(daNote);
							case 2:
								if (FlxG.keys.pressed.SPACE)
									goodNoteHit(daNote);
							case 3:
								if (up)
									goodNoteHit(daNote);
							case 4:
								if (right)
									goodNoteHit(daNote);
						}
					}
				}
			});
		}
		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left && !FlxG.keys.pressed.SPACE)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
		}
		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch(SONG.mania){
				case 4:
					switch (spr.ID)
					{
						case 0:
							if (leftP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (leftR)
								spr.animation.play('static');
						case 1:
							if (downP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (downR)
								spr.animation.play('static');
						case 2:
							if (upP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (upR)
								spr.animation.play('static');
						case 3:
							if (rightP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (rightR)
								spr.animation.play('static');
					}
				case 5:
					switch (spr.ID)
					{
						case 0:
							if (leftP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (leftR)
								spr.animation.play('static');
						case 1:
							if (downP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (downR)
								spr.animation.play('static');
						case 2:
							if (upP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (upR)
								spr.animation.play('static');
						case 3:
							if (rightP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (rightR)
								spr.animation.play('static');
						case 4:
							if (FlxG.keys.pressed.SPACE && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (FlxG.keys.justReleased.SPACE)
								spr.animation.play('static');
					}	
			}	
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	public function noteMiss(direction:Int = 1, ?isDeath:Bool = false, ?noteType:String = null):Void
	{
		var optionsFile:Array<String> = CoolUtil.coolTextFile(Paths.txt('options/ghost'));
		var customNote:Array<String> = null;
		var noteOptions:Array<String> = null;
		try{
			customNote = CoolUtil.coolTextFile(Paths.txt('custom_notes/$noteType/$noteType-missed'));
		}
		catch(e){
			trace("Could not find the custom note function for missing");
		}
		noteOptions = CoolUtil.coolTextFile(Paths.txt('custom_notes/$noteType/$noteType-settings'));
		if(customNote != null){
			customNoteMiss(noteType);
		}
		if (!boyfriend.stunned && isDeath == false && noteOptions[0] == "false")
		{
			if(!optionsFile.contains('ghost')){
				health -= 0.04;
			}
			songComboBreaks += 1;
			songAccuracy -= 2.25 + songComboBreaks - 1;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 4:
					boyfriend.playAnim('singDOWNmiss', true);
			}
		}
	}

	function badNoteCheck(?isDeath:Bool = false, ?noteType:String = null)
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;
		var optionsFile:Array<String> = CoolUtil.coolTextFile(Paths.txt('options/ghost'));
		if(!optionsFile.contains('ghost')){
			if (leftP)
				noteMiss(0, isDeath, noteType);
			if (downP)
				noteMiss(1, isDeath, noteType);
			if (upP)
				noteMiss(2, isDeath, noteType);
			if (rightP)
				noteMiss(3, isDeath, noteType);
			if(SONG.mania == 5 && FlxG.keys.pressed.SPACE)
				noteMiss(2, isDeath, noteType);		
		}
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP){
			goodNoteHit(note);
		}
		else
		{
			badNoteCheck(note.isDeath, note.daType);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		var customNote:Array<String> = null;
		var noteType = note.daType;
		var daNoteData:Int = 0;
		if(SONG.mania == 4){
			daNoteData = Std.int(note.noteData % 4);
		}else if(SONG.mania == 5){
			daNoteData = Std.int(note.noteData % 5);
		}
		try{
			customNote = CoolUtil.coolTextFile(Paths.txt('custom_notes/$noteType/$noteType-pressed'));
		}
		catch(e){
			trace("Could not find the custom note function for pressed");
		}
		if(customNote != null){
			customNotePress(noteType);
		}
		if (!note.wasGoodHit)
		{
			if(note.isDeath == true){
				health -= 100;
			}
			else
			{
				if (!note.isSustainNote)
				{
					popUpScore(note.strumTime);
					combo += 1;
				}
				if (note.noteData >= 0)
					health += 0.023;
				else
					health += 0.004;
		
				switch (note.noteData)
				{
					case 0:
						boyfriend.playAnim('singLEFT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 4:
						boyfriend.playAnim('singDOWN', true);
				}
		
				if(SONG.mania == 4){
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
						}
					});	
				}else{
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNoteData) == spr.ID - 0.5)
						{
							spr.animation.play('confirm', true);
						}
					});	
				}
		
				note.wasGoodHit = true;
				vocals.volume = 1;
		
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
			}
			
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		try{
			var beatEvents = CoolUtil.coolTextFile(Paths.txt(curSong.toLowerCase() + '/beatEvent'));
			var objectsAdded:Array<String> = [];
			var lastestObject:String = "";
			for(i in 0...beatEvents.length){
				if(beatEvents[i].contains(Std.string(curBeat))){
					trace(i);
					/*if(beatEvents[i].contains("dad =")){
						dad = null;
						dad = new Character(100, 100, beatEvents[i].substring(beatEvents[i].indexOf('=') + 2));
						var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
						switch (SONG.player2)
						{
							case 'gf':
								dad.setPosition(gf.x, gf.y);
								gf.visible = false;
							if (isStoryMode)
							{
								camPos.x += 600;
								tweenCamIn();
							}

							case "spooky":
								dad.y += 200;
							case "monster":
								dad.y += 100;
							case 'monster-christmas':
								dad.y += 130;
							case 'dad':
								camPos.x += 400;
							case 'pico':
								camPos.x += 600;
								dad.y += 300;
							case 'parents-christmas':
								dad.x -= 500;
							case 'senpai':
								dad.x += 150;
								dad.y += 360;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
							case 'senpai-angry':
								dad.x += 150;
								dad.y += 360;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
							case 'spirit':
								dad.x -= 150;
								dad.y += 100;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
						}
					} */
					if(beatEvents[i].contains("bf.die")){
						health -= 100;
					}
					if(beatEvents[i].contains("health -=")){
						health -= Std.parseFloat(beatEvents[i].substring(beatEvents[i].indexOf('=') + 2));
					}
					if(beatEvents[i].contains("health +=")){
						health += Std.parseFloat(beatEvents[i].substring(beatEvents[i].indexOf('=') + 2));
					}
					if(beatEvents[i].contains("health =")){
						health = Std.parseFloat(beatEvents[i].substring(beatEvents[i].indexOf('=') + 2));
					}
					if(beatEvents[i].contains("drain =")){
						SONG.healthDrain = Std.parseFloat(beatEvents[i].substring(beatEvents[i].indexOf('=') + 2));
					}
					/*if(beatEvents[i].contains("==")){
						trace(beatEvents[i].substring(2, beatEvents[i].indexOf('=')));
						trace(beatEvents[i].substring(beatEvents[i].indexOf('=') + 3));
						var ifStatmentArgs1:String = beatEvents[i].substring(2, beatEvents[i].indexOf('='));
						var ifStatmentArgs2:String = beatEvents[i].substring(beatEvents[i].indexOf('=') + 3);
						var args1:Dynamic = "";
						var args2:Dynamic = "";
						args1 = ifStatmentArgs1;
						switch(args1){
							case "comboBreaks":
								args1 = songComboBreaks;
							case "grade":
								trace("Should set to grade");
								args1 = songGrade;
							case "accuracy":
								args1 = songAccuracy;
							case "score":
								args1 = songScore; 
							case "drain":
								args1 = SONG.healthDrain;
							case "health":
								args1 = health;
							case "mania":
								args1 = SONG.mania;
						}
						args2 = ifStatmentArgs2;
						switch(args2){
							case "comboBreaks":
								args2 = songComboBreaks;
							case "grade":
								args2 = songGrade;
							case "accuracy":
								args2 = songAccuracy;
							case "score":
								args2 = songScore; 
							case "drain":
								args2 = SONG.healthDrain;
							case "health":
								args2 = health;
							case "mania":
								args2 = SONG.mania;
						}
						trace(args1);
						trace(args2);
						if(args1 == args2){
							trace('They are equal');
							doBeatEvent(beatEvents[i + 1].substring(4));
						}
					} */
					if(beatEvents[i].contains("healthCheck") && !beatEvents[i].contains('!')){
						SONG.healthCheck = true;
					}
					if(beatEvents[i].contains("!healthCheck") && beatEvents[i].contains('!')){
						SONG.healthCheck = false;
					}
					if(beatEvents[i].contains("hideArrows")){
						hidden = true;
					}
					if(beatEvents[i].contains("showArrows")){
						hidden = false;					}
					/*if(beatEvents[i].contains("addPng:")){
						var sprite:FlxSprite = new FlxSprite();
						//trace(Paths.imageJpg(SONG.song.toLowerCase() + '/' + beatEvents[i].substring(10, beatEvents[i].indexOf(','))));
						//trace('X: ' + beatEvents[i].substring(beatEvents[i].indexOf(',') + 2, beatEvents[i].lastIndexOf(',')) + ' Y: ' + beatEvents[i].substring(beatEvents[i].lastIndexOf(',') + 2));
						sprite.loadGraphic(Paths.image(SONG.song.toLowerCase() + '/' + beatEvents[i].substring(10, beatEvents[i].indexOf(','))), 'shared');
						sprite.x = Std.parseFloat(beatEvents[i].substring(beatEvents[i].indexOf(',') + 2, beatEvents[i].lastIndexOf(',')));
						sprite.y = Std.parseFloat(beatEvents[i].substring(beatEvents[i].lastIndexOf(',') + 2));
						objects.add(sprite);
						objectsAdded.push(Std.string(sprite));
					}
					if(beatEvents[i].contains("addJpg:") && !objectsAdded.contains(beatEvents[i].substring(10, beatEvents[i].indexOf(',')))){
						var sprite:FlxSprite = new FlxSprite();
						//trace(Paths.imageJpg(SONG.song.toLowerCase() + '/' + beatEvents[i].substring(10, beatEvents[i].indexOf(','))));
						//trace('X: ' + beatEvents[i].substring(beatEvents[i].indexOf(',') + 2, beatEvents[i].lastIndexOf(',')) + ' Y: ' + beatEvents[i].substring(beatEvents[i].lastIndexOf(',') + 2));
						sprite.loadGraphic(Paths.imageJpg(SONG.song.toLowerCase() + '/' + beatEvents[i].substring(10, beatEvents[i].indexOf(','))), 'shared');
						sprite.x = Std.parseFloat(beatEvents[i].substring(beatEvents[i].indexOf(',') + 2, beatEvents[i].lastIndexOf(',')));
						sprite.y = Std.parseFloat(beatEvents[i].substring(beatEvents[i].lastIndexOf(',') + 2));
						objects.add(sprite);
						objectsAdded.push(beatEvents[i].substring(10, beatEvents[i].indexOf(',')));
						trace(sprite);
					} */
					/*if(beatEvents[i].contains("anim.bf.")){
						trace(beatEvents[i].substring(beatEvents[i].indexOf('.') + 4));
						boyfriend.playAnim(beatEvents[i].substring(beatEvents[i].indexOf('.') + 4), true);
					} */
				}
			}
		}catch(e){
			trace("There is no fucking beat Event");
		}
		/*try{
			var stepEvents = CoolUtil.coolTextFile(Paths.txt(curSong.toLowerCase() + '/stepEvent'));
			for(i in 0...stepEvents.length){
				if(stepEvents[i].contains(Std.string(curStep))){
					if(stepEvents[i].contains("dad =")){
						dad = null;
						dad = new Character(100, 100, stepEvents[i].substring(stepEvents[i].indexOf('=') + 2));
						var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
						switch (SONG.player2)
						{
							case 'gf':
								dad.setPosition(gf.x, gf.y);
								gf.visible = false;
							if (isStoryMode)
							{
								camPos.x += 600;
								tweenCamIn();
							}

							case "spooky":
								dad.y += 200;
							case "monster":
								dad.y += 100;
							case 'monster-christmas':
								dad.y += 130;
							case 'dad':
								camPos.x += 400;
							case 'pico':
								camPos.x += 600;
								dad.y += 300;
							case 'parents-christmas':
								dad.x -= 500;
							case 'senpai':
								dad.x += 150;
								dad.y += 360;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
							case 'senpai-angry':
								dad.x += 150;
								dad.y += 360;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
							case 'spirit':
								dad.x -= 150;
								dad.y += 100;
								camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
						}
					} 
					if(stepEvents[i].contains("health -=")){
						health -= Std.parseFloat(stepEvents[i].substring(stepEvents[i].indexOf('=') + 2));
					}
					if(stepEvents[i].contains("health +=")){
						health += Std.parseFloat(stepEvents[i].substring(stepEvents[i].indexOf('=') + 2));
					}
					if(stepEvents[i].contains("health =")){
						health = Std.parseFloat(stepEvents[i].substring(stepEvents[i].indexOf('=') + 2));
					}
					if(stepEvents[i].contains("drain =")){
						SONG.healthDrain = Std.parseFloat(stepEvents[i].substring(stepEvents[i].indexOf('=') + 2));
					}
					if(stepEvents[i].contains("healthCheck") && !stepEvents[i].contains('!')){
						SONG.healthCheck = true;
					}
					if(stepEvents[i].contains("!healthCheck") && stepEvents[i].contains('!')){
						SONG.healthCheck = false;
					}
					if(stepEvents[i].contains("hideArrows")){
						hidden = true;
					}
					if(stepEvents[i].contains("showArrows")){
						hidden = false;
					}
					if(stepEvents[i].contains("anim.bf.")){
						trace(stepEvents[i].substring(stepEvents[i].indexOf('.') + 4));
						boyfriend.playAnim(stepEvents[i].substring(stepEvents[i].indexOf('.') + 4), true);
					}
				}
			}
		}catch(e){
			trace("There is no fucking step Event");
		} */
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
		if(SONG.healthCheck == true){
			if(health >= 0.25){
				health -=  SONG.healthDrain;
			}
		}else{
			health -=  SONG.healthDrain;
		}
		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
