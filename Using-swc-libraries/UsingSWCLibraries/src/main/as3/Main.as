package
{

    import com.greensock.TweenMax;

    import flash.display.Shape;
    import flash.display.Sprite;

    public class Main extends Sprite
    {
        public function Main()
        {
            var shape:Shape = new Shape()
            shape.graphics.beginFill(0)
            shape.graphics.drawRect(0, 0, 100, 100)
            shape.graphics.endFill()

            addChild(shape)

            var tween:TweenMax = TweenMax.to(shape, 10, {rotation:100})
        }
    }
}
