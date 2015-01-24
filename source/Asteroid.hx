package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

/**
 * ...
 * @author ...
 */
class Asteroid extends FlxSprite
{
	private static var MIN_SPEED:Int = 100;
	private static var MAX_SPEED:Int = 200;
	private static var SIZE:Int = 100;
	private static var MAX_ROTATION_RATE = 5;
	
	private var rotationRate:Float;
	
	public function new() 
	{
		var spawnOnLeft:Bool = FlxRandom.float() > 1 / 2;
		var spawnPosX:Int = spawnOnLeft ? 0 - SIZE : FlxG.width;
		var spawnPosY:Int = Std.int(FlxRandom.float() * FlxG.height);
		super(spawnPosX, spawnPosY);
		
		loadGraphic("assets/images/asteroid1.png");
		
		// Give it some speed.
		this.velocity.x = (MAX_SPEED - MIN_SPEED) * 
			FlxRandom.float() + MIN_SPEED;
		
		// Reverse speed if it's starting on the right side of the screen.
		if (!spawnOnLeft) {
			this.velocity.x *= -1;
		}
		
		// Now give it some horizontal speed.
		this.velocity.y = MAX_SPEED * (FlxRandom.float() - 0.5);
		
		// Rotation rate.
		rotationRate = MAX_ROTATION_RATE * (FlxRandom.float() - 0.5);
	}
	
	override public function update():Void {
		super.update();
		
		this.angle += rotationRate;
	}
}