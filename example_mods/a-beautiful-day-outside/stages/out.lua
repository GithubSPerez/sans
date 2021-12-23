

function onCreate()

	setPropertyFromClass('GameOverSubstate', 'characterName', 'bf-pixel-dead'); --Character json file for the death animation
	--setPropertyFromClass('GameOverSubstate', 'deathSoundName', 'fnf_loss_sfx-pixel'); --put in mods/sounds/

	local suff = '-day';

	if (songName == 'Spine-Crusher') then
		suff = '';
	elseif (songName == 'Mas-fuerte-que-tu' or songName == 'Megalovania') then
		suff = '-night';
	end

	makeLuaSprite('sky', 'stage/sky'..suff, 400, 300);
	setProperty('sky.scale.x', 6);
	setProperty('sky.scale.y', 6);
	setProperty('sky.antialiasing', false);
	setScrollFactor('sky', 0.1, 0.1);

	makeLuaSprite('city', 'stage/mount'..suff, 400, 390);
	setProperty('city.scale.x', 6);
	setProperty('city.scale.y', 6);
	setProperty('city.antialiasing', false);
	setScrollFactor('city', 0.4, 0.4);

	makeLuaSprite('tree_b', 'stage/tree_b'..suff, 400, 480);
	setProperty('tree_b.scale.x', 6);
	setProperty('tree_b.scale.y', 6);
	setProperty('tree_b.antialiasing', false);
	setScrollFactor('tree_b', 0.6, 0.6);

	makeLuaSprite('tree_a', 'stage/tree_a'..suff, 400, 520);
	setProperty('tree_a.scale.x', 6);
	setProperty('tree_a.scale.y', 6);
	setProperty('tree_a.antialiasing', false);
	setScrollFactor('tree_a', 0.8, 0.8);

	makeLuaSprite('gr', 'stage/ground'..suff, 200, 498);
	setProperty('gr.scale.x', 6);
	setProperty('gr.scale.y', 6);
	setProperty('gr.antialiasing', false);

	addLuaSprite('sky', false);
	addLuaSprite('city', false);
	addLuaSprite('tree_b', false);
	addLuaSprite('tree_a', false);
	addLuaSprite('gr', false);

	--bullSpawn('boneV3', 0, 0, 0, 0, 0.01, 20);

	--[[
	addLuaSprite('stagefront', false);
	addLuaSprite('stagelight_left', false);
	addLuaSprite('stagelight_right', false);
	addLuaSprite('stagecurtains', false);
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
	]]
end

function onUpdate(elapsed)
	local dget = 'dad.animation.curAnim'
	if (getProperty(dget..'.name') == 'idle' and getProperty(dget..'.finished')) then
		setProperty(dget..'.curFrame', 0);
		setProperty(dget..'.finished', false);
	end
end