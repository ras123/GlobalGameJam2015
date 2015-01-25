package;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

/**
 * ...
 * @author ...
 */
class BlackHole extends FlxSprite
{
	private static var MIN_SIZE = 480;
	private static var MAX_SIZE = 960;
	private static var BASE_ATTRACTION = 960;

	private var center_pos:FlxPoint;
	private var size:Int;
	private var attraction:Int;
	
	public function new() 
	{
		super();

		immovable = true;
		solid = false;		
	}
	
	public function attract(object:FlxSprite):Void
	{
		
	}
	
}