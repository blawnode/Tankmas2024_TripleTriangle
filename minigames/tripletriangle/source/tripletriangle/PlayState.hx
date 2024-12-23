package tripletriangle;

import tripletriangle.GenericCircle.CircleType;
import ui.Cursor;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxGroup;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

#if ADVENT
import utils.OverlayGlobal as Global;
#else
import utils.Global;
#end

enum UIUnlockableType{
	circle;  // With "active" status.
	spikeSkin;  // With "locked" and "chosen" status.
	backgroundSkin;  // With "locked" and "chosen" status.
	achievement;  // With optional tooltip.
}

// Needs to be flexible, and preferably possible to initiate via anonymous JSON objects like {type: 1}
/*class UIUnlockableButtonData {
	public var type:UIUnlockableType;
	public var x:Int;
	public var y:Int;
	public var callback:(btn:FlxButton) -> Void;
	public var image:String;
	public var unlockableName:String;
	//public var active:Bool;
}*/

class PlayState extends FlxSubState
{
	var _walls:FlxGroup;

	var _circleList:FlxTypedGroup<GenericCircle>;  // Originally it's a List<GameObject>
	public static var _spikeList:FlxTypedGroup<Spike>; // New to this Haxe version
	public static var _spikeSpriteList:FlxTypedGroup<FlxSprite>; // For collisions. New to this Haxe version

	public static var textShopMoney:FlxBitmapText;
	
	var fontAngelCode:FlxBitmapFont;
	var fontAngelCode_x4:FlxBitmapFont;

	var cursor:Cursor;  // Debugging
	var cursorPosition:FlxBitmapText;  // Debugging

	override public function create()
	{
		bgColor = 0xffcbdbfc;
		FlxG.camera.antialiasing = false;
		cursor = new Cursor(this);
		cursor.scale.x = 0.125;
		cursor.scale.y = 0.125;
		cursor.offset.set(58, 72);  // Some magic numbers manually selected until it looked currect.
		states.PlayState.self.input_manager.mode = input.InputManager.InputMode.MouseOrTouch;

		super.create();
		fontAngelCode = FlxBitmapFont.fromAngelCode(Global.asset("assets/slkscrb_0.png"), Global.asset("assets/slkscrb.fnt"));
		fontAngelCode_x4 = FlxBitmapFont.fromAngelCode(Global.asset("assets/slkscrb_x4_0.png"), Global.asset("assets/slkscrb_x4.fnt"));

		var circle:BasicCircle = new BasicCircle(120, 160, Global.asset("assets/images/Circle Basic.png"));
		var errorCauser:BasicCircle = new BasicCircle(5, 5, Global.asset("assets/images/Logo Triangles.png"));  // TODO: No. Initialize actual pick up circles.
		var circlePrefabArr: Array<FlxObject> = [circle];  // Must have at least one circle.
		var pickupCirclePrefabArr: Array<FlxObject> = [errorCauser];  // Must have at least one circle.

		

		_walls = new FlxGroup();
		var wallColor = 0xff847e87;

		var _leftWall = new FlxSprite(0, 0);
		_leftWall.makeGraphic(80, 240, wallColor);
		_leftWall.immovable = true;
		_walls.add(_leftWall);

		var _rightWall = new FlxSprite(240, 0);
		_rightWall.makeGraphic(80, 240, wallColor);
		_rightWall.immovable = true;
		_walls.add(_rightWall);

		/*var _bottomWall = new FlxSprite(0, 239);
		_bottomWall.makeGraphic(320, 10, FlxColor.TRANSPARENT);
		_bottomWall.immovable = true;
		_walls.add(_bottomWall);*/
		
		add(_walls);



		initializeUI();

		_circleList = new FlxTypedGroup();
		add(_circleList);

		_spikeList = new FlxTypedGroup();
		add(_spikeList);
		_spikeSpriteList = new FlxTypedGroup();
		add(_spikeSpriteList);

		var spikesController = new SpikesController(this);
		add(spikesController);

		FlxG.sound.playMusic(Global.asset("assets/music/Rob0ne - Press Start.ogg"), 1, true);

		GameManagerBase.Main = new GameManager(circlePrefabArr, pickupCirclePrefabArr, _circleList);
		add(GameManagerBase.Main);
		var global = new GlobalMasterManager();
		add(global);
	}
	override function update(elapsed:Float)
	{
		//cursorPosition.text = cursor.getPosition().toString();
		super.update(elapsed);
	}

	function initializeUI(){
		var creditsText = new FlxBitmapText(fontAngelCode);
		creditsText.font = fontAngelCode;
		creditsText.text = "Dev:\n Blawnode";
		creditsText.setPosition(8, 54);
		add(creditsText);

		var exitText = new FlxBitmapText(fontAngelCode);
		exitText.font = fontAngelCode;
		exitText.text = "C - Exit";
		exitText.setPosition(8, 200);
		add(exitText);
		
		// CURSOR POSITION DEBUGGING
		/*cursorPosition = new FlxBitmapText(fontAngelCode);
		cursorPosition.font = fontAngelCode;
		cursorPosition.text = "-";
		cursorPosition.setPosition(8, 74);
		add(cursorPosition);*/

		/*var creditsText = new FlxText(8, 54, 0, "Dev:\n Blawnode", 8);
		creditsText.font = "assets/slkscrb.ttf";
		creditsText.antialiasing = false;
		creditsText.pixelPerfectRender = true;
		add(creditsText);*/
		// creditsText.setFormat(null, 8);
		// creditsText.scrollFactor.set(0, 0); // Keeps the text fixed in place
		//creditsText.x = Math.floor(creditsText.x / FlxG.camera.scaleX) * FlxG.camera.scaleX;
		//creditsText.y = Math.floor(creditsText.y / FlxG.camera.scaleY) * FlxG.camera.scaleY;

		var logoTriangles:FlxSprite = new FlxSprite(0, 0, Global.asset("assets/images/Logo Triangles.png"));
		add(logoTriangles);

		
		
		var logoShop:FlxSprite = new FlxSprite(240, 16, Global.asset("assets/images/Shop Money Icon.png"));
		add(logoShop);

		final INITIAL_MONEY = 0;
		textShopMoney = new FlxBitmapText(fontAngelCode_x4);
		textShopMoney.font = fontAngelCode_x4;
		textShopMoney.text = StringTools.lpad(Std.string(INITIAL_MONEY), "0", 3);
		textShopMoney.setPosition(278 - (textShopMoney.width / 2), 57 - (textShopMoney.height / 2));
		textShopMoney.alignment = FlxTextAlign.CENTER;
		add(textShopMoney);

		var tbaText = new FlxBitmapText(fontAngelCode);
		tbaText.font = fontAngelCode;
		tbaText.text = "TBA:\n Mo' enemies\n Medals\n\nUnlikely:\n Skins?\n Boss?";
		tbaText.setPosition(242, 160);
		add(tbaText);
		
		/*flixel.util.FlxTimer.wait(2, () ->
		{
			textShopMoney.text = "999";
			textShopMoney.x = 244 - (textShopMoney.width / 2);
			textShopMoney.y = 42 - (textShopMoney.height / 2);
		});*/

		initializeShopButtons();
	}

	function initializeShopButtons(){
		var buttonDatas:Array<Dynamic> = [
			// (Already unlocked)
			{
				type: UIUnlockableType.circle,
				x: 250,
				y: 100,
				callback: btnShopItemCallback,
				image: "assets/images/Shop Circle Madness Grunt.png",
				imageLocked: "assets/images/Shop Locked Unimplemented.png",
				unlockableName: "Grunt Circle",
				price: 999,
				unlocked: true,
				circleType: CircleType.Basic,
			},
			/*{
				type: UIUnlockableType.circle,
				x: 290,
				y: 130,
				callback: btnToBeImplementedCallback,
				image: "assets/images/Shop Locked Unimplemented.png",
				imageLocked: "assets/images/Shop Locked Unimplemented.png",
				unlockableName: "6th Circle",
				price: 50,
				unlocked: true,
			},*/
			{
				type: UIUnlockableType.circle,
				x: 270,
				y: 100,
				callback: btnShopItemCallback,
				image: "assets/images/Shop Circle Nene.png",
				imageLocked: "assets/images/Shop Locked 50.png",
				unlockableName: "Nene Circle",
				price: 50,
				unlocked: false,
				circleType: CircleType.Torpedo,
			},
			{
				type: UIUnlockableType.circle,
				x: 290,
				y: 100,
				callback: btnShopItemCallback,
				image: "assets/images/Shop Circle Nene.png",
				// image: "assets/images/Shop Circle Moony.png",
				imageLocked: "assets/images/Shop Locked 50.png",
				unlockableName: "Moony Circle",
				price: 50,
				unlocked: false,
				circleType: CircleType.Bloon,
			},
			{
				type: UIUnlockableType.circle,
				x: 250,
				y: 130,
				callback: btnShopItemCallback,
				image: "assets/images/Shop Circle Nene.png",
				// image: "assets/images/Shop Circle P-Bot.png",
				imageLocked: "assets/images/Shop Locked 100.png",
				unlockableName: "P-Bot Circle",
				price: 100,
				unlocked: false,
				circleType: CircleType.Big,
			},
			{
				type: UIUnlockableType.circle,
				x: 270,
				y: 130,
				callback: btnShopItemCallback,
				image: "assets/images/Shop Circle Angry Faic.png",
				imageLocked: "assets/images/Shop Locked 100.png",
				unlockableName: "Angry Faic Circle",
				price: 100,
				unlocked: false,
				circleType: CircleType.Mole,
			},
			/*{
				type: UIUnlockableType.circle,
				x: 290,
				y: 130,
				callback: btnShopItemCallback,
				image: "assets/images/Shop Locked Unimplemented.png",
				imageLocked: "assets/images/Shop Locked 100.png",
				// image: "assets/images/Shop Circle Nene.png"
				unlockableName: "6th Circle",
				price: 100,
				unlocked: false,
			},*/
			

			// Spike Skin Buttons
			
			/*{
				type: UIUnlockableType.spikeSkin,
				x: 270,
				y: 100,
				callback: btnToBeImplementedCallback,
				image: "assets/images/Shop Locked Unimplemented.png"
				// image: "assets/images/Shop Circle Nene.png"
			},
			{
				type: UIUnlockableType.spikeSkin,
				x: 270,
				y: 100,
				callback: btnToBeImplementedCallback,
				image: "assets/images/Shop Locked Unimplemented.png"
				// image: "assets/images/Shop Circle Nene.png"
			},
			{
				type: UIUnlockableType.spikeSkin,
				x: 270,
				y: 100,
				callback: btnToBeImplementedCallback,
				image: "assets/images/Shop Locked Unimplemented.png"
				// image: "assets/images/Shop Circle Nene.png"
			},*/
			
			
			// BG Skin Buttons
			
			/*{
				type: UIUnlockableType.backgroundSkin,,
				x: 270,
				y: 100,
				callback: btnToBeImplementedCallback,
				image: "assets/images/Shop Locked Unimplemented.png"
				// image: "assets/images/Shop Circle Nene.png"
			},
			{
				type: UIUnlockableType.backgroundSkin,
				x: 270,
				y: 100,
				callback: btnToBeImplementedCallback,
				image: "assets/images/Shop Locked Unimplemented.png"
				// image: "assets/images/Shop Circle Nene.png"
			},
			{
				type: UIUnlockableType.backgroundSkin,
				x: 270,
				y: 100,
				callback: btnToBeImplementedCallback,
				image: "assets/images/Shop Locked Unimplemented.png"
				// image: "assets/images/Shop Circle Nene.png"
			},*/
		];

		var btnGroup:FlxTypedGroup<FlxButton> = new FlxTypedGroup<FlxButton>();
		
		trace("(TEMP) Initializing buttons...");
		for(buttonData in buttonDatas){
			var btn:FlxButton = new FlxButton(buttonData.x, buttonData.y, "");
			// btn.loadGraphic("assets/images/Shop Circle Angry Faic.png");
			btn.loadGraphic(Global.asset(buttonData.unlocked ? buttonData.image : buttonData.imageLocked));
			trace(btn.origin);
			btn.centerOrigin();
			trace(btn.origin);
			btn.onUp.callback = () -> {buttonData.callback(btn, buttonData);};
			btnGroup.add(btn);
		}
		
		add(btnGroup);
	}

	function btnShopItemCallback(btn:FlxButton, shopButtonData:Dynamic){
		trace("Clicked shop item: " + shopButtonData.unlockableName);
		if(shopButtonData.unlocked)
		{
			trace("But it is already unlocked!");
			trace("TEST: " + btn.toString());
			return;
		}

		// ASSUMPTION: There is only GameManager inheriting form GameManagerBase.
		if(!GameManager.Main.CanPurchase(shopButtonData.price)){
			trace("Insufficient funds.");
			trace("TEST: " + btn.toString());
			return;
		}

		shopButtonData.unlocked = true;
		GameManager.Main.Purchase(shopButtonData.price);
		// btn.active = false;  // More efficient when the button is disabled. Better debugging when the button is enabled + Items can be re-enabled or re-disabled, like skins.
		switch(shopButtonData.type){
			case UIUnlockableType.circle:
				trace("TODO: UNLOCK CIRCLE");
				GameManager.Main.UnlockCircle(shopButtonData.circleType);
			case UIUnlockableType.spikeSkin:
				trace("TODO: UNLOCK SPIKE SKIN");
			case UIUnlockableType.backgroundSkin:
				trace("TODO: UNLOCK BACKGROUND SKIN");
			default:
				trace("UNSUPPORTED PURCHASE TYPE. MISTAKE IN PROGRAMMING EXPECTED.");
		}
		btn.loadGraphic(Global.asset(shopButtonData.image));
	}

	function btnToBeImplementedCallback(btn:FlxButton, shopButtonData:Dynamic){
		trace("A locked button. (To be implemented!) " + btn.toString());
	}
}
