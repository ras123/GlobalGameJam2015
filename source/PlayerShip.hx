package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;

/**
 * ...
 * @author ...
 */
class PlayerShip extends FlxSprite
{
	public static var PLAYER_SPRITE_WIDTH: Int = 100;
	public static var PLAYER_SPRITE_HEIGHT: Int = 100;
	
	private static var PLAYER_ONE_CONTROLS: Array<String> = ["ENTER"];//, "A", "SPACE"];
	private static var PLAYER_TWO_CONTROLS: Array<String> = ["CAPSLOCK"];//, "D", "L"];
	//private static var DOWN_CONTROLS: Array<String> = ["S"];

	private static var r_booster_acc: FlxPoint = new FlxPoint(-4, 6);
	private static var r_booster_angular_acc: Int = -45;
	private static var l_booster_acc: FlxPoint = new FlxPoint(4, 6);
	private static var l_booster_angular_acc: Int = 45;
	
	//private static var SHIP_MAX_VELOCITY: FlxPoint = new FlxPoint(150, 150);
	//private static var SHIP_ACCELERATION_RATE: FlxPoint = new FlxPoint(4, 4);
	//private static var SHIP_DECELLERATION_RATE: FlxPoint = new FlxPoint(SHIP_MAX_VELOCITY.x * 2, SHIP_MAX_VELOCITY.y * 2);
	private static var EVENT_HORIZON = 150;
	
	private var blackHole: FlxSprite;
	private var blackHoleVisible: Bool = false;	
	
	private var captainOne:FlxSprite;
	private var captainTwo:FlxSprite;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y);

		maxVelocity = new FlxPoint(200, 2000);
		drag = new FlxPoint(100, 400);
		maxAngular = 90;
		angularDrag = 90;
		acceleration = new FlxPoint(0, 400);
		
		//maxVelocity.set(SHIP_MAX_VELOCITY.x, SHIP_MAX_VELOCITY.y);
		//drag.set(SHIP_DECELLERATION_RATE.x, SHIP_DECELLERATION_RATE.y);
		
		this.loadGraphic("assets/images/100spritesheet.png", true, PLAYER_SPRITE_WIDTH, PLAYER_SPRITE_HEIGHT);
		this.animation.add("idle", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4], 10, true);
		this.animation.add("r_booster", [5, 6], 8, true);
		this.animation.add("l_booster", [7, 8], 8, true);
		this.animation.add("f_booster", [12, 13], 8, true);
		this.animation.add("breaking_apart", [10, 11], 1, false);
	}
	
	public function addCaptains(captainOne:FlxSprite, captainTwo:FlxSprite):Void {
		this.captainOne = captainOne;
		captainOne.loadGraphic("assets/images/captsheet.png", true, 250, 300);
		captainOne.animation.add("idle", [0, 1], 4, true);
		captainOne.animation.add("active", [2, 3], 4, true);
		captainOne.scrollFactor.set(0, 0);
		
		this.captainTwo = captainTwo;
		captainTwo.loadGraphic("assets/images/captsheet.png", true, 250, 300);
		captainTwo.animation.add("idle", [4, 5], 4, true);
		captainTwo.animation.add("active", [6, 7], 4, true);
		captainTwo.scrollFactor.set(0, 0);
	}
	
	override public function update():Void
	{
		super.update();
		
		var r_booster_on:Bool = FlxG.keys.anyPressed(PLAYER_ONE_CONTROLS);
		var l_booster_on:Bool = FlxG.keys.anyPressed(PLAYER_TWO_CONTROLS);
		
		if (r_booster_on && l_booster_on)
		{
			velocity.addPoint(FlxAngle.rotatePoint(0, r_booster_acc.y + l_booster_acc.y, 0, 0, angle));
			this.animation.play("f_booster");
		}
		else if (r_booster_on)
		{
			angularVelocity += r_booster_angular_acc;
			velocity.addPoint(FlxAngle.rotatePoint(r_booster_acc.x, r_booster_acc.y, 0, 0, angle));
			this.animation.play("r_booster");
		}
		else if (l_booster_on)
		{
			angularVelocity += l_booster_angular_acc;
			velocity.addPoint(FlxAngle.rotatePoint(l_booster_acc.x, l_booster_acc.y, 0, 0, angle));
			this.animation.play("l_booster");
		}
		else
			this.animation.play("idle");
		
			
		// Captain one animations.
		if (l_booster_on) {
			captainOne.animation.play("active");
		}
		else {
			captainOne.animation.play("idle");
		}
		// Captain two animations.
		if (r_booster_on) {
			captainTwo.animation.play("active");
		}
		else {
			captainTwo.animation.play("idle");
		}
		
		//this.acceleration.set(0, 0);
		//// Four states. Each one is a permutation of whether player 1 and 2 have
		//// their button pressed.
		//if (r_booster_on && l_booster_on) {
			//this.acceleration.y = -this.maxVelocity.y * SHIP_ACCELERATION_RATE.y;
			//this.animation.play("f_booster");
		//}
		//else if (!r_booster_on && l_booster_on) {
			//this.acceleration.x = -this.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
			//this.animation.play("r_booster");
		//}
		//else if (r_booster_on && !l_booster_on) {
			//this.acceleration.x = this.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
			//this.animation.play("l_booster");
		//}
		//else if (FlxG.keys.anyPressed(["S"])) {
			//this.acceleration.y = this.maxVelocity.y * SHIP_ACCELERATION_RATE.y;
			//this.animation.play("idle");
		//}
		//else if (!r_booster_on && !l_booster_on) {
			////this.acceleration.y = this.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			////this.acceleration.x = 0;
			//this.animation.play("idle");
		//}
		//else {
			//// Should never happen.
		//}
		
		if (blackHoleVisible) {
			var x = blackHole.getMidpoint().x - getMidpoint().x;
			var y = blackHole.getMidpoint().y - getMidpoint().y;
			
			// If close enough to the black hole, start feeling the gravitational pull
			if (Math.abs(x) < EVENT_HORIZON * 1.2 && Math.abs(y) < EVENT_HORIZON * 1.2) {
				var gravityPullX = 400 / (Math.sqrt(Math.abs(x)));
				var gravityPullY = 400 / (Math.sqrt(Math.abs(y)));
				var C = 0.8;
				
				// If near even horizon, make controlling the ship more difficult
				if (Math.abs(x) < EVENT_HORIZON && Math.abs(y) < EVENT_HORIZON) {
					C = 1 - C;
					gravityPullX * 2;
					gravityPullY * 2;
				}
				
				if (x < 0) {
					this.acceleration.x = C * this.acceleration.x - gravityPullX;
				} else {
					this.acceleration.x = C * this.acceleration.x + gravityPullX;
				}
				
				if (y < 0) {
					this.acceleration.y = C * this.acceleration.y - gravityPullY;
				} else {
					this.acceleration.y = C * this.acceleration.y + gravityPullY;
				}
			}
		}
		
		//trace("Velocity: " + velocity.x + " " + velocity.y);
		//trace("Acceleration: " + acceleration.x + " " + acceleration.y);
		
		//this.angle = 30 * (velocity.x / maxVelocity.x);
	}
	
	public function setBlackHole(blackHole : FlxSprite):Void {
		this.blackHole = blackHole;
		this.blackHoleVisible = true;
	}
	
}