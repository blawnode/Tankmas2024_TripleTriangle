package ui;

import squid.sprite.TempSprite;

class TouchOverlay extends FlxTypedGroupExt<FlxSpriteExt>
{
	public function new(?X:Float, ?Y:Float)
	{
		super();
		sstate(IDLE);
	}

	override function update(elapsed:Float)
	{
		fsm();
		super.update(elapsed);
	}

	function fsm()
		switch (cast(state, State))
		{
			default:
			case IDLE:
				if (!Ctrl.mode.can_move)
					return;
				if (FlxG.mouse.pressed)
					sstate(PRESSING, fsm);
			case PRESSING:
				if (FlxG.mouse.justReleased)
				{
					move_to_position();
					sstate(IDLE, fsm);
				}
		}

	function move_to_position()
	{
		PlayState.self.player.start_auto_move(FlxG.mouse.getWorldPosition());
		var fx:TempSprite = new TempSprite("move-circle", this);
		fx.center_on(FlxG.mouse.getWorldPosition());
		add(fx);
	}

	override function kill()
	{
		super.kill();
	}
}

private enum abstract State(String) from String to String
{
	var IDLE;
	var PRESSING;
}
