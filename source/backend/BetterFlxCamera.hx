package backend;

import flixel.util.FlxAxes;

class BetterFlxCamera extends flixel.FlxCamera {
    private var _matrix:Matrix = new Matrix();
	private var _fxShakeI:Float = -999999;
	private var _fxShakeHardness:Float = 0.5;
	private var _fxShakeFadeTime:Float = 0.15;

    private var viewOffset:FlxPoint = new FlxPoint();
    private var skew:FlxPoint = new FlxPoint();
    private var shakeAngle:Float = 0;

    override function update(elapsed:Float) {
        if (!Std.isOfType(this, PsychCamera)) super.update(elapsed);

        var scaleMode = FlxG.scaleMode.scale;
		var aW = width * 0.5, aH = height * 0.5;

		_matrix.identity();
		_matrix.translate(-aW, -aH); // AnchorPoint In
		_matrix.scale(scaleX, scaleY); // Scaling
		_matrix.rotateDeg(angle + shakeAngle); // Angle
		_matrix.skew(skew.x, skew.y);
		_matrix.translate(aW, aH); // AnchorPoint Out
		_matrix.translate(viewOffset.x, viewOffset.y); // Offset
		_matrix.scale(scaleMode.x, scaleMode.y); // ScaleMode
		
        @:privateAccess {
            canvas.__transform.a = _matrix.a;
            canvas.__transform.b = _matrix.b;
            canvas.__transform.c = _matrix.c;
            canvas.__transform.d = _matrix.d;
            canvas.__transform.tx = _matrix.tx;
            canvas.__transform.ty = _matrix.ty;
        }
    }

    override function updateShake(elapsed:Float) {
        var fadeTime = -FlxMath.bound(_fxShakeDuration * 0.5, _fxShakeFadeTime / 2, _fxShakeFadeTime);

        _fxShakeDuration = _fxShakeDuration > fadeTime ? _fxShakeDuration - elapsed : fadeTime;

        viewOffset.set();
        skew.set();
        shakeAngle = 0;

        if (_fxShakeDuration > fadeTime) {
            var sX = _fxShakeIntensity * width;
            var sY = _fxShakeIntensity * height;

            var rX:Float = 0, rY:Float = 0, rAngle:Float = 0, rSkewX:Float = 0, rSkewY:Float = 0;
            var w = _fxShakeDuration / -fadeTime + 1;
            var ww = FlxMath.bound(w, 0, 1) * (_fxShakeHardness + 1);
            var www = FlxMath.bound(w, 0, 1) * _fxShakeHardness;

            _fxShakeI += (FlxMath.bound((_fxShakeIntensity * 7) + 0.75, 0, 10) * elapsed * FlxMath.bound(w, 0, 1.5));
            rX = Math.cos(_fxShakeI * 97) * sX * ww;
            rY = Math.sin(_fxShakeI * 86) * sY * ww;
            rAngle = Math.sin(_fxShakeI * 62) * FlxMath.bound(_fxShakeIntensity * 66, -60, 60) * ww;
            rSkewX = Math.cos(_fxShakeI * 54) * FlxMath.bound(_fxShakeIntensity * 12, -4, 4) * ww;
            rSkewY = Math.sin(_fxShakeI * 51) * FlxMath.bound(_fxShakeIntensity * 12, -1.5, 1.5) * ww;

            if (_fxShakeHardness > 0) {
                rX += Math.cos(_fxShakeI * 165) * sX * www;
                rY += Math.sin(_fxShakeI * 132) * sY * www;
                rAngle += Math.sin(_fxShakeI * 111) * FlxMath.bound(_fxShakeIntensity * 66, -60, 60) * www;
                rSkewX += Math.cos(_fxShakeI * 123) * FlxMath.bound(_fxShakeIntensity * 12, -4, 4) * www;
                rSkewY += Math.sin(_fxShakeI * 101) * FlxMath.bound(_fxShakeIntensity * 12, -1.5, 1.5) * www;
            }

            viewOffset.add(rX * zoom, rY * zoom);
            shakeAngle += rAngle;
            skew.add(rSkewX, rSkewY);
        }
    }

    public function betterShake(Intensity:Float = 0.05, Duration:Float = 0.5, Hardness:Float = 0.5, FadeTime:Float = 0.15, ?OnComplete:() -> Void) {
		if ((Intensity < _fxShakeIntensity && Duration < _fxShakeDuration))
			return;

		_fxShakeIntensity = Intensity;
		_fxShakeDuration = Duration;
        _fxShakeHardness = Hardness;
        _fxShakeFadeTime = FadeTime;
		_fxShakeComplete = OnComplete;
    }

    override function set_angle(Angle:Float):Float {
        angle = Angle;
        return Angle;
    }
}