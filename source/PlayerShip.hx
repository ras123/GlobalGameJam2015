package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * ...
 * @author ...
 */
class PlayerShip extends FlxSprite
{
	private static var PLAYER_ONE_CONTROLS : Array<String> = ["ENTER", "A", "SPACE"];
	private static var PLAYER_TWO_CONTROLS : Array<String> = ["CAPSLOCK", "D", "L"];
	private static var DOWN_CONTROLS : Array<String> = ["S"];
	
	private static var SHIP_MAX_VELOCITY : FlxPoint = new FlxPoint(150, 150);
	private static var SHIP_ACCELERATION_RATE : FlxPoint = new FlxPoint(4, 4);
	private static var SHIP_DECELLERATION_RATE : FlxPoint = new FlxPoint(SHIP_MAX_VELOCITY.x * 2, SHIP_MAX_VELOCITY.y * 2);
	private static var EVENT_HORIZON = 150;
	
	private var blackHole : FlxSprite;
	private var blackHoleVisible : Bool = false;
	
	public var accelerating : Bool;
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y);
		
		maxVelocity.set(SHIP_MAX_VELOCITY.x, SHIP_MAX_VELOCITY.y);
		drag.set(SHIP_DECELLERATION_RATE.x, SHIP_DECELLERATION_RATE.y);
		
		this.loadGraphic("assets/images/100spritesheet.png", true, 100, 100);
		this.animation.add("idle", [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4], 10, true);
		this.animation.add("boost_left", [5, 6], 8, true);
		this.animation.add("boost_right", [7, 8], 8, true);
		this.animation.add("breaking_apart", [10, 11], 1, false);
		this.animation.add("boost_forward", [12, 13], 8, true);

		accelerating = false;
	}
	
	override public function update():Void
	{
		super.update();
		
		var playerOneButtonIsPressed:Bool = FlxG.keys.anyPressed(PLAYER_ONE_CONTROLS);
		var playerTwoButtonIsPressed:Bool = FlxG.keys.anyPressed(PLAYER_TWO_CONTROLS);

		if (playerOneButtonIsPressed || playerTwoButtonIsPressed)
			accelerating = true;
		
		this.acceleration.set(0, 0);
		// Four states. Each one is a permutation of whether player 1 and 2 have
		// their button pressed.
		if (playerOneButtonIsPressed && playerTwoButtonIsPressed) {
			this.acceleration.y = -this.maxVelocity.y * SHIP_ACCELERATION_RATE.y;
			this.animation.play("boost_forward");
		}
		else if (!playerOneButtonIsPressed && playerTwoButtonIsPressed) {
			this.acceleration.x = -this.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
			this.animation.play("boost_left");
		}
		else if (playerOneButtonIsPressed && !playerTwoButtonIsPressed) {
			this.acceleration.x = this.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
			this.animation.play("boost_right");
		}
		else if (FlxG.keys.anyPressed(["S"])) {
			this.acceleration.y = this.maxVelocity.y * SHIP_ACCELERATION_RATE.y;
			this.animation.play("idle");
		}
		else if (!playerOneButtonIsPressed && !playerTwoButtonIsPressed) {
			//this.acceleration.y = this.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			//this.acceleration.x = 0;
			this.animation.play("idle");
		}
		else {
			// Should never happen.
		}
		
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
		
		this.angle = 30 * (velocity.x / maxVelocity.x);
	}
	
	public function setBlackHole(blackHole : FlxSprite):Void {
		this.blackHole = blackHole;
		this.blackHoleVisible = true;
	}
	
}