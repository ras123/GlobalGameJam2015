package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * ...
 * @author ...
 */
class StatsOverlay extends FlxGroup
{	
	private static var BANNER_HEIGHT:Int = 300;
	
	private static var ANIMATION_DURATION:Float = 60; // Frames
	
	private static var bannerStartX:Float;
	private static var bannerStartY:Float;
	private static var bannerTargetX:Float;
	private static var bannerTargetY:Float;
	
	private var heightTextStartX:Float;
	private var heightTextTargetX:Float;
	
	private var background:FlxSprite;
	private var heightText:FlxText;
	private var instructionsText:FlxText;
	
	private var animationCounter:Int = 0;
	private var blinkCounter:Int = 0;
	
	public function new(maxHeight:Int) 
	{
		super();
		
		bannerStartX = -FlxG.width;
		bannerStartY = FlxG.height / 2 - BANNER_HEIGHT / 2; 
		bannerTargetX = 0;
		bannerTargetY = bannerStartY;
		
		background = new FlxSprite(bannerStartX, bannerStartY);
		background.scrollFactor.set(0, 0);
		background.makeGraphic(FlxG.width, BANNER_HEIGHT, 0xaa00CC00);
		add(background);
		
		heightTextStartX = FlxG.width;
		heightTextTargetX = 0;
		heightText = new FlxText(heightTextStartX, bannerStartY + 100, FlxG.width, maxHeight + " m", 60);
		heightText.alignment = "center";
		heightText.scrollFactor.set(0, 0);
		add(heightText);
		
		instructionsText = new FlxText(0, bannerStartY + BANNER_HEIGHT - 80, FlxG.width, "SPACE:\tTRY AGAIN\nESC:\tMENU", 20);
		instructionsText.alignment = "center";
		instructionsText.scrollFactor.set(0, 0);
		instructionsText.visible = false;
		add(instructionsText);
	}
	
	override public function update():Void {
		super.update();
		
		if (animationCounter <= ANIMATION_DURATION) {
			background.x = (animationCounter / ANIMATION_DURATION) * (bannerTargetX - bannerStartX) + bannerStartX;
			animationCounter++;
			
			heightText.x = (animationCounter / ANIMATION_DURATION) * (heightTextTargetX - heightTextStartX) + heightTextStartX;
			
			// If we're in the last iteration turn on the instructions, since
			// everything else is in place.
			if (animationCounter > ANIMATION_DURATION) {
				instructionsText.visible = true;
				
				// And some screen shake for good measure :)
				FlxG.camera.shake(0.01, 0.3);
			}
		}
		else {
			blinkCounter++;
			if (blinkCounter % 40 == 0) {
				instructionsText.visible = !instructionsText.visible;
			}			
		}

	}
	
}