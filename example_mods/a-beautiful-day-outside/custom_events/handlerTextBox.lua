local allowCountdown = false
wTime = 0.8;
function onStartCountdown()
	-- Block the first countdown and start a timer of 0.8 seconds to play the dialogue
	if not allowCountdown and isStoryMode and not seenCutscene then
		setProperty('inCutscene', true);
        if (songName == 'Bit-Bone') then wTime = 1.4 end
		runTimer('startDialogue', wTime);
		allowCountdown = true;
		return Function_Stop;
	end
	return Function_Continue;
end

fadeOut = false;

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startDialogue' then -- Timer completed, play dialogue
		startDial(string.lower(songName));
		--startDialogue('dialogue', '');
    elseif (tag == 'endit') then
        --endSong();
        playSound('title');
        makeLuaSprite('sc', 'ut/box', 1280 / 2, 720 - 200);
        setProperty('sc.scale.x', 40);
        setProperty('sc.scale.y', 40);
        setObjectCamera('sc', 'camHUD');

        addLuaSprite('sc', true);

        makeLuaSprite('tt', 'logo', 1280 / 2, 200);
        setProperty('tt.offset.x', getProperty('tt.width') / 2);
        setProperty('tt.scale.x', 6);
        setProperty('tt.scale.y', 6);
        setProperty('tt.antialiasing', false);
        setObjectCamera('tt', 'camHUD');

        addLuaSprite('tt', true);

        runTimer('credit', 3);
    elseif (tag == 'credit') then
        playSound('title');
        makeLuaSprite('cc', 'credit', 1280 / 2, 500);
        setProperty('cc.offset.x', getProperty('cc.width') / 2);
        setProperty('cc.scale.x', 5);
        setProperty('cc.scale.y', 5);
        setProperty('cc.antialiasing', false);
        setObjectCamera('cc', 'camHUD');

        addLuaSprite('cc', true);
        runTimer('thanks', 3);
    elseif (tag == 'thanks') then
        playSound('win');
        makeLuaSprite('th', 'thanks', 1280 / 2, 630);
        setProperty('th.offset.x', getProperty('th.width') / 2);
        setProperty('th.scale.x', 6);
        setProperty('th.scale.y', 6);
        setProperty('th.antialiasing', false);
        setObjectCamera('th', 'camHUD');

        addLuaSprite('th', true);
        runTimer('finish', 3);
    elseif (tag == 'finish') then
        makeLuaSprite('sc2', 'ut/box', 1280 / 2, 720 - 200);
        setProperty('sc2.scale.x', 40);
        setProperty('sc2.scale.y', 40);
        setProperty('sc2.alpha', 0);
        setObjectCamera('sc2', 'camHUD');

        addLuaSprite('sc2', true);
        runTimer('finish2', 2);

        fadeOut = true;
    elseif (tag == 'finish2') then
        endSong();
    end
end


data = {{}};
parrSize = 0;
function reSet(max)
	for i = 0, max, 1 do
		data[i] = {};
	end
	parrSize = max + 1;
