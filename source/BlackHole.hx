package;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import Math;

/**
 * ...
 * @author ...
 */

enum Size {
	Small;
	Medium;
	Big;
}
 
 class BlackHole extends FlxSprite
{	
	private static var SIZE_SMALL = 600;
	private static var SIZE_MEDIUM = 750;
	private static var SIZE_BIG = 1000;
	private static var ATTRACTION_FACTOR = 400;

	private var attraction:Float;

	public function new(map_width:Int, min_y:Int, max_y:Int, size:EnumValue):Void
	//public function new(x:Int, y:Int, size:EnumValue):Void
	{
		var spawn_x = Std.int(map_width * FlxRandom.floatRanged(0.3, 0.7));
		var spawn_y = FlxRandom.intRanged(min_y, max_y);		
		super(spawn_x, spawn_y);
		//super(x, y);
		
		//immovable = true;
		//solid = false;

		switch (size) {
			case Size.Small:
				attraction = ATTRACTION_FACTOR * SIZE_SMALL;
				setSize(SIZE_SMALL * 1.5, SIZE_SMALL * 1.5);
				offset.set(SIZE_SMALL * -0.25, SIZE_SMALL * -0.25);
				this.loadGraphic("assets/images/bholesmall.png", true, SIZE_SMALL, SIZE_SMALL);
			case Size.Medium:
				attraction = ATTRACTION_FACTOR * SIZE_MEDIUM;
				setSize(SIZE_MEDIUM * 1.5, SIZE_MEDIUM * 1.5);
				offset.set(SIZE_MEDIUM * -0.25, SIZE_MEDIUM * -0.25);
				this.loadGraphic("assets/images/bholemed.png", true, SIZE_MEDIUM, SIZE_MEDIUM);
			case Size.Big:
				attraction = ATTRACTION_FACTOR * SIZE_BIG;
				setSize(SIZE_BIG * 1.5, SIZE_BIG * 1.5);
				offset.set(SIZE_BIG * -0.25, SIZE_BIG * -0.25);
				this.loadGraphic("assets/images/bigblackhole.png", true, SIZE_BIG, SIZE_BIG);
		}
		
		this.animation.add("idle", [0, 1], 8, true);
	}

	override public function update():Void
	{
		super.update();
		animation.play("idle");
	}
	
	public function attract(object:FlxSprite):Void
	{
		var center_pos = new FlxPoint(this.x + this.frameWidth / 2, this.y + this.frameHeight / 2);
		
		var obj_center_pos:FlxPoint = new FlxPoint(object.x + object.frameWidth/2, object.y + object.frameHeight/2);
		var angle_between:Float = FlxAngle.getAngle(obj_center_pos, center_pos);
		var distance_between:Float = FlxMath.getDistance(obj_center_pos, center_pos);
		
		var acceleration:FlxPoint = FlxAngle.rotatePoint(0, attraction * Math.pow(1/distance_between, 2), 0, 0, angle_between);
		object.velocity.add(-acceleration.x, -acceleration.y);
	}
	
}