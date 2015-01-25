package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.util.FlxRandom;
import flixel.util.FlxPoint;

/**
 * ...
 * @author ...
 */
class Mine extends FlxSprite
{

	private var beeping:Bool = false;
	public var exploded:Bool = false;
	private var slowBeepingTimer:FlxTimer;
	private var fastBeepingTimer:FlxTimer;
	private var timer:FlxTimer;
	private static var TIME_TO_EXPLOSION = 3;
	private static var SIZE:Int = 100;
	
	public function new() 
	{
		var spawnPosX:Int = Std.int(FlxRandom.float() * FlxG.width);
		var spawnPosY:Int = Std.int(FlxRandom.float() * FlxG.height + FlxG.camera.scroll.y);
		super(spawnPosX, spawnPosY);
		
		loadGraphic("assets/images/100spritesheet.png", true, 100, 100);
		animation.add("idle", [31], 1, false);
	}
	
	override public function update():Void
	{
		// TODO: Kill the object when it's not visible any more
		/*if (x > PlayState.BGTILE_HORIZONTAL_LENGTHS || x < 0) 
			kill();*/
			
		super.update();
		
		if (beeping) {
			animation.play("beeping");
		} else {
			animation.play("idle");
		}
	}
	
	private function beepingSound(timer:FlxTimer):Void
	{
		FlxG.sound.play("assets/sounds/beep.wav");
	}
	
	public function startBeeping():Void
	{
		animation.add("beeping", [30, 31], 2, true);
		slowBeepingTimer = new FlxTimer(1, beepingSound, 2);
		fastBeepingTimer = new FlxTimer(2, fastBeeping);
		timer = new FlxTimer(TIME_TO_EXPLOSION, explode);
		beeping = true;
		FlxG.sound.play("assets/sounds/beep.wav");
	}
	
	public function stopBeeping():Void
	{
		beeping = false;
		timer.cancel();
		slowBeepingTimer.cancel();
		fastBeepingTimer.cancel();
	}
	
	public function isBeeping():Bool
	{
		return beeping;
	}
	
	private function fastBeeping(timer:FlxTimer):Void
	{
		animation.add("beeping", [30, 31], 8, true);
		new FlxTimer(.25, beepingSound, 4);
	}
	
	private function explode(timer:FlxTimer):Void
	{
		exploded = true;
	}
}