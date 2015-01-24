package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import openfl._v2.geom.Point;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private static var PLAYER_ONE_CONTROLS : Array<String> = ["A", "SPACE"];
	private static var PLAYER_TWO_CONTROLS : Array<String> = ["D", "L"];
	
	private static var SHIP_MAX_VELOCITY : FlxPoint = new FlxPoint(256, 512);
	private static var SHIP_ACCELERATION_RATE : FlxPoint = new FlxPoint(8, 8);
	private static var SHIP_DECELLERATION_RATE : FlxPoint = new FlxPoint(2, 2);
	
	private var playerShip:FlxSprite;
	
	private var asteroids:FlxGroup;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		FlxG.mouse.visible = false;
		
		playerShip = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		playerShip.makeGraphic(24, 24, FlxColor.WHITE);
		playerShip.maxVelocity.set(SHIP_MAX_VELOCITY.x, SHIP_MAX_VELOCITY.y);
		playerShip.drag.x = playerShip.maxVelocity.x * SHIP_DECELLERATION_RATE.x;
		add(playerShip);
		
		asteroids = new FlxGroup();
		add(asteroids);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		
		var playerOneButtonIsPressed:Bool = FlxG.keys.anyPressed(PLAYER_ONE_CONTROLS);
		var playerTwoButtonIsPressed:Bool = FlxG.keys.anyPressed(PLAYER_TWO_CONTROLS);
		
		// Four states. Each one is a permutation of whether player 1 and 2 have
		// their button pressed.
		if (playerOneButtonIsPressed && playerTwoButtonIsPressed) {
			playerShip.acceleration.y = -playerShip.maxVelocity.y * SHIP_ACCELERATION_RATE.y;
			playerShip.acceleration.x = 0;
		}
		else if (playerOneButtonIsPressed && !playerTwoButtonIsPressed) {
			playerShip.acceleration.y = playerShip.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			playerShip.acceleration.x = -playerShip.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
		}
		else if (!playerOneButtonIsPressed && playerTwoButtonIsPressed) {
			playerShip.acceleration.y = playerShip.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			playerShip.acceleration.x = playerShip.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
		}
		else if (!playerOneButtonIsPressed && !playerTwoButtonIsPressed) {
			playerShip.acceleration.y = playerShip.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			playerShip.acceleration.x = 0;
		}
		else {
			// Should never happen.
		}
		
		super.update();
		
		spawnAsteroids();
		
		FlxG.collide(playerShip, asteroids);
	}
	
	public function spawnAsteroids():Void {
		
		var asteroidSpawnRate:Float = 1 / 20;
		if (FlxRandom.float() > asteroidSpawnRate) {
			return;
		}
		
		var asteroidSize = 12;
		
		var spawnOnLeft:Bool = FlxRandom.float() > 1 / 2;
		var spawnPosX:Int = spawnOnLeft ? 0 : FlxG.width - asteroidSize;
		var spawnPosY:Int = Std.int(FlxRandom.float() * FlxG.height);
		var asteroid:Asteroid = new Asteroid(spawnPosX, spawnPosY);
		asteroid.makeGraphic(asteroidSize, asteroidSize, FlxColor.RED);
		
		// Give it some speed.
		var minAsteroidSpeed = 100;
		var maxAsteroidSpeed = 200;
		asteroid.velocity.x = (maxAsteroidSpeed - minAsteroidSpeed) * 
			FlxRandom.float() + minAsteroidSpeed;
		
		// Reverse speed if it's starting on the right side of the screen.
		if (!spawnOnLeft) {
			asteroid.velocity.x *= -1;
		}
		
		// Now give it some horizontal speed.
		asteroid.velocity.y = maxAsteroidSpeed * (FlxRandom.float() - 0.5);
		
		
		asteroids.add(asteroid);
	}
}