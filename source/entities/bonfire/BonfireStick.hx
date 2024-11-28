package entities.bonfire;

import flixel.addons.plugin.taskManager.FlxTask;
import flixel.graphics.FlxAsepriteUtil;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxEase;

class BonfireStick extends FlxSprite
{
	var bonfire:BonfireArea;
	var start_tween:FlxTween;

	var _ang:Float = 0.0;

	var enabled = false;

	public var marshmallow:Marshmallow;

	public function new(x, y, area)
	{
		super(x, y);

		bonfire = area;
		FlxAsepriteUtil.loadAseAtlasAndTagsByIndex(this, AssetPaths.grill_stick__png, AssetPaths.grill_stick__json);
		animation.play("idle");

		PlayState.self.objects.add(this);

		visible = false;

		origin.x = 16;
		origin.y = 109;

		hide();
	}

	function discardMarshmallow()
	{
		if (marshmallow != null)
		{
			marshmallow.discard();
		}
		marshmallow = null;
	}

	function newMarshmallow()
	{
		discardMarshmallow();

		marshmallow = new Marshmallow(x, y);
		PlayState.self.objects.add(marshmallow);
	}

	public function activate()
	{
		enabled = true;
		visible = true;

		if (start_tween != null)
			start_tween.cancel();

		_ang = 30.0;
		alpha = 0.0;

		start_tween = FlxTween.tween(this, {_ang: 0.0}, 0.45, {ease: FlxEase.elasticOut});
		start_tween.onComplete = onEquipped;

		var player = PlayState.self.player;
		x = player.x;
		y = player.y;
	}

	function onEquipped(tween:FlxTween)
	{
		newMarshmallow();
	}

	public function hide()
	{
		enabled = false;
		discardMarshmallow();
	}
	
	var shake_force = 0.0;
	public function shake_off() {
		discardMarshmallow();
		shake_force = 10.0;
	}

	var time:Float = 0.;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		time += elapsed;

		if (enabled)
		{
			alpha += (1.0 - alpha) * 0.2;
		}
		else
		{
			alpha *= 0.5;
		}
		

		var player = PlayState.self.player;
		var offset_x = 128;

		if (!player.flipX)
		{
			offset_x = -64;
		}

		origin.x = flipX ? 128 - 16 : 16;

		flipX = !player.flipX;

		var swayX = Math.sin(time * 1) * 12;
		var swayY = Math.sin(time * 2.5 + 3) * 8;

		var tx = player.x + offset_x + swayX;
		var ty = player.y + swayY;

		x += (tx - x) * 0.3;
		y += (ty - y) * 0.3;

		angle = flipX ? -_ang : _ang;
		
		if (shake_force > 0) {
			shake_force *= 0.86;
			angle += Math.sin(time * (0.8 + shake_force)) * 2 * shake_force;
			if (shake_force < 0.01) {
				newMarshmallow();
				shake_force = 0;
			}
		}

		if (marshmallow != null)
		{
			marshmallow.x = x;
			marshmallow.y = y;
			marshmallow.flipX = flipX;

			var putOnDx = 15.0;
			var putOnDy = 15.0;

			if (!flipX)
			{
				putOnDx = -putOnDx;
				marshmallow.x += 64;
			}
			
			marshmallow.x += (marshmallow.alpha - 1.0) * putOnDx;
			marshmallow.y += (marshmallow.alpha - 1.0) * putOnDy;
			
			var d = FlxMath.distanceBetween(bonfire, marshmallow);

			marshmallow.heat(d, elapsed);
		}
	}
}
