package backend;

class BetterFlxCamera extends flixel.FlxCamera {
    public var betterShake:Bool = true;
	public var betterShakeHardness:Float = 0.5;
	public var betterShakeFadeTime:Float = 0.15;


    private var anchorPoint:FlxPoint = new FlxPoint(0.5, 0.5);
    private var offset:FlxPoint = new FlxPoint();

    private var skew:FlxPoint = new FlxPoint();
    private var clipSkew:FlxPoint = new FlxPoint();

    private var transform:Matrix = new Matrix();
    private var _matrix:Matrix = new Matrix();

    private var viewOffset:FlxPoint = new FlxPoint();

	private var _fxShakeI:Float = -999999;
    private var shakeAngle:Float = 0;

    override function update(elapsed:Float) {
        if (!Std.is(this, PsychCamera)) super.update(elapsed);

        var scaleMode = FlxG.scaleMode.scale;
		
		var aW = width * anchorPoint.x, aH = height * anchorPoint.y;

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
        var cool = betterShake ? -betterShakeFadeTime : 0;

        _fxShakeDuration = _fxShakeDuration > cool ? _fxShakeDuration - elapsed : cool;

        viewOffset.set();
        skew.set();
        shakeAngle = 0;

        if (_fxShakeDuration > cool) {
            var sX = _fxShakeIntensity * width;
            var sY = _fxShakeIntensity * height;

            var rX:Float = 0, rY:Float = 0, rAngle:Float = 0, rSkewX:Float = 0, rSkewY:Float = 0;
            if (betterShake) {
                var w = _fxShakeDuration / -cool + 1;
                var ww = FlxMath.bound(w, 0, 1) * (betterShakeHardness + 1);
                var www = FlxMath.bound(w, 0, 1) * betterShakeHardness;

                _fxShakeI += (FlxMath.bound((_fxShakeIntensity * 7) + 0.75, 0, 10) * elapsed * FlxMath.bound(w, 0, 1.5));
                rX = Math.cos(_fxShakeI * 97) * sX * ww;
                rY = Math.sin(_fxShakeI * 86) * sY * ww;
                rAngle = Math.sin(_fxShakeI * 62) * FlxMath.bound(_fxShakeIntensity * 66, -60, 60) * ww;
                rSkewX = Math.cos(_fxShakeI * 54) * FlxMath.bound(_fxShakeIntensity * 12, -4, 4) * ww;
                rSkewY = Math.sin(_fxShakeI * 51) * FlxMath.bound(_fxShakeIntensity * 12, -1.5, 1.5) * ww;

                if (betterShakeHardness > 0) {
                    rX += Math.cos(_fxShakeI * 165) * sX * www;
                    rY += Math.sin(_fxShakeI * 132) * sY * www;
                    rAngle += Math.sin(_fxShakeI * 111) * FlxMath.bound(_fxShakeIntensity * 66, -60, 60) * www;
                    rSkewX += Math.cos(_fxShakeI * 123) * FlxMath.bound(_fxShakeIntensity * 12, -4, 4) * www;
                    rSkewY += Math.sin(_fxShakeI * 101) * FlxMath.bound(_fxShakeIntensity * 12, -1.5, 1.5) * www;
                }
            } else {
                rX = FlxG.random.float(-sX, sX);
                rY = FlxG.random.float(-sY, sY);
            }

            viewOffset.add(rX * zoom, rY * zoom);
            shakeAngle += rAngle;
            skew.add(rSkewX, rSkewY);
        }
    }

    override function set_angle(Angle:Float):Float {
        angle = Angle;
        return Angle;
    }
}