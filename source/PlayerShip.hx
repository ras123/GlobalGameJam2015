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
	private static var PLAYER_ONE_CONTROLS : Array<String> = ["A", "SPACE"];
	private static var PLAYER_TWO_CONTROLS : Array<String> = ["D", "L"];
	
	private static var SHIP_MAX_VELOCITY : FlxPoint = new FlxPoint(256, 512);
	private static var SHIP_ACCELERATION_RATE : FlxPoint = new FlxPoint(8, 8);
	private static var SHIP_DECELLERATION_RATE : FlxPoint = new FlxPoint(2, 2);
	
	public function new(X:Float=0, Y:Float=0, ?SimpleGraphic:Dynamic) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/shipsprite.png");
		maxVelocity.set(SHIP_MAX_VELOCITY.x, SHIP_MAX_VELOCITY.y);
		drag.x = maxVelocity.x * SHIP_DECELLERATION_RATE.x;
	}
	
	override public function update():Void
	{
		super.update();
		
		var playerOneButtonIsPressed:Bool = FlxG.keys.anyPressed(PLAYER_ONE_CONTROLS);
		var playerTwoButtonIsPressed:Bool = FlxG.keys.anyPressed(PLAYER_TWO_CONTROLS);
		
		// Four states. Each one is a permutation of whether player 1 and 2 have
		// their button pressed.
		if (playerOneButtonIsPressed && playerTwoButtonIsPressed) {
			this.acceleration.y = -this.maxVelocity.y * SHIP_ACCELERATION_RATE.y;
			this.acceleration.x = 0;
		}
		else if (playerOneButtonIsPressed && !playerTwoButtonIsPressed) {
			this.acceleration.y = this.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			this.acceleration.x = -this.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
		}
		else if (!playerOneButtonIsPressed && playerTwoButtonIsPressed) {
			this.acceleration.y = this.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			this.acceleration.x = this.maxVelocity.x * SHIP_ACCELERATION_RATE.x;
		}
		else if (!playerOneButtonIsPressed && !playerTwoButtonIsPressed) {
			this.acceleration.y = this.maxVelocity.y * SHIP_DECELLERATION_RATE.y;
			this.acceleration.x = 0;
		}
		else {
			// Should never happen.
		}
		
		this.angle = 30 * (velocity.x / maxVelocity.x);
	}
	
}