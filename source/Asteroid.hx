package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.util.FlxAngle;
import haxe.Constraints.FlatEnum;

import Math;

/**
 * ...
 * @author ...
 */
class Asteroid extends FlxSprite
{
	private static var MIN_SPEED:Int = 60;
	private static var MAX_SPEED:Int = 100;
	private static var SIZE:Int = 100;
	private static var MAX_ROTATION_RATE = 5;
	
	private var rotationRate:Float;
	
	public function new() 
	{
		var spawnOnLeft:Bool = FlxRandom.float() > 1 / 2;
		var rightSpawnLocation:Float = FlxG.camera.scroll.x + FlxG.width;
		var spawnPosX:Float = spawnOnLeft ? FlxG.camera.scroll.x - SIZE : rightSpawnLocation;
		
		// Y spawn position depends on where the player is, so add the camera
		// coordinates.
		var screenWidthsToSpawnOn:Int = 5;
		var minSpawnPosY:Float = FlxG.camera.scroll.y - screenWidthsToSpawnOn*FlxG.height;
		var maxSpawnPosY:Float = minSpawnPosY + 2*screenWidthsToSpawnOn*FlxG.height;
		var spawnPosY:Float = (maxSpawnPosY - minSpawnPosY) * FlxRandom.float() + minSpawnPosY;
		super(spawnPosX, spawnPosY);
		
		// Three asteroid graphics. Load randomly.
		var asteroidNumber = FlxRandom.intRanged(1, 3);
		loadGraphic("assets/images/asteroid" + asteroidNumber + ".png");
		
		
		// Give it some speed.
		this.velocity.x = (MAX_SPEED - MIN_SPEED) * FlxRandom.float() + MIN_SPEED;
		
		// Reverse speed if it's starting on the right side of the screen.
		if (!spawnOnLeft) {
			this.velocity.x *= -1;
		}
		
		// Now give it some horizontal speed.
		this.velocity.y = MAX_SPEED * (FlxRandom.float() - 0.5);
		
		// Rotation rate.
		rotationRate = MAX_ROTATION_RATE * (FlxRandom.float() - 0.5);
		
		// Asteroid 2 graphic doesn't look good rotating (kinda looks like a 
		// commet). Remove the rotation, and make sure the orientation is set
		// properly.
		if (asteroidNumber == 2) {
			rotationRate = 0;
			// To get the asteroid flying straight calculate the initial angle 
			// based on the velocities. 
			this.angle = 45 + FlxAngle.TO_DEG * Math.tan(velocity.y / velocity.x);
			if (spawnOnLeft) {
				this.angle += 180;
			}
		}
	}
	
	override public function update():Void {
		if (x > PlayState.BGTILE_HORIZONTAL_LENGTHS || x < 0) 
			kill();
		
		this.angle += rotationRate;
		super.update();		
	}
}