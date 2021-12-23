canMove = false;
spawned = {};
bProp = {};
bInd = 0;

targetW = 450;
targetH = 300;
boxX = 1280 - 325;
boxY = 720 / 2;
boxW = 0;
boxH = 0;

boxA = 0;

pX = 0;
pY = 0;

isBlue = false;
gravDir = 270;
vsp = 0;
grav = 0.26;

hRemove = false;

curAtk = 'none';
atkTimer = 0;

bts = 0;
bTimer = 0;
succ = 0;

dmgMulti = 1;

local damageTaken = 0;

local forceKill = false;

--stolen xddd
function get_angle(vector1,vector2)
	--Multiply the components of both vectors along the x-axis with each other
	local i = vector1["x"]*vector2["x"]
	local j = vector1["y"]*vector2["y"]
	local k = vector1["z"]*vector2["z"]
	local sumtotal = i+j+k --dot product
	local absoluteA = math.sqrt((vector1["x"]^2)+(vector1["y"]^2)+(vector1["z"]^2))
	local absoluteB = math.sqrt((vector2["x"]^2)+(vector2["y"]^2)+(vector2["z"]^2))
	--now angle :
	local product = absoluteA*absoluteB
	return math.acos(sumtotal/product)
end

function point_direction(x1, y1, x2, y2)
	local v1 = {};
	local v2 = {};

	v1['x'] = 1;
	v1['y'] = 0;
	v1['z'] = 0;

	v2['x'] = x2 - x1;
	v2['y'] = y2 - y1;
	v2['z'] = 0;

	local a = math.deg(get_angle(v1, v2));

	if (y2 > y1) then
		a = -a + 360;
	end

	return (a);
end

function bullInit(i)
	local n = 'b'..i;
	local t = bProp[n..'.type'];

	if (t == 'blaster') then
		--debugPrint('hola');
		bProp[n..'.safe'] = true;
		bProp[n..'.iniAng'] = bProp[n..'.ang'];
		bProp[n..'.iniX'] = bProp[n..'.x'];
		bProp[n..'.iniY'] = bProp[n..'.y'];
		bProp[n..'.state'] = 0;
		bProp[n..'.extend'] = 1;

		if (bProp[n..'.exArg'] == nil) then bProp[n..'.exArg'] = 1 end

		bProp[n..'.ang'] = bProp[n..'.ang'] + 600;
		bProp[n..'.x'] = bProp[n..'.x'] - math.cos(math.rad(bProp[n..'.iniAng'])) * 1280;
		bProp[n..'.y'] = bProp[n..'.y'] + math.sin(math.rad(bProp[n..'.iniAng'])) * 1280;
		setProperty(n..'.alpha', 1);
		stopSound('blaster');
		playSound('blaster', 0.3, 'blaster');

		setProperty(n..'.x', boxX + bProp[n..'.x']);
		setProperty(n..'.y', boxY + bProp[n..'.y']);
	elseif (t == 'blast') then
		bProp[n..'.w'] = 430 * 3;
		--bProp[n..'.h'] = 18 * 3;
		bProp[n..'.safe'] = true;
		bProp[n..'.exDir'] = 1;
		bProp[n..'.sc'] = 2;

		setProperty(n..'.scale.x', 3);
		setProperty(n..'.scale.y', 2);
		setProperty(n..'.alpha', 1);
		setProperty(n..'.visible', false);

		bProp[n..'.adj'] = false;
	end

	if (bProp[n..'.plat']) then
		--setProperty(n..'.offset.y', bProp[n..'.h'] / 4 * 3);
		bProp[n..'.h'] = bProp[n..'.h'] * 1.4;
	end
end

function bullSpawn(type, xx, yy, hsp, vsp, dmg, ang, exArg, exArg2)
	hsp = hsp or 0;
	vsp = vsp or 0;
	dmg = dmg or 1;
	ang = ang or 0;
	exArg = exArg or nil;
	exArg2 = exArg2 or nil
	local name = 'b'..bInd;
	table.insert(spawned, name);
	bProp[name..'.type'] = type;
	bProp[name..'.x'] = xx;
	bProp[name..'.y'] = yy;
	bProp[name..'.hsp'] = hsp;
	bProp[name..'.vsp'] = vsp;
	bProp[name..'.dmg'] = dmg;
	bProp[name..'.ang'] = ang;
	bProp[name..'.exArg'] = exArg;
	bProp[name..'.exArg2'] = exArg2;
	bProp[name..'.unspawn'] = false;
	bProp[name..'.iTime'] = bTimer;

	bProp[name..'.safe'] = false;
	bProp[name..'.adj'] = true;
	bProp[name..'.plat'] = false;
	if (dmg == 0) then bProp[name..'.safe'] = true end

	local t = type;
	local spr = t;

	--here special cases
	if (t == 'plat1' or t == 'plat2' or t == 'plat3') then
		bProp[name..'.plat'] = true;
		bProp[name..'.safe'] = true;
	end

	makeLuaSprite(name, 'ut/bullets/'..spr, boxX + xx, boxY + yy);
	setProperty(name..'.offset.x', getProperty(name..'.width') / 2);
	setProperty(name..'.offset.y', getProperty(name..'.height') / 2);

	bProp[name..'.w'] = getProperty(name..'.width') * 2;
	bProp[name..'.h'] = getProperty(name..'.height') * 2;

	setProperty(name..'.scale.x', 2);
	setProperty(name..'.scale.y', 2);
	setProperty(name..'.alpha', 0);
	setProperty(name..'.angle', ang);
	setProperty(name..'.antialiasing', false);
	addLuaSprite(name, true);
	setObjectCamera(name, 'camHUD');

	bullInit(bInd);

	bInd = bInd + 1;

	return(name);
