package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;

typedef MenuCharacterFile = {
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idle_anim:String;
	var confirm_anim:String;
}

class MenuCharacter extends FlxSprite
{
	public var character:String;
	private static var DEFAULT_CHARACTER:String = 'bf';

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}

	public function changeCharacter(?char:String = 'bf') {
		if(char == null) character = '';
		if(char == this.character) return;

		character = char;

		trace(char);
		if (character == 'menu_sans') character = 'source_sans';
		if (character == 'menu_cringe') character = 'source_cringe';
		trace(character);

		antialiasing = ClientPrefs.globalAntialiasing;
		visible = true;

		var dontPlayAnim:Bool = false;
		scale.set(1, 1);
		updateHitbox();

		switch(character) {
			case '' | 'bf' | 'gf':
				visible = false;
				dontPlayAnim = true;
			default:
				var characterPath:String = 'images/menucharacters/' + character + '.json';
				var rawJson = null;

				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if(!FileSystem.exists(path)) {
					path = Paths.getPreloadPath('images/menucharacters/' + DEFAULT_CHARACTER + '.json');
				}
				rawJson = File.getContent(path);

				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if(!Assets.exists(path)) {
					path = Paths.getPreloadPath('images/menucharacters/' + DEFAULT_CHARACTER + '.json');
				}
				rawJson = Assets.getText(path);
				#end
				
				var charFile:MenuCharacterFile = cast Json.parse(rawJson);
				frames = Paths.getSparrowAtlas('menucharacters/' + charFile.image);
				animation.addByPrefix('idle', charFile.idle_anim, 24);
				animation.addByPrefix('confirm', charFile.confirm_anim, 24, false);

				if(charFile.scale != 1) {
					scale.set(charFile.scale, charFile.scale);
					updateHitbox();
				}
				offset.set(offset.x, charFile.position[1]);

				screenCenter(X);
				animation.play('idle');
		}
	}
}
