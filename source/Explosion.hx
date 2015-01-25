package ;

import flixel.FlxSprite;

/**
 * ...
 * @author ...
 */
class Explosion extends FlxSprite
{
	
	private static var SIZE : Int = 200;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		// Called with midpoint x/y, for the sake of centering the explosion.
		super(X  -  SIZE / 2, Y  -  SIZE / 2);
		
		this.loadGraphic("assets/images/200spritesheet.png", true, 200, 200);
		this.animation.add("explode", [0, 1, 2, 3, 4, 5, 6, 7, 8], 16, false);
		
		this.animation.play("explode");
	}
	
	override public function update():Void {
		super.update();
		
		if (this.animation.finished) {
			this.destroy();
		}
	}
	
}