end

sndTime = 0.0;
function bullUpdate(elapsed)
	hRemove = false;
	bts = bts + elapsed * 60
	for i = 0, bInd - 1, 1 do
		local n = 'b'..i;

		--moving
		succ = bTimer
		while (succ < math.floor(bts)) do
			bullStep(i);
			succ = succ + 1;
		end

		bProp[n..'.x'] = bProp[n..'.x'] + bProp[n..'.hsp'] * (elapsed * 60);
		bProp[n..'.y'] = bProp[n..'.y'] + bProp[n..'.vsp'] * (elapsed * 60);

		local blX = bProp[n..'.x'];
		local blY = bProp[n..'.y'];

		setProperty(n..'.x', boxX + blX);
		setProperty(n..'.y', boxY + blY);
		setProperty(n..'.angle', -bProp[n..'.ang']);
		

		--collision
		local lX = -bProp[n..'.w'] / 2 - 8;
		local rX = bProp[n..'.w'] / 2 + 8;
		local uY = -bProp[n..'.h'] / 2 - 8;
		local dY = bProp[n..'.h'] / 2 + 8;

		local xdif = pX - bProp[n..'.x'];
		local ydif = pY - bProp[n..'.y'];
		local dis = math.sqrt((xdif) ^ 2 + (ydif) ^ 2);

		local vec1 = {};
		local vec2 = {};

		vec1['x'] = math.cos(math.rad(bProp[n..'.ang']));
		vec1['y'] = math.sin(math.rad(bProp[n..'.ang']));
		vec1['z'] = 0;

		vec2['x'] = xdif;
		vec2['y'] = -ydif;
		vec2['z'] = 0;
		local bang = get_angle(vec1, vec2);
		--local bang = math.acos(xdif / dis) - math.rad(bProp[n..'.ang']);
		--local bangy = math.asin(ydif / dis) - math.rad(bProp[n..'.ang']);
		local ppX = math.cos(bang) * dis;
		local ppY = math.sin(bang) * dis;

		local hitIt = (ppX > lX and ppX < rX and ppY > uY and ppY < dY);

		local dmg = bProp[n..'.dmg'];

		if (dmg < 0) then
			setProperty(n..'.color', getColorFromHex('00A1FF'));
			hitIt = hitIt and moving;
		end

		if ((bProp[n..'.unspawn'] == false and bProp[n..'.safe'] == false and canMove) and hitIt) then
			if (hRemove == false) then
				local diffDmg = 2.2;

				if (difficulty == 0) then diffDmg = diffDmg / 2.5;
				elseif (difficulty == 1) then diffDmg = diffDmg / 1.75 end

				local indDmg = math.abs(dmg);
				if (dmgMulti ~= 1) then indDmg = dmgMulti; end
				setProperty('health', getProperty('health') - (elapsed / 1.1) * diffDmg * indDmg * healthLossMult);
				damageTaken = damageTaken + (elapsed * 30) * diffDmg * indDmg * healthLossMult;
				dtRed = dtrMax;
				if (instakillOnMiss) then
					forceKill = true;
				end
				hRemove = true;
			end
		end

		if (bProp[n..'.plat'] and canMove and hitIt) then
			if (vsp >= 0 and pY > blY - 16 and pY < blY + 3) then --and ppY < 8) then
				vsp = 0;
				ground = true;
				pY = blY - 15;
				pX = pX + (bProp[n..'.hsp'] * (elapsed * 60));
			end
		end

		if (bProp[n..'.unspawn']) then
			local ga = getProperty(n..'.alpha');
			setProperty(n..'.alpha', ga - elapsed * 5);
			--if (ga <= 0)
		elseif (bProp[n..'.adj']) then
			setProperty(n..'.alpha', getProperty(n..'.alpha') + elapsed * 5);
		end
	end

	while (bTimer < math.floor(bts)) do
		bTimer = bTimer + 1;
	end

	if (hRemove) then
		if (sndTime <= 0) then 
			playSound('snd_hurt1', 1);
			sndTime = 1;
		else
			sndTime = sndTime - elapsed * 30;
		end
	else
		sndTime = 0;
	end
end

