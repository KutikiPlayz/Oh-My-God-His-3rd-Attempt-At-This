package backend;

class Matrix extends openfl.geom.Matrix {
    public function rotateDeg(degrees: Float): Void {
        rotate(degrees * (Math.PI / 180));
    }

    public function skew(x:Float, y:Float): Void {
        var skb = Math.tan(y * (Math.PI / 180)), skc = Math.tan(x * (Math.PI / 180));

        b = a * skb + b;
        c = c + d * skc;

        ty = tx * skb + ty;
        tx = tx + ty * skc;
    }
}