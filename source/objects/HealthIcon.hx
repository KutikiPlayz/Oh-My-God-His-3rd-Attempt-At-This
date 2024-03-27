package objects;

import openfl.Assets;

enum IconType {
	NEUTRAL;
	LOSING;
	WINNING;
}

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public var hasLosing(default, null):Bool = false;
	public var hasWinning(default, null):Bool = false;
	public var isAnimated(default, null):Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false, ?allowGPU:Bool = true)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, allowGPU);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, ?allowGPU:Bool = true) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon

			isAnimated = Paths.fileExists('images/' + name + '.xml', TEXT);
			if (!isAnimated) {
				var graphic = Paths.image(name, allowGPU);
				var icons = graphic.width / graphic.height;
				if (icons > 1) hasLosing = true;
				if (icons == 3) hasWinning = true;
				loadGraphic(graphic, true, Math.floor(graphic.width / icons), Math.floor(graphic.height));
				iconOffsets[0] = (width - 150) / icons;
				iconOffsets[1] = (height - 150) / icons;
				updateHitbox();
	
				var frames = [0];
				if (hasLosing) frames.push(1);
				if (hasWinning) frames.push(2);
				animation.add(char, frames, 0, false, isPlayer);
				animation.play(char);
			} else {
				var xml = Assets.getText(Paths.getPath('images/$name.xml', TEXT));
				hasLosing = xml.contains('losing');
				hasWinning = xml.contains('winning');
				frames = Paths.getSparrowAtlas(name, allowGPU);
				animation.addByPrefix('neutral', 'neutral');
				if (hasLosing) animation.addByPrefix('losing', 'losing');
				if (hasWinning) animation.addByPrefix('winning', 'winning');
				animation.play('neutral');
			}
			this.char = char;

			if(char.endsWith('-pixel'))
				antialiasing = false;
			else
				antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	public function playAnim(type:IconType) {
		if (type == LOSING && hasLosing)
			if (isAnimated) animation.play('losing'); else animation.curAnim.curFrame = 1;
		else if (type == WINNING && hasWinning)
			if (isAnimated) animation.play('winning'); else animation.curAnim.curFrame = 2;
		else
			if (isAnimated) animation.play('neutral'); else animation.curAnim.curFrame = 0;
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}
