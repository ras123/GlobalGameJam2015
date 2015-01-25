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
import flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{	
	private var playerShip:PlayerShip;
	private var asteroids:FlxGroup;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		FlxG.mouse.visible = false;
		
		playerShip = new PlayerShip(FlxG.width / 2, FlxG.height / 2);
		add(playerShip);
		
		asteroids = new FlxGroup();
		add(asteroids);
		
		createBlackHole();
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
		super.update();
		
		//spawnAsteroids();
		
		FlxG.collide(playerShip, asteroids);
	}
	
	public function spawnAsteroids():Void {
		
		var asteroidSpawnRate:Float = 1 / 20;
		if (FlxRandom.float() > asteroidSpawnRate) {
			return;
		}
		
		/*
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
		*/
		
		var asteroid:Asteroid = new Asteroid();
		
		asteroids.add(asteroid);
		
	}
	
	public function createBlackHole():Void {
		var blackHole = new FlxSprite(FlxG.width / 4, FlxG.height / 4);
		blackHole.makeGraphic(48, 48, FlxColor.RED);
		playerShip.setBlackHole(blackHole);
		add(blackHole);
	}
}