function bullStep(i)
	local n = 'b'..i;
	local t = succ - bProp[n..'.iTime'];
	local tp = bProp[n..'.type'];

	if (tp == 'blaster') then
		local s = bProp[n..'.state'];
		if (s == 0) then
			bProp[n..'.x'] = bProp[n..'.x'] + (bProp[n..'.iniX'] - bProp[n..'.x']) / 5;
			bProp[n..'.y'] = bProp[n..'.y'] + (bProp[n..'.iniY'] - bProp[n..'.y']) / 5;
			bProp[n..'.ang'] = bProp[n..'.ang'] + (bProp[n..'.iniAng'] - bProp[n..'.ang']) / 5;

			bProp[n..'.esp'] = 0;
			if (t == 40) then
				bProp[n..'.state'] = 1;
			end
		elseif (s == 1) then
			bProp[n..'.esp'] = bProp[n..'.esp'] + 0.006;
			bProp[n..'.extend'] = bProp[n..'.extend'] - bProp[n..'.esp'];

			if (t == 48) then
				bProp[n..'.extend'] = 1.2;
				bProp[n..'.state'] = 2;
				bProp[n..'.esp'] = 0;

				removeLuaSprite(n, true);
				makeLuaSprite(n, 'ut/bullets/blasterOpen', boxX + bProp[n..'.x'], boxY + bProp[n..'.y']);
				setProperty(n..'.offset.x', getProperty(n..'.width') / 2);
				setProperty(n..'.offset.y', getProperty(n..'.height') / 2);
				setProperty(n..'.antialiasing', false);
				addLuaSprite(n, true);
				setObjectCamera(n, 'camHUD');
				stopSound('blast_shoot');
				playSound('blast_shoot', 0.5, 'blast_shoot');

				local b = bullSpawn('blast', 0, 0, 0, 0, bProp[n..'.dmg'], 0);
				bProp[b..'.ang'] = bProp[n..'.ang'];
				bProp[n..'.blast'] = b;
				bProp[b..'.exArg'] = bProp[n..'.exArg'];

				triggerEvent('Screen Shake', '0.2,0.005', '0.2,0.005');
			end
		elseif (s == 2) then
			bProp[n..'.esp'] = bProp[n..'.esp'] + 0.3;
			bProp[n..'.hsp'] = -math.cos(math.rad(bProp[n..'.ang'])) * bProp[n..'.esp'];
			bProp[n..'.vsp'] = math.sin(math.rad(bProp[n..'.ang'])) * bProp[n..'.esp'];
			bProp[n..'.extend'] = 1 + math.sin(math.rad(t * 30)) / 20;

			local b = bProp[n..'.blast'];
			setProperty(b..'.visible', true);
			local bdis = (430 * 3 / 2 + 60);
			bProp[b..'.x'] = bProp[n..'.x'] + (math.cos(math.rad(bProp[b..'.ang'])) * bdis);
			bProp[b..'.y'] = bProp[n..'.y'] - (math.sin(math.rad(bProp[b..'.ang'])) * bdis);
		end

		setProperty(n..'.scale.y', 3 * bProp[n..'.extend'] * bProp[n..'.exArg']);
		setProperty(n..'.scale.x', 3 * (1 + (1 - bProp[n..'.extend']) / 3));
	elseif (tp == 'blast') then
		bProp[n..'.h'] = 16 * getProperty(n..'.scale.y');
		bProp[n..'.sc'] = bProp[n..'.sc'] + (bProp[n..'.exDir'] * 0.7);
		if (bProp[n..'.sc'] > 4.5) then
			bProp[n..'.exDir'] = -0.27;
		end
		if (bProp[n..'.sc'] < 3) then
			setProperty(n..'.alpha', getProperty(n..'.alpha') - 0.04);
			if (bProp[n..'.sc'] < 0.5) then
				bProp[n..'.unspawn'] = true;
			end
		end
		setProperty(n..'.scale.y', bProp[n..'.sc'] * bProp[n..'.exArg'] * 1.2);
		bProp[n..'.safe'] = false;
	elseif (tp == 'throwBones') then
		local wt = 20;
		local st = 5;
		local un = 25;
		if (t < wt) then
			bProp[n..'.adj'] = false;
			setProperty(n..'.alpha', 0);
		end
		if (t == wt) then
			stopSound('rise');
			playSound('rise', 1, 'rise');
			local a = math.rad(bProp[n..'.ang']);
			bProp[n..'.hsp'] = math.cos(a) * 13;
			bProp[n..'.vsp'] = -math.sin(a) * 13;
			setProperty(n..'.alpha', 1);
			bProp[n..'.adj'] = true;
		elseif (t == wt + st) then
			bProp[n..'.hsp'] = 0;
			bProp[n..'.vsp'] = 0;
		elseif (t == wt + un) then
			bProp[n..'.unspawn'] = true;
			local a = math.rad(bProp[n..'.ang'] + 180);
			bProp[n..'.hsp'] = math.cos(a) * 10;
			bProp[n..'.vsp'] = -math.sin(a) * 10;
		end
		if (t >= wt + st and t <= wt + st + 4 and 0 == 1) then
			bProp[n..'.x'] = bProp[n..'.x'] + math.random(-1, 1);
			bProp[n..'.y'] = bProp[n..'.y'] + math.random(-1, 1);
		end
	elseif (tp == 'warn') then
		if (t == 1) then
			bProp[n..'.adj'] = false;
			setProperty(n..'.alpha', 1);
		elseif (t == 20) then
			setProperty(n..'.alpha', 0);
			bProp[n..'.unspawn'] = true;
		end
	elseif (tp == 'keys') then
		if (t >= 120) then
			bProp[n..'.unspawn'] = true;
		end
	elseif (tp == 'boneMini') then
		bProp[n..'.ang'] = bProp[n..'.ang'] + 7;
	end
end

function killAll()
	for i = 0, bInd - 1, 1 do
		local n = 'b'..i;
		removeLuaSprite(n, true);
	end
	bInd = 0;
	spawned = {};
	bProp = {};
end

function unspawnAll()
	for i = 0, bInd - 1, 1 do
		local n = 'b'..i;
		bProp[n..'.unspawn'] = true;
		--removeLuaSprite(n, true);
	end
end

function onCreate()
	if (middlescroll) then
		boxX = 1280 / 2;
	end

	makeLuaSprite('box', 'ut/box', boxX, boxY);
	setProperty('box.offset.x', 50);
	setProperty('box.offset.y', 50);
	setProperty('box.antialiasing', false);
	setObjectCamera('box', 'camHUD');

	makeLuaSprite('boxB', 'ut/boxBorder', boxX, boxY);
	setProperty('boxB.offset.x', 50);
	setProperty('boxB.offset.y', 50);
	setProperty('boxB.antialiasing', false);
	setObjectCamera('boxB', 'camHUD');

	addLuaSprite('boxB', false);
	addLuaSprite('box', false);

	makeLuaSprite('p', 'ut/soul', boxX, boxY);
	setProperty('p.offset.x', 8);
	setProperty('p.offset.y', 8);
	setProperty('p.scale.x', 2);
	setProperty('p.scale.y', 2);
	setProperty('p.antialiasing', false);

	addLuaSprite('p', false);
	setObjectCamera('p', 'camHUD');


	--botplay spook oooOOoOOooo
	makeLuaSprite('u', 'ut/uboa', boxX, boxY);
	setProperty('u.scale.x', 3);
	setProperty('u.scale.y', 3);
	setProperty('u.alpha', 0);
	setProperty('u.antialiasing', false);
	addLuaSprite('u', false);
	setObjectCamera('u', 'camHUD');

	makeLuaText('hitsTxt', 'Damage: ', -1, 1280 / 2 - 45, 150);
	setTextAlignment('hitsTxt', 'center');
	if (not downscroll) then
		setProperty('hitsTxt.y', 720 - 150);
	end
	addLuaText('hitsTxt', true);
	setObjectCamera('hitsTxt', 'camHUD');
end

-- -350 + Math.sin((Conductor.songPosition / 1000) * (Conductor.bpm / 60) * 1.5) * 12.5;
moving = false;
ground = false;
rxm = 0;
rym = 0;

dtRed = 0;
dtrMax = 10;
notice = 0;
function onUpdate(elapsed)
	local toW = targetW;
	local toH = targetH;

	if (canMove == false) then
		toW = 0;
		toH = 0;
	end

	boxW = boxW + ((toW - boxW) / (10 / (elapsed * 60)));
	boxH = boxH + ((toH - boxH) / (10 / (elapsed * 60)));

	if (math.ceil(boxW) == toW or math.floor(boxW) == toW) then boxW = toW end
	if (math.ceil(boxH) == toH or math.floor(boxH) == toH) then boxH = toH end

	setProperty('box.scale.x', boxW / 100);
	setProperty('box.scale.y', boxH / 100);

	setProperty('boxB.scale.x', (boxW + 16) / 100);
	setProperty('boxB.scale.y', (boxH + 16) / 100);

	local hColor = getColorFromHex("FF0000");
	if (isBlue) then hColor = getColorFromHex("0000FF") end
	setProperty('p.color', hColor);

	local lBd = -boxW / 2 + 16;
	local rBd = boxW / 2 - 16;
	local uBd = -boxH / 2 + 16;
	local dBd = boxH / 2 - 16;

	--hRemove = true;
	moving = false;
	local lX = pX;
	local lY = pY;
	if (canMove) then

		local lxm = rxm;
		local lym = rym;

		local xmov = 0;
		local ymov = 0;

		local gp = false;
		if (getPropertyFromClass('flixel.FlxG', 'gamepads.numActiveGamepads') > 0) then
			gp = true;
		end

		local kR = getPropertyFromClass('flixel.FlxG', 'keys.pressed.RIGHT') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.D') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.L') or
		(gp and (getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.DPAD_RIGHT') or getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_RIGHT')));
		
		local kL = getPropertyFromClass('flixel.FlxG', 'keys.pressed.LEFT') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.A') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.J') or
		(gp and (getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.DPAD_LEFT') or getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_LEFT')));
		
		local kU = getPropertyFromClass('flixel.FlxG', 'keys.pressed.UP') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.W') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.I') or
		(gp and (getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.DPAD_UP') or getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_UP')));
		
		local kD = getPropertyFromClass('flixel.FlxG', 'keys.pressed.DOWN') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.S') or getPropertyFromClass('flixel.FlxG', 'keys.pressed.K') or
		(gp and (getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.DPAD_DOWN') or getPropertyFromClass('flixel.FlxG', 'gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_DOWN')));
		
		
		if (kR) then
			xmov = xmov + 1;
		end

		if (kL) then
			xmov = xmov - 1;
		end

		if (kD) then
			ymov = ymov + 1;
		end

		if (kU) then
			ymov = ymov - 1;
		end

		rxm = xmov;
		rym = ymov;

		--if (getPropertyFromGroup('playerStrums', 3, 'animation.curAnim.name') == 'pressed') then
		local spd = 4.2 * (elapsed * 60);

		local jSpd = 10;
		if (isBlue) then
			if (ground == false) then
				vsp = vsp + grav * elapsed * 60;
			end

			if ground and ((gravDir == 0 and xmov == -1) or (gravDir == 180 and xmov == 1) or (gravDir == 90 and ymov == 1) or (gravDir == 270 and ymov == -1)) then
				vsp = -jSpd;
			end

			if (vsp < 0 and (((gravDir == 0 or gravDir == 180) and xmov == 0 and lxm ~= 0) or ((gravDir == 90 or gravDir == 270) and ymov == 0 and lym ~= 0))) then
				vsp = vsp / 4;
			end
			if (gravDir == 0 or gravDir == 180) then
				xmov = 0;
			elseif (gravDir == 90 or gravDir == 270) then
				ymov = 0;
			end

			setProperty('p.angle', -gravDir - 90);
		else
			vsp = 0;
			setProperty('p.angle', 0);
		end

		local vBy = vsp * elapsed * 60;
		pX = pX + xmov * spd + math.cos(math.rad(gravDir)) * vBy;
		pY = pY + ymov * spd - math.sin(math.rad(gravDir)) * vBy;

		if (boxA < 1) then boxA = boxA + elapsed*3 end;
	else
		if (boxA > 0) then boxA = boxA - elapsed*3 end;
	end

	ground = false;

	if (pX < lBd) then
		pX = lBd;

		if (gravDir == 180) then
			vsp = 0;
			ground = true;
		end
	elseif (pX > rBd) then
		pX = rBd;

		if (gravDir == 0) then
			vsp = 0;
			ground = true;
		end
	end

	if (pY < uBd) then
		pY = uBd;

		if (gravDir == 90) then
			vsp = 0;
			ground = true;
		elseif (gravDir == 270) then
			vsp = 0;
		end
	elseif (pY > dBd) then
		pY = dBd;

		if (gravDir == 270) then
			vsp = 0;
			ground = true;
		elseif (gravDir == 90) then
			vsp = 0;
		end
	end

	if (botPlay) then
		pX = -5000;
		pY = -5000;
		setProperty('u.alpha', boxA);
	end

	if (ground and heavy) then
		triggerEvent('Screen Shake', '0.2,0.005', '0.2,0.005');
		playSound('impact', 1);
		act = 1;
		heavy = false;
	end

	if (lX ~= pX or lY ~= pY) then
		moving = true;
	end

	if (boxW < 48 and boxH < 48) then
		pX = 0;
		pY = 0;
	end

	setProperty('box.x', boxX);
	setProperty('box.y', boxY);
	setProperty('boxB.x', boxX);
	setProperty('boxB.y', boxY);

	setProperty('p.x', boxX + pX);
	setProperty('p.y', boxY + pY);

	setProperty('p.alpha', boxA);
	setProperty('box.alpha', boxA);
	setProperty('boxB.alpha', boxA);

	if (notice > 0) then
		notice = notice - elapsed * 60;
		setProperty('p.color', getColorFromHex('FFFFFF'));
		setProperty('p.alpha', notice / 10);
	end
	--hRemove = true;
	bullUpdate(elapsed);

	if (getProperty('health') <= 0 and not practice) then
		killAll();
	end

	atkUpdate(elapsed);

	if (forceKill) then
		setProperty('health', 0);
	end
	--setProperty('health', 0);

	setTextString('hitsTxt', 'Damage: '..math.ceil(damageTaken));
	local dtcolor = 'FFFFFF';
	if (dtRed > 0) then
		if (dtRed == dtrMax) then
			dtcolor = 'FF0000';
		elseif (dtRed > dtrMax / 2) then
			dtcolor = 'FF6A00';
		else
			dtcolor = 'FFFFFF';
		end
		dtRed = dtRed - (elapsed * 60);
	end
	setTextColor('hitsTxt', dtcolor);
	--setTextSize('hitsTxt', math.floor(dtscale * 16));
end

th = 0;
spec = '';
function setAtk(atk, s)
	if (atk == '') then atk = 'none' end
	s = s or '';
	curAtk = atk;
	spec = s;
	th = 0;
	atkTimer = 0;
end

function atkUpdate(elapsed)
	if (curAtk ~= 'none') then
		th = th + elapsed * 60;
		--debugPrint(atkTimer);

		while (atkTimer < math.floor(th)) do
			atkStep();
			atkTimer = atkTimer + 1;
		end
	else
		th = 0;
		atkTimer = 0;
	end
end

function atkIni()
	local k = curAtk;
	targetW = 450;
	targetH = 300;
	finTime = 2000;
	isBlue = false;
	gravDir = 270;
	wav = 0;
	act = 0;

	if (k == 'twirl') then
		targetW = 300;
		targetH = 300;
	elseif (k == 'hops' or k == 'hopsRng') then
		isBlue = true;
		targetH = 200;

		if (spec == 'reset') then
			heavy = true;
			vsp = 30;
		end
	elseif (k == 'bluehops') then
		isBlue = true;
		targetH = 200;
		targetW = 550;
	elseif (k == 'leftsine') then
		targetH = 200;
		targetW = 200;
		wav = 0;
		finTime = 120;
	elseif (k == 'blasters_r') then
		targetW = 250;
		targetH = 250;
		wav = 2;
		finTime = 500;
	elseif (k == 'platformRush' or k == 'platformRushRight') then
		targetW = 530;
		targetH = 260;
		isBlue = true;
		--wav = 2;
		finTime = 500;
	elseif (k == 'keys') then
		bullSpawn('keys', 0, -15, 0, 0, 0);
	elseif (k == 'rotSingle') then
		finTime = 1000;
	end
end
function atkStep()
	local k = curAtk;

	if (atkTimer == 0) then
		atkIni();
	end

	--fucking lua doesnt have switch statement yandev code lookin ass
	if (k == 'twirl') then
		if (atkTimer % 45 == 0) then
			bullSpawn('boneH2', -80, -380, 0, 7.1, 1.4);
			bullSpawn('boneH2', 80, 380, 0, -7.1, 1.4);
		end
	elseif (k == 'hops') then
		if (atkTimer % 38 == 0) then
			local sp = -110;
			local rn = 100;
			bullSpawn('boneV1', -500, rn, 8, 0, 1.4);
			bullSpawn('boneV1', 500, rn, -8, 0, 1.4);

			bullSpawn('boneV3', -500, sp, 8, 0);
			bullSpawn('boneV3', 500, sp, -8, 0);
			--bullSpawn('boneV3', -600, math.sin(math.rad(wav * 13)) * rn + sp, 10, 0);
		end
	elseif (k == 'bluehops') then
		local sp = 0;
		local rn = 100;
		if (atkTimer % 45 == 0) then
			bullSpawn('boneV3', -500, sp, 9, 0, -1);

			bullSpawn('boneV1', -700, rn, 9, 0);
			--bullSpawn('boneV3', -600, math.sin(math.rad(wav * 13)) * rn + sp, 10, 0);
		end
	elseif (k == 'leftsine') then
		if (atkTimer % 4 == 0) then
			local sp = 90;
			local rn = 60;
			local side = 1;
			if (spec == 'reversed') then side = -1 end
			bullSpawn('boneV1', 600 * -side, math.sin(math.rad(wav * 13)) * rn - sp, 10 * side, 0);
			bullSpawn('boneV1', 600 * -side, math.sin(math.rad(wav * 13)) * rn + sp, 10 * side, 0);
			wav = wav + 1;
		end
	elseif (k == 'leftrng') then
		targetH = 240
		if (atkTimer % 40 == 0) then
			local sp = 120;
			local rn = math.random(-100, 100);
			bullSpawn('boneV2', -500, rn - sp, 7, 0);
			bullSpawn('boneV2', -500, rn + sp, 7, 0);
		end
		if (atkTimer % 80 == 20) then
			bullSpawn('boneV3', -600, 0, 8, 0, -1);
		end
	elseif (k == 'leftrngfast' or k == 'blasterleft') then
		targetH = 240
		if (atkTimer % 30 == 0) then
			local sp = 120;
			local rn = math.random(-80, 80);
			bullSpawn('boneV2', -500, rn - sp, 7, 0);
			bullSpawn('boneV2', -500, rn + sp, 7, 0);
		end
	elseif (k == 'blasters') then
		if (atkTimer % 20 == 0) then
			local rn = 200;
			local a = math.random(0, 360);
			local bx = math.cos(math.rad(a)) * rn;
			local by = -math.sin(math.rad(a)) * rn;

			local pa = point_direction(bx, by, pX, pY);

			bullSpawn('blaster', bx, by, 0, 0, 1, pa, 0.9);
		end
	elseif (k == 'blasters_s') then
		if (atkTimer % 35 == 0) then
			local rn = 200;
			local a = math.random(0, 360);
			local bx = math.cos(math.rad(a)) * rn;
			local by = -math.sin(math.rad(a)) * rn;

			local pa = point_direction(bx, by, pX, pY);

			bullSpawn('blaster', bx, by, 0, 0, 1, pa, 0.6);
		end
	elseif (k == 'blasters_r') then
		if (atkTimer % 6 == 0) then
			if (wav < 3) then wav = wav + 0.02 end
			local rn = 300;
			local a = atkTimer*wav + 90;
			local bx = math.cos(math.rad(a)) * rn;
			local by = -math.sin(math.rad(a)) * rn;

			local pa = a + 180;

			bullSpawn('blaster', bx, by, 0, 0, 1, pa, 0.5);
		end
	elseif (k == 'blasters_c') then
		if (atkTimer % 1 == 0) then
			local rn = 250;
			local bx = math.random(-rn, rn);
			local by = math.random(-rn, rn);

			local pa = math.random(0, 360);--point_direction(bx, by, pX, pY);

			bullSpawn('blaster', bx, by, 0, 0, 1, pa, 1.1);
		end
	elseif (k == 'blasterCross') then
		targetW = 220;
		targetH = 220;

		local ang = {};
		ang[0] = 270;
		ang[1] = 180;
		ang[2] = 360 - 45;
		ang[3] = 45;

		local dis = 220;
		if (atkTimer % 30 == 0 and wav < 4) then
			bullSpawn('blaster', math.cos(math.rad(180 + ang[wav])) * dis, -math.sin(math.rad(180 + ang[wav])) * dis, 0, 0, 1.3, ang[wav]);
			wav = wav + 1;
		end
	elseif (k == 'platformRush') then
		local ply = 60;
		--debugPrint(atkTimer);
		if (atkTimer == 1) then
			bullSpawn('plat2', -600, ply, 4.1, 0);
			bullSpawn('plat2', -1000, ply, 4.1, 0);
			bullSpawn('plat2', -1400, ply, 4.1, 0);
			bullSpawn('boneV2', -1700, ply - 130, 5, 0);
			bullSpawn('boneV2', -1730, ply - 130, 5, 0);
			--bullSpawn('boneV2', -1730, ply + 130, 5, 0, -1);
			bullSpawn('boneV2', -1760, ply - 130, 5, 0);
		end
		if (atkTimer == 350) then
			bullSpawn('boneV3', -600, ply - 130, 6, 0);
			bullSpawn('boneV3', -700, 10, 6, 0, -1);
			bullSpawn('boneV1', -900, 100, 6, 0);
			bullSpawn('boneV3', -900, -130, 6, 0);
		end
		if (atkTimer == 480) then
			bullSpawn('blaster', -200, -300, 0, 0, 1, 270, 1.1);
		end
		if (atkTimer % 10 == 0 and atkTimer < 340) then
			bullSpawn('boneV1', -400, 140, 4, 0, 0.9);
		end
	elseif (k == 'rotBone') then
		targetH = 32;
		targetW = 200;
		if (atkTimer % 20 == 10) then
			bullSpawn('boneV1', pX, 410, 0, -8);
		end
	elseif (k == 'bigJump') then
		targetH = 250;
		targetW = 550;
		isBlue = true;
		if (atkTimer % 6 == 0 and atkTimer < 60) then
			bullSpawn('boneV2', -660, 100, 12, 0);
		end
	elseif (k == 'gravThrow') then
		targetW = 300;
		if (atkTimer % 50 == 25) then
			vsp = 30;
			heavy = true;
			gravDir = math.floor(math.random(0, 360) / 90) * 90;
			if (spec == 'down') then gravDir = 270 end
			isBlue = true;
		end
		if (act == 1) then
			playSound('warn', 1);
			local a = math.rad(gravDir);
			local sep = 212;
			bullSpawn('throwBones', math.cos(a) * sep, -math.sin(a) * sep, 0, 0, 1, gravDir + 180);
			bullSpawn('warn', 0, 0, 0, 0, 0, gravDir);
			act = 0;
		end
	elseif (k == 'platformRushRight') then
		local ply = 60;
		--debugPrint(atkTimer);
		if (atkTimer == 1) then
			bullSpawn('plat2', 650, ply, -4.6, 0);
			bullSpawn('plat2', 1000, -10, -4.6, 0);
			bullSpawn('plat2', 1200, ply, -4.6, 0);
			bullSpawn('boneV2', 1000, 100, -4.6, 0);

			bullSpawn('boneV2', 1700, ply - 180, -5, 0);
			bullSpawn('plat2', 1700, ply - 60, -5, 0);
			bullSpawn('boneV2', 1900, ply - 160, -5, 0);
			bullSpawn('plat2', 1900, ply - 40, -5, 0);
			--bullSpawn('boneV2', -1730, ply + 130, 5, 0, -1);
			bullSpawn('boneV2', 2100, ply - 190, -5, 0);
			bullSpawn('plat2', 2100, ply - 70, -5, 0);

			bullSpawn('boneV3', 2220, 40, -5, 0);
			bullSpawn('boneV3', -2300, -40, 5, 0);

			bullSpawn('blaster', -400, 90, 0, 0, 1, 0);
		elseif (atkTimer == 250) then
			bullSpawn('blaster', -400, 30, 0, 0, 1, 0, 0.6);
		elseif (atkTimer == 460) then
			bullSpawn('blaster', -400, 90, 0, 0, 1, 0);
		end
		if (atkTimer % 10 == 0 and atkTimer < 340) then
			bullSpawn('boneV1', 400, 140, -4, 0, 0.9);
		end
	elseif (k == 'gasterPlat') then
		targetW = 600;
		targetH = 250;
		isBlue = true;
		if (atkTimer % 50 == 0) then
			bullSpawn('plat2', -500, 48, 5, 0);
			bullSpawn('plat2', 500, -48, -5, 0);
		end
		if (atkTimer % 60 == 59) then
			local rany = math.floor(math.random(-1, 1));
			rany = rany * 100;
			bullSpawn('blaster', -400, rany, 4, 0, 1, 0, 1.1);
		end
	elseif (k == 'blasterFlurry') then
		targetW = 250;
		targetH = 250;
		if (atkTimer == 10 or atkTimer == 55+45) then
			local r = 90;
			bullSpawn('blaster', -r, -r*2, 0, 0, 1, 270, 1.1);
			bullSpawn('blaster', r, r*2, 0, 0, 1, 90, 1.1);
			bullSpawn('blaster', -r*2, -r, 0, 0, 1, 0, 1.1);
			bullSpawn('blaster', r*2, r, 0, 0, 1, 180, 1.1);
		elseif (atkTimer == 55) then
			local d = 220;
			bullSpawn('blaster', -d, -d, 0, 0, 1, 360 - 45);
			bullSpawn('blaster', -d, d, 0, 0, 1, 45);
			bullSpawn('blaster', d, -d, 0, 0, 1, 180 + 45);
			bullSpawn('blaster', d, d, 0, 0, 1, 90 + 45);
		elseif (atkTimer == 145) then
			bullSpawn('blaster', -220, 20, 0, 0, 1, 0, 1.5);
			bullSpawn('blaster', 220, -20, 0, 0, 1, 180, 1.5);
		end
	elseif (k == 'boneSlice') then
		targetW = 240;
		if (atkTimer % 35 == 0) then
			bullSpawn('boneV1', 0, -400, 0, 5);
		end

		local fq = 120;
		if (atkTimer % fq == fq / 2 -1) then
			bullSpawn('blaster', -60, -200, 0, 0, 1, 270);
		end
		if (atkTimer % fq == fq - 1) then
			bullSpawn('blaster', 60, -200, 0, 0, 1, 270);
		end
	elseif (k == 'hopsRng') then
		local sz = 143;
		if (atkTimer % 60 == 0) then
			--local sp = -110;
			local rn = math.random(-70, 70);
			bullSpawn('boneV3', -500, rn - sz, 8, 0, 2);
			bullSpawn('boneV3', 500, rn - sz, -8, 0, 2);

			bullSpawn('boneV3', -500, rn + sz, 8, 0);
			bullSpawn('boneV3', 500, rn + sz, -8, 0);
			--bullSpawn('boneV3', -600, math.sin(math.rad(wav * 13)) * rn + sp, 10, 0);
		end
	elseif (k == 'rotSingle') then
		targetW = 180;
		targetH = 180;
		if (atkTimer == 1) then 
			wav = bullSpawn('boneV3', 0, 500, 0, -6);
		end

		if (atkTimer > 1) then
			bProp[wav..'.ang'] = bProp[wav..'.ang'] + 3;
			if (bProp[wav..'.y'] < 0) then
				bProp[wav..'.vsp'] = 0;
				bProp[wav..'.y'] = 0;
			end
		end
		if (atkTimer % 50 == 10) then
			bullSpawn('boneV3', 600, 0, -7, 0, -1);
		end
	elseif (k == 'boneFlurry') then
		targetH = 250;
		targetW = 300;
		if (atkTimer % 8 == 5) then
			local a = math.sin(math.rad(atkTimer * 2.9)) / 2;
			local s = 6;
			local d = 1;
			if (math.random(0, 10) > 7) then d = -1 end
			bullSpawn('boneMini', -300, 0, math.cos(a) * s, math.sin(a) * s, d);
		end

		if (atkTimer % 12 == 8) then
			local a = math.sin(math.rad(-atkTimer * 2.7)) / 2;
			local s = 6;
			local d = 1;
			if (math.random(0, 10) > 1) then d = -1 end
			bullSpawn('boneMini', -300, 0, math.cos(a) * s, math.sin(a) * s, d);
		end
	elseif (k == 'cave') then
		isBlue = true;
		targetH = 400;
		if (atkTimer % 10 == 0) then
			bullSpawn('boneV1', 400, 210, -4, 0, 0.9);
			bullSpawn('boneV1', -400, -210, 4, 0, 0.9);
		end

		if (atkTimer % 50 == 0) then
			bullSpawn('plat2', 400, 70, -5, 0);
			bullSpawn('plat2', -400, -70, 5, 0);
		end
		if (atkTimer % 90 == 0) then
			bullSpawn('boneV3', 800, 160, -4, 0);
		end
		if (atkTimer % 90 == 60) then
			bullSpawn('boneV3', -800, -160, 4, 0);
		end
	elseif (k == 'elevator') then
		targetH = 400;
		targetW = 200;
		isBlue = true;
		if (atkTimer % 50 == 0) then
			bullSpawn('plat2', 60, 300, 0, -3);
		end

		if (atkTimer % 10 == 0) then
			bullSpawn('boneV1', 400, 220, -4, 0, 0.9);
			bullSpawn('boneV1', -400, -220, 4, 0, 0.9);
		end

		if (atkTimer % 60 == 59) then
			bullSpawn('blaster', -300, math.random(-150, 150), 0, 0);
		end
	end


	--cccc5
	if (k == 'blasterleft') then
		if (atkTimer % 120 == 50) then
			local rn = 300;
			local a = math.random(0, 360);
			local bx = math.cos(math.rad(a)) * rn;
			local by = -250;--math.sin(math.rad(a)) * rn;

			local pa = point_direction(bx, by, pX, pY);

			bullSpawn('blaster', bx, by, 0, 0, -1, pa, 0.5);
		end
	end

	finTime = finTime - 1;

	if (finTime <= 0) then
		atkEnd();
	end
end

function atkEnd()
	finTime = 0;
	curAtk = 'none';
end

function onEvent(name, value1, value2)
	if (name == 'boxOpen') then
		killAll();
		canMove = true;
		setAtk(value1, value2);
	elseif (name == 'boxClose') then
		canMove = false;
		unspawnAll();
		atkEnd();
	elseif (name == 'setAttack') then
		setAtk(value1, value2);
	elseif (name == 'handlerUndertale') then
		if (value1 == 'balance') then
			setProperty('health', 2);
			dmgMulti = 0.3;
		end
	end
end

function onStepHit()
	for i = 0, getProperty('eventNotes.length') - 1, 1 do
		local name = getPropertyFromGroup('eventNotes', i, 1);
		local sTime = (getPropertyFromGroup('eventNotes', i, 0) - noteOffset) / stepCrochet;

		if (curStep == math.floor(sTime - 8) or curStep == math.floor(sTime - 4) or curStep == math.floor(sTime - 2)) then
			if ((name == 'boxOpen' and canMove == false) or name == 'boxClose') then
				--stopSound('notice');
				--playSound('notice', 1, 'notice');
				notice = 10;
			end
		end
	end
end