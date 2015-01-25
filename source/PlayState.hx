package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{	
	private var background:FlxGroup;	

	private var playerShip:PlayerShip;
	private var asteroids:FlxGroup;
		
	private var climbcamera_on:Bool;
	private var min_y:Float;
	private var climbonly_deadzone:FlxRect;

	private static var CAMERA_STANDARD_ZOOM = 1;
	private static var CAMERA_MAX_ZOOM = 2;
	
	private var deathCamFrames = 30;
	private var deathZoomInRate:Float;
	private var deathCamDelta:FlxPoint;

	private var debugtext1:FlxText;
	private var debugtext2:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		background = new FlxGroup();
		setupBackground();
		add(background);
		
		playerShip = new PlayerShip(FlxG.width / 2, FlxG.height / 2);
		add(playerShip);
		min_y = playerShip.y;
		
		deathZoomInRate = (CAMERA_MAX_ZOOM - CAMERA_STANDARD_ZOOM) / deathCamFrames;
		
		asteroids = new FlxGroup();
		add(asteroids);
		
		FlxG.camera.follow(playerShip, FlxCamera.STYLE_TOPDOWN_TIGHT);
		FlxG.camera.deadzone.top = FlxG.height / 2;
		FlxG.camera.deadzone.bottom = FlxG.height;
		climbonly_deadzone = FlxG.camera.deadzone;
		climbcamera_on = true;
		
		//createBlackHole();

		debugtext1 = new FlxText(0, 0, 400, "player pos: " + playerShip.x + ", " + playerShip.y);
		debugtext1.scrollFactor.set(0, 0);
		debugtext2 = new FlxText(0, 12, 400, "screen pos: " + FlxG.camera.scroll.x + ", " + FlxG.camera.scroll.y);
		debugtext2.scrollFactor.set(0, 0);
		add(debugtext1);
		add(debugtext2);
		
		super.create();
	}
	
	private function setupBackground():Void {
		var numBackgrounds:Int = 12;
		
		// Far away stars.
		var i:Int = 0;
		while (i < numBackgrounds) {
			var backgroundTile:FlxSprite;
			
			// Far away stars.
			backgroundTile = new FlxSprite(0, -FlxG.height * i);
			backgroundTile.loadGraphic("assets/images/stars_20px.png", false, FlxG.width, FlxG.height);
			backgroundTile.scrollFactor.y = 0.4;
			background.add(backgroundTile);
			
			// Medium-distance stars.
			backgroundTile = new FlxSprite(0, -FlxG.height * i);
			backgroundTile.loadGraphic("assets/images/stars_32px.png", false, FlxG.width, FlxG.height);
			backgroundTile.scrollFactor.y = 0.6;
			background.add(backgroundTile);
			
			// Closer (bigger) stars.
			backgroundTile = new FlxSprite(0, -FlxG.height * i);
			backgroundTile.loadGraphic("assets/images/stars_64px.png", false, FlxG.width, FlxG.height);
			backgroundTile.scrollFactor.y = 0.8;
			background.add(backgroundTile);
			
			i++;
		}
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

		debugtext1.text = Std.string("player pos: " + playerShip.x + ", " + playerShip.y);
		debugtext2.text = Std.string("screen pos: " + FlxG.camera.scroll.x + ", " + FlxG.camera.scroll.y);
		
		manageCamera(playerShip.accelerating);
		
		spawnAsteroids();
		
		if (FlxG.overlap(playerShip, asteroids)) {
			destroyTheShip();
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

	private function manageCamera(climbing: Bool):Void
	{		
		// update min_y
		if (climbcamera_on && playerShip.y < min_y)
			min_y = playerShip.y;
		
		// reenable camera follow if playerShip reaches threshhold
		if (climbing && playerShip.y < min_y && !climbcamera_on)
		{
			FlxG.camera.follow(playerShip, FlxCamera.STYLE_TOPDOWN_TIGHT);
			FlxG.camera.deadzone = climbonly_deadzone;
			climbcamera_on = true;
		}
				
		// disable camera follow if playerShip falls off screen bottom
		if (!climbing && climbcamera_on && playerShip.y > min_y + (FlxG.height / 2 - playerShip.frameHeight))
		{
			FlxG.camera.follow(null);
			climbcamera_on = false;
		}

		// update horizontal camera position manually if follow disabled
		if (!climbcamera_on)
		{
			if (playerShip.x - FlxG.camera.scroll.x < climbonly_deadzone.left)
				FlxG.camera.scroll.x += (playerShip.x - FlxG.camera.scroll.x) - climbonly_deadzone.left;
			else if (playerShip.x - FlxG.camera.scroll.x > (climbonly_deadzone.right - playerShip.frameWidth/2))
				FlxG.camera.scroll.x += (playerShip.x - FlxG.camera.scroll.x) - (climbonly_deadzone.right - playerShip.frameWidth/2);
		}

	}
	
	private function destroyTheShip():Void {
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