package org.devboy.redcircle
{

    import flash.display.Sprite;

    public class RedCircle extends Sprite
    {
        public function RedCircle( radius: Number )
        {
            graphics.beginFill(0xFF0000)
            graphics.drawCircle(radius,radius,radius)
            graphics.endFill()
        }
    }
}
