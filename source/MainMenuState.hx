package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var flicker:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		'credits'
	];

	var magenta:FlxSprite;
	var logo:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var logoScale = 8;
	var logoFinalY = 35 * 4;

	var bttAlpha = 0.0;
	var miniAlpha = 0.0;
	var mini = [];
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		if (FlxG.save.data.sansProg == null)
		{
			FlxG.save.data.sansProg = 0;
			FlxG.save.flush();
		}

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		//var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBG'));
		//bg.scrollFactor.set(0, yScroll);
		//bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.scale.x = 4;
		bg.scale.y = 4;
		bg.updateHitbox();
		//bg.screenCenter();
		bg.antialiasing = false;//ClientPrefs.globalAntialiasing;
		add(bg);

		/*
		var guide:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuguide'));
		guide.scale.x = 4;
		guide.scale.y = 4;
		guide.updateHitbox();
		//guide.screenCenter();
		add(guide);
		*/

		logo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('logo'));
		logo.scale.x = logoScale;
		logo.scale.y = logoScale;
		logo.offset.set(Math.ceil(logo.width / 2), Math.floor(logo.height / 2));
		logo.scrollFactor.set();
		add(logo);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		/*
		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		*/
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		flicker = new FlxTypedGroup<FlxSprite>();
		add(flicker);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/
		var btts = [];
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('btt/' + optionShit[i] + '-n'));
			menuItem.scale.set(4, 4);
			menuItem.scrollFactor.set(1.2, 1.2);
			//menuItem.updateHitbox();
			menuItem.offset.set(menuItem.width / 2, menuItem.height / 2);
			menuItem.setPosition(FlxG.width / 2, FlxG.height / 2);

			var xr = 168;
			var yUp = -6;
			var yDown = 118;

			var poss = [[-xr, xr, -xr, xr], [yUp, yUp, yDown, yDown]];
			menuItem.x += poss[0][i];
			menuItem.y += poss[1][i];
			menuItem.ID = i;
			menuItems.add(menuItem);

			btts[i] = menuItem;

			var f = new FlxSprite(0, 0).loadGraphic(Paths.image('btt/' + optionShit[i] + '-f'));
			f.scale.set(4, 4);
			f.scrollFactor.set(1.2, 1.2);
			f.offset.set(menuItem.width / 2, menuItem.height / 2);
			f.setPosition(menuItem.x, menuItem.y);
			f.ID = i;
			flicker.add(f);
			f.alpha = 0;
		}

		var p = FlxG.save.data.sansProg;
		var m = new FlxSprite(btts[0].x - 100, btts[0].y - 100).loadGraphic(Paths.image('mini/sans'));
		m.visible = (p >= 1);
		m.offset.set(m.width / 2, m.height / 2);
		m.scale.set(3, 3);
		m.scrollFactor.set(1.2, 1.2);
		add(m);
		mini[0] = m;

		m = new FlxSprite(btts[1].x + 100, btts[1].y - 100).loadGraphic(Paths.image('mini/cringe'));
		m.visible = (p >= 2);
		m.offset.set(m.width / 2, m.height / 2);
		m.scale.set(3, 3);
		m.scrollFactor.set(1.2, 1.2);
		add(m);
		mini[1] = m;

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		//versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "FNF: A beautiful day outside 1.0", 12);
		//versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
		FlxTransitionableState.skipNextTransIn = true;

		if (!Main.seenTitle)
		{
			camFollowPos.y = -720;
			FlxG.sound.play(Paths.sound('title'));

			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				Main.playMenuSong();
				menuShow = true;
			});
			Main.seenTitle = true;
		}
		else
		{
			logo.scale.x = 4;
			logo.scale.y = logo.scale.x;
			logo.y = logoFinalY;
			bttAlpha = 1;
			menuShow = true;
			camFollowPos.y = 720 / 2;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;
	var menuShow = false;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
		{
			if (FlxG.sound.music.volume < 0.8)
			{
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			}
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.x = FlxG.width / 2;
		if (menuShow)
		{
			var spd = 12 / (elapsed * 60);
			camFollowPos.y += (FlxG.height / 2 - camFollowPos.y) / spd;
			logo.scale.x += (4 - logo.scale.x) / spd;
			logo.scale.y = logo.scale.x;
			logo.y += (logoFinalY - logo.y) / spd;
			if (bttAlpha < 1)
			{
				bttAlpha += elapsed * 1.25;
			}
		}

		if (!selectedSomethin)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.alpha = bttAlpha;
			});
			miniAlpha = bttAlpha;
		}

		for (s in mini)
		{
			s.alpha = miniAlpha;
		}
		//camFollowPos.setPosition(FlxG.width / 2, FlxG.height / 2);

		if (!selectedSomethin)
		{
			var mChange = 0;

			if (controls.UI_UP_P) mChange = -2;
			if (controls.UI_DOWN_P) mChange = 2;
			if (controls.UI_LEFT_P) mChange = -1;
			if (controls.UI_RIGHT_P) mChange = 1;

			if (mChange != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(mChange);
			}

			if (controls.ACCEPT && menuShow)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					flicker.forEach(function(spr:FlxSprite)
					{
						if (spr.ID == curSelected)
						{
							spr.alpha = 1;
							if(ClientPrefs.flashing) FlxFlicker.flicker(spr, 1.1, 0.15, false);
						}
					});

					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						var daChoice = optionShit[curSelected];
						switch (daChoice)
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							#if MODS_ALLOWED
							case 'mods':
								MusicBeatState.switchState(new ModsMenuState());
							#end
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new options.OptionsState());
						}
					});
					menuItems.forEach(function(spr:FlxSprite)
					{
						/*
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new options.OptionsState());
								}
							});
						}racista
						*/
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}
		else
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (spr.ID != curSelected)
				{
					spr.alpha -= elapsed * 1.3;
				}
			});
			miniAlpha -= elapsed * 1.3;
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(?huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected > 3) curSelected -= 3;
		if (curSelected < 0) curSelected += 3;

		menuItems.forEach(function(spr:FlxSprite)
		{
			//trace(spr.ID, curSelected);
			var gfx = '-n';
			if (spr.ID == curSelected)
			{
				gfx = '-s';
			}
			spr.loadGraphic(Paths.image('btt/' + optionShit[spr.ID] + gfx));
		});
	}
}