end
function getDial(s)
	if (s == 'bit-bone') then
		reSet(7);
		data[0]['txt'] = "Beep!"
		data[0]['side'] = -1
		data[0]['spr'] = "bfNormal"

		data[1]['txt'] = "* uh? who's there?"
		data[1]['side'] = 1
		data[1]['spr'] = "sansNormal"

		data[2]['txt'] = "Bep!"
		data[2]['side'] = -1
		data[2]['spr'] = "bfBeep"

		data[3]['txt'] = "* oh, hey bud. want some#hot dogs?"
		data[3]['side'] = 1
		data[3]['spr'] = "sansSide"

		data[4]['txt'] = "Blop!"
		data[4]['side'] = -1
		data[4]['spr'] = "bfBap"

		data[5]['txt'] = "* you... wanna rap?"
		data[5]['side'] = 1
		data[5]['spr'] = "sansNormal"

		data[6]['txt'] = "* i mean, sure thing bud."
		data[6]['side'] = 1
		data[6]['spr'] = "sansSide"

		data[7]['txt'] = "* that's a good excuse for#slacking on the job."
		data[7]['side'] = 1
		data[7]['spr'] = "sansWink"
    elseif (s == 'spine-crusher') then
        reSet(2);
        data[0]['txt'] = "* oh, sorry pal, did i scare you?"
        data[0]['side'] = 1
        data[0]['spr'] = "sansWink"

        data[1]['txt'] = "a"
        data[1]['side'] = -1
        data[1]['spr'] = "bfAh"

        data[2]['txt'] = "* ehehehehe, my bad."
        data[2]['side'] = 1
        data[2]['spr'] = "sansSide"
    elseif (s == 'fracture') then
        reSet(5);
        data[0]['txt'] = "* ehe."
        data[0]['side'] = 1
        data[0]['spr'] = "sansSide"

        data[1]['txt'] = "Bap?"
        data[1]['side'] = -1
        data[1]['spr'] = "bfBap"

        data[2]['txt'] = "* oh, what's my job?"
        data[2]['side'] = 1
        data[2]['spr'] = "sansNormal"

        data[3]['txt'] = "* nothing, i was just passing by."
        data[3]['side'] = 1
        data[3]['spr'] = "sansSide"

        data[4]['txt'] = "* welp, would you like another#round?"
        data[4]['side'] = 1
        data[4]['spr'] = "sansWink"

        data[5]['txt'] = "Bee!"
        data[5]['side'] = -1
        data[5]['spr'] = "bfBeep"
    elseif (s == 'ending') then
        reSet(7)
        data[0]['txt'] = "* huff... puff... all right, #that's it. all this singing#really tired me out."
        data[0]['side'] = 1
        data[0]['spr'] = "sansTired"

        data[1]['txt'] = "Beep?"
        data[1]['side'] = -1
        data[1]['spr'] = "bfNormal"

        data[2]['txt'] = "* why i was passing by?"
        data[2]['side'] = 1
        data[2]['spr'] = "sansTnormal"

        data[3]['txt'] = "Bep!"
        data[3]['side'] = -1
        data[3]['spr'] = "bfBap"

        data[4]['txt'] = "* oh, i was just passing-"
        data[4]['side'] = 1
        data[4]['spr'] = "sansTside"

        data[5]['txt'] = "* away."
        data[5]['side'] = 1
        data[5]['spr'] = "sansTwink"

        data[6]['txt'] = "..."
        data[6]['side'] = -1
        data[6]['spr'] = "bfAh"

        data[7]['txt'] = "* welp, gotta go, take care pal."
        data[7]['side'] = 1
        data[7]['spr'] = "sansTside"
    elseif (s == 'mas-fuerte-que-tu') then
        reSet(1);
        data[0]['txt'] = "dato curioso!"
		data[0]['side'] = 1
		data[0]['spr'] = "perezNormal"
		data[1]['txt'] = "192.168.73.1"
		data[1]['side'] = 1
		data[1]['spr'] = "perezFuck"

    end
end

dStarted = false;
dEnded = false;
function startDial(name)
    --debugPrint('ssss');
    th = 0;
    parr = 0;
    ind = 0;
    dEnded = false;
    dialId = name;

	getDial(dialId);--'bit-bone');
	dStarted = true;
    makeLuaSprite('screen', 'ut/box', 0, 0);
    setProperty('screen.scale.x', 50);
	setProperty('screen.scale.y', 50);
    setProperty('screen.alpha', 0);
    setObjectCamera('screen', 'camHUD');
    addLuaSprite('screen', false);

	makeLuaSprite('box2', 'ut/txtBox', 1280 / 2, 720 - 200);
	setProperty('box2.offset.x', 289 / 2);
	setProperty('box2.offset.y', 45);
	setProperty('box2.scale.x', 4);
	setProperty('box2.scale.y', 4);
	setProperty('box2.antialiasing', false);
	setObjectCamera('box2', 'camHUD');

	addLuaSprite('box2', true);

    showPort();
end

function endDial()
	removeLuaSprite('box2', true);
    removeLuaSprite('port');
    
    local finish = true;
    if (dialId == 'ending' and not eCutscene) then --11
        eCutscene = true;
        finish = false;
        runTimer('endit', 6);
    end
    
    if (finish) then
        startDialogue('sas', '');
    end
    dEnded = true;
end

th = 0;
parr = 0;
ind = 0;
dialId = '';
eCutscene = false;
eHsp = 0;
eGrav = 0.1;

loaded = {};

xx = 0;
yy = 0;

portY = 720 - 400;
function showPort()
    local n = 'port';
    removeLuaSprite('port');
    makeLuaSprite(n, 'ut/port/'..data[parr]['spr'], 1280 / 2 - 300 - (100 * data[parr]['side']), portY + 10);
    setProperty(n..'.offset.x', getProperty('port.width') / 2);
    setProperty(n..'.offset.y', getProperty('port.height'));
    setProperty(n..'.scale.x', 4);
    setProperty(n..'.scale.y', 4);
    setProperty(n..'.antialiasing', false);
    setObjectCamera(n, 'camHUD');
    addLuaSprite(n, false);
end
function onUpdate(elapsed)
	--[[
	makeLuaSprite('box2', 'ut/box', 1280 / 2, 720 - 200);
	setProperty('box2.offset.x', 50);
	setProperty('box2.offset.y', 50);
	setProperty('box2.scale.x', 3);
	setProperty('box2.antialiasing', false);
	setObjectCamera('box2', 'camHUD');

	addLuaSprite('box2', true);
	]]
    if (eCutscene) then
        if (eHsp <= 0) then
            eHsp = 10;
        end
        eHsp = eHsp - eGrav * (elapsed * 60);
        setProperty('dad.x', getProperty('dad.x') + eHsp * (elapsed*60));
    end

    if (fadeOut) then
        setProperty('sc2.alpha', getProperty('sc2.alpha') + elapsed / 2);
    end

    if (dStarted and not dEnded) then
        if (getProperty('screen.alpha') < 0.5) then
            setProperty('screen.alpha', getProperty('screen.alpha') + elapsed * 2);
        end
    end

    if (dEnded) then
        if (getProperty('screen.alpha') > 0) then
            setProperty('screen.alpha', getProperty('screen.alpha') - elapsed * 2);
        else
            removeLuaSprite('screen');
        end
    end

	if (dStarted) then
		th = th + elapsed * 30;
		local p = parr;
		local str = data[p]['txt'];
		local enderDragon = false;
		if (th > string.len(str)) then
			th = string.len(str);
			enderDragon = true;
		end

        setProperty('port.y', getProperty('port.y') + ((portY - getProperty('port.y')) / 5) * (elapsed * 60));

        local acc = false;
        if keyJustPressed('space') then acc = true end

        local gp = false;
		if (getPropertyFromClass('flixel.FlxG', 'gamepads.numActiveGamepads') > 0) then
			gp = true;
		end

        if (gp) then
            if (getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.A') or getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.B') or getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.X') or getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.Y')) then
                acc = true;
            end
        end


		if (acc) then
			if (not enderDragon) then
				th = string.len(str);
			else
				parr = parr + 1;
                xx = 0;
                yy = 0;

                for i = 0, ind, 1 do
                    local n = 'l'..i;
                    removeLuaSprite(n, true);
                end

				if (parr >= parrSize) then
					endDial();
				else
					th = 0;
					ind = 0;
                    showPort();
				end
			end
		end
		--debugPrint(th)

        local jx = 8 * 4;
        local jy = 14 * 4;
		while (ind < math.floor(th)) do
			local char = string.sub(str, ind + 1, ind + 1);
            local nChar = string.sub(str, ind + 2, ind + 2);

            local skip = false;
            if (char == '#') then
                xx = 0;
                yy = yy + jy;
                if (nChar ~= '*') then
                    xx = xx + jx * 2;
                end
                skip = true;
            end

            if (not skip) then
                local let = char;
                local vc = true;

                if (char == '*') then
                    let = 'ast';
                    vc = false;
                elseif (char == ' ') then
                    let = 'space';
                    vc = false;
                elseif (char == '?') then
                    let = 'qmark';
                elseif (char == '.') then
                    let = 'dot';
                elseif (char == '\'') then
                    let = 'ap';
                elseif (char == ',') then
                    let = 'comma';
                elseif (char == '!') then
                    let = 'exc';
                elseif (char == '-') then
                    let = 'dash';
                else --making sure upper cased shit doesn't count symbols
                    if (string.upper(char) == char) then
                        let = let..'-c';
                    end
                end
                local n = 'l'..ind;
                local fnt = 'sans';
                if (data[p]['side'] == -1) then
                    fnt = 'normal';
                end
                makeLuaSprite(n, 'ut/fnt/'..fnt..'/'..let, 120 + xx, 720 - 290 + yy);
                setProperty(n..'.scale.x', 4);
                setProperty(n..'.scale.y', 4);
                setProperty(n..'.antialiasing', false);
                setObjectCamera(n, 'camHUD');
                addLuaSprite(n, true);
                xx = xx + jx;

                --debugPrint(char);
                if (vc) then
                    local vFile = 'txtSans';
                    if (data[p]['side'] == -1) then
                        vFile = 'dialogue';
                    end

                    --stopSound('vc');
                    playSound(vFile, 1, 'vc');
                end
                --debugPrint('sas')
            end
			ind = ind + 1;
		end
	end
end

function onEndSong()
    --debugPrint('tula')
    if (isStoryMode and string.lower(songName) == 'spine-crusher' and not eCutscene) then
        startDial('ending');
        return Function_Stop;
    elseif (eCutscene) then
        --debugPrint(':(')
        return Function_Continue;
    end
end