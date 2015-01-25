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
	
	private static var CAMERA_STANDARD_ZOOM = 1;
	private static var CAMERA_MAX_ZOOM = 2;
	
	private var deathCamFrames = 30;
	private var deathZoomInRate:Float;
	private var deathCamDelta:FlxPoint;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		FlxG.mouse.visible = false;
		
		deathZoomInRate = (CAMERA_MAX_ZOOM - CAMERA_STANDARD_ZOOM) / deathCamFrames;
		
		playerShip = new PlayerShip(FlxG.width / 2, FlxG.height / 2);
		add(playerShip);
		
		asteroids = new FlxGroup();
		add(asteroids);
		
		//createBlackHole();
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
		
		spawnAsteroids();
		
		if (FlxG.overlap(playerShip, asteroids)) {
			var shipMidpoint : FlxPoint = playerShip.getMidpoint();
			var explosion : Explosion = new Explosion(shipMidpoint.x, shipMidpoint.y);
			add(explosion);
			
			playerShip.kill();
			FlxG.camera.shake(0.01, 0.5);
			
			// Calculate death camera movement specs.
			deathCamDelta = new FlxPoint();
			deathCamDelta.x = (FlxG.camera.x - shipMidpoint.x) / deathCamFrames;
			deathCamDelta.y = (FlxG.camera.y - shipMidpoint.y) / deathCamFrames;
		}
		
		if (!playerShip.alive) {
			// Allow players to restart the game or go back to the menu.
			if (FlxG.keys.anyPressed(["SPACE", "R"])) {
				FlxG.cameras.fade(0xff000000, 1, false, restartGame);
			}
			else if (FlxG.keys.anyPressed(["ESCAPE", "M"])) {
				FlxG.cameras.fade(0xff000000, 1, false, goToMainMenu);
			}
			
			// Dramatic zoom!
			if (FlxG.camera.zoom < CAMERA_MAX_ZOOM) {
				FlxG.camera.zoom += deathZoomInRate;				
			
				FlxG.camera.x += deathCamDelta.x;
				FlxG.camera.y += deathCamDelta.y;
			}
			
		}
		
	}
	
	private function restartGame():Void {
		FlxG.switchState(new PlayState());
	}
	
	private function goToMainMenu():Void {
		FlxG.switchState(new MenuState());
	}
	
	public function spawnAsteroids():Void {
		
		var asteroidSpawnRate:Float = 1 / 40; // Chance per frame.
		if (FlxRandom.float() > asteroidSpawnRate) {
			return;
		}
		
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