package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.FlxObject;
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
	public static var BGTILE_HORIZONTAL_LENGTHS: Int = 1920;
	public static var BGTILE_VERTICAL_LENGTHS: Int = 960;
	public static var BG_VERTICAL_TILES: Int = 16;
	
	private var background:FlxGroup;
	private var transitionNodes: FlxGroup;
	private var playerShip:PlayerShip;

	private var hazards: FlxGroup;
	private var asteroids: FlxGroup;
	
	private var climbcamera_on:Bool;
	private var min_y:Float;
	private var climbonly_deadzone:FlxRect;

	private static var CAMERA_STANDARD_ZOOM = 1;
	private static var CAMERA_MAX_ZOOM = 2;
	
	private static var deathCamFrames = 30;
	private var deathZoomInRate:Float = (CAMERA_MAX_ZOOM - CAMERA_STANDARD_ZOOM) / deathCamFrames;
	private var deathCamDelta:FlxPoint;

	private var debugtext1:FlxText;
	private var debugtext2:FlxText;
	
	private var heightMeter:FlxText;
	private var maxHeightAchieved:Float = 0;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		
		background = new FlxGroup();
		setupBackground();
		add(background);
		
		playerShip = new PlayerShip((FlxG.worldBounds.right - FlxG.worldBounds.left)/2 - (PlayerShip.PLAYER_SPRITE_WIDTH/2),
									 FlxG.worldBounds.height - (12 + 100) - PlayerShip.PLAYER_SPRITE_HEIGHT);
		add(playerShip);
		min_y = playerShip.y;

		transitionNodes = new FlxGroup();
		var launchpad = new FlxSprite(Std.int(FlxG.worldBounds.right - FlxG.worldBounds.left) / 2 - 60, Std.int(FlxG.worldBounds.bottom) - (12 + 100));
		launchpad.makeGraphic(120, 16, 0xcc44ff00);
		launchpad.immovable = true;
		transitionNodes.add(launchpad);
		
		var target = new FlxSprite(Std.int(FlxG.worldBounds.right - FlxG.worldBounds.left) / 2 - 40, 100);
		target.makeGraphic(160, 24, FlxColor.SILVER);
		target.immovable = true;
		transitionNodes.add(target);
		add(transitionNodes);
		
		hazards = new FlxGroup();
		var floor = new FlxSprite(0, FlxG.worldBounds.bottom - 100);
		floor.makeGraphic(Std.int(FlxG.worldBounds.width), 100, FlxColor.BROWN);
		hazards.add(floor);

		var l_wall1 = new FlxSprite(0, 0);
		l_wall1.makeGraphic(60, Std.int(FlxG.worldBounds.bottom/2), 0x66fc0fc0);
		hazards.add(l_wall1);
		var l_wall2 = new FlxSprite(0, FlxG.worldBounds.bottom/2);
		l_wall2.makeGraphic(60, Std.int(FlxG.worldBounds.bottom/2), 0x66fc0fc0);
		hazards.add(l_wall2);
		
		var r_wall1 = new FlxSprite(FlxG.worldBounds.right - 60, 0);
		r_wall1.makeGraphic(60, Std.int(FlxG.worldBounds.bottom/2), 0x66fc0fc0);
		hazards.add(r_wall1);
		var r_wall2 = new FlxSprite(FlxG.worldBounds.right - 60, FlxG.worldBounds.bottom/2);
		r_wall2.makeGraphic(60, Std.int(FlxG.worldBounds.bottom), 0x66fc0fc0);
		hazards.add(r_wall2);
		
		var ceiling = new FlxSprite(0, FlxG.worldBounds.top);
		ceiling.makeGraphic(Std.int(FlxG.worldBounds.width), 100, FlxColor.CHARCOAL);
		hazards.add(ceiling);
		
		asteroids = new FlxGroup();
		hazards.add(asteroids);
		add(hazards);

		FlxG.camera.follow(playerShip, FlxCamera.STYLE_TOPDOWN_TIGHT);
		//FlxG.camera.deadzone.top = FlxG.height / 2;
		//FlxG.camera.deadzone.bottom = FlxG.height;
		//climbonly_deadzone = FlxG.camera.deadzone;
		climbcamera_on = true;
		
		//createBlackHole();
		
		heightMeter = new FlxText(60, 60, 250, "Height: 0m");
		heightMeter.size = 20;
		heightMeter.scrollFactor.x = heightMeter.scrollFactor.y = 0;
		//add(heightMeter);
		
		debugtext1 = new FlxText(0, 0, 400, "player pos: " + playerShip.x + ", " + playerShip.y);
		debugtext1.scrollFactor.set(0, 0);
		//debugtext2 = new FlxText(0, 12, 400, "screen pos: " + FlxG.camera.scroll.x + ", " + FlxG.camera.scroll.y);
		debugtext2 = new FlxText(0, 12, 400, "world bounds: " + FlxG.worldBounds.top + ", " + FlxG.worldBounds.bottom);
		debugtext2.scrollFactor.set(0, 0);
		add(debugtext1);
		add(debugtext2);
		
		super.create();
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		if (playerShip.isTouching(FlxObject.FLOOR)) {
			playerShip.velocity.y -= 5;
		}
		
		super.update();

		debugtext1.text = Std.string("player pos: " + playerShip.x + ", " + playerShip.y);
		//debugtext2.text = Std.string("screen pos: " + FlxG.camera.scroll.x + ", " + FlxG.camera.scroll.y);
		
		manageCamera(playerShip.velocity.y < 0);
		
		spawnAsteroids();
		
		//FlxG.overlap(playerShip, hazards, doPrecisionOverlap);
		FlxG.overlap(playerShip, hazards, destroyTheShip, processDestroyShip);
		FlxG.collide(playerShip, transitionNodes);
		
		updateHeightCounter();
		
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
				//FlxG.camera.zoom += deathZoomInRate;				
			
				//FlxG.camera.x += deathCamDelta.x;
				//FlxG.camera.y += deathCamDelta.y;
			}
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

	private function setupBackground():Void {
		var i:Int = 0;
		while (i < BG_VERTICAL_TILES) {
			var backgroundTile:FlxSprite;
			
			// Far away stars.
			backgroundTile = new FlxSprite(0, BGTILE_VERTICAL_LENGTHS * i);
			//backgroundTile.loadGraphic("assets/images/stars_20px.png", false, FlxG.width, FlxG.height);
			backgroundTile.loadGraphic("assets/images/starssmall1920.png", false, BGTILE_HORIZONTAL_LENGTHS, BGTILE_VERTICAL_LENGTHS);
			backgroundTile.scrollFactor.y = 0.4;
			background.add(backgroundTile);
			
			// Medium-distance stars.
			backgroundTile = new FlxSprite(0, BGTILE_VERTICAL_LENGTHS * i);
			//backgroundTile.loadGraphic("assets/images/stars_32px.png", false, FlxG.width, FlxG.height);
			backgroundTile.loadGraphic("assets/images/starsmed1920.png", false, BGTILE_HORIZONTAL_LENGTHS, BGTILE_VERTICAL_LENGTHS);
			backgroundTile.scrollFactor.y = 0.6;
			background.add(backgroundTile);
			
			// Closer (bigger) stars.
			backgroundTile = new FlxSprite(0, 
			
			BGTILE_VERTICAL_LENGTHS * i);
			//backgroundTile.loadGraphic("assets/images/stars_64px.png", false, FlxG.width, FlxG.height);
			backgroundTile.loadGraphic("assets/images/starsbig1920.png", false, BGTILE_HORIZONTAL_LENGTHS, BGTILE_VERTICAL_LENGTHS);
			backgroundTile.scrollFactor.y = 0.8;
			background.add(backgroundTile);
			
			i++;
		}

		// Update the world boundaries and number of divisions for proper collision.
		FlxG.worldBounds.set(0, 0, BGTILE_HORIZONTAL_LENGTHS, BGTILE_VERTICAL_LENGTHS * BG_VERTICAL_TILES);
		if (BG_VERTICAL_TILES > 12)
			FlxG.worldDivisions = Std.int(BG_VERTICAL_TILES/2);
		// Update camera boundaries
		FlxG.camera.setBounds(0, 0, BGTILE_HORIZONTAL_LENGTHS, BGTILE_VERTICAL_LENGTHS * BG_VERTICAL_TILES);
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
			//FlxG.camera.follow(null);
			//climbcamera_on = false;
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
	
	private function updateHeightCounter():Void {
		heightMeter.text = "Height: " + (FlxG.worldBounds.height - min_y) + "m";
	}
	
	//private function doPrecisionOverlap(sprite1:FlxSprite, sprite2:FlxSprite):Void {
		//if (FlxG.pixelPerfectOverlap(sprite1, sprite2)) {
			//destroyTheShip();
		//}
	//}

	private function processDestroyShip(ship:FlxSprite, object:FlxSprite):Bool {
		return FlxG.pixelPerfectOverlap(ship, object, 0x66);
	}
	
	private function destroyTheShip(ship:FlxSprite, object:FlxSprite):Void {
		var shipMidpoint:FlxPoint = ship.getMidpoint();
		var explosion:Explosion = new Explosion(shipMidpoint.x, shipMidpoint.y);
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
		
		var asteroidSpawnRate:Float = 1 / 200; // Chance per frame.
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