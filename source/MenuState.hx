package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	
	private var text1:FlxText;
	private var text1BlinkCounter:Int = 0;
	
	private var background:FlxSprite;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.state.bgColor = 0xFF000000;
		
		background = new FlxSprite(0, 0);
		background.loadGraphic("assets/images/readyscreen.png", true, 768, 1152);
		background.animation.add("idle", [0, 1], 1, true);
		background.animation.play("idle");
		add(background);
		
		text1 = new FlxText( 0, FlxG.height - 100, FlxG.width, "PRESS SPACE TO START");
		text1.alignment = "center";
		text1.size = 40;
		text1.visible = true;
		add(text1);
		
		super.create();
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
	
		if (FlxG.keys.anyPressed(["A", "SPACE", "R"])) {
			FlxG.cameras.fade(0xff000000, 1, false, startGame);
		}
		
		text1BlinkCounter++;
		if (text1BlinkCounter % 60 == 0) {
			//text1.visible = !text1.visible;
		}
	}
	
	private function startGame():Void {
		FlxG.switchState(new PlayState());
	}
}