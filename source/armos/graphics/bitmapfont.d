module armos.graphics.bitmapfont;
import armos.math;
import armos.graphics.image;
import armos.graphics;

/++
BitmapFontを描画するclassです．
+/
class BitmapFont {
    public{
        /++
        +/
        this(){
            _image = new armos.graphics.Image;
        }

        /++
            fontのBitmap画像を読み込みます．
            Params:
            filename = fontの画像のPathを指定します．
            fontWidth = フォントの横幅を指定します．
            fontHeight= フォントの縦幅を指定します．
        +/
        BitmapFont load(in string fileName, in int fontWidth, in int fontHeight){
            _image.load(fileName)
                  .minMagFilter(TextureMinFilter.Nearest, TextureMagFilter.Nearest);
            width = fontWidth;
            height = fontHeight;
            return this;
        };

        /++
            読み込まれたFontにより文字を描画します．
            Params:
            str = 描画する文字列を指定します．
            x = 文字列を描画するX座標を指定します．
            y = 文字列を描画するY座標を指定します．
            z = 文字列を描画するZ座標を指定します．
        +/
        BitmapFont draw(in string str, in int x, in int y, in int z = 0){
            if(str == ""){return this;}

            int currentPosition = 0;

            import std.string;
            import std.algorithm;
            import std.conv;
            import std.array;
            string[] lines = str.split("\n");

            armos.graphics.pushMatrix;
            armos.graphics.translate(x, y, z);
            foreach (line; lines) {
                armos.graphics.pushMatrix;
                armos.graphics.translate(0, currentPosition*height, 0);
                drawLine(line);
                armos.graphics.popMatrix;
                currentPosition += 1;
            }
            armos.graphics.popMatrix;
            return this;
        }

        /++
            fontの横幅のプロパティです．
        +/
        int width()const{
            return _size[0];
        }

        /++
            fontの横幅のプロパティです．
        +/
        BitmapFont width(in int w){
            _size[0] = w;
            return this;
        }

        /++
            fontの縦幅のプロパティです．
        +/
        int height()const{
            return _size[1];
        }

        /++
            fontの縦幅のプロパティです．
        +/
        BitmapFont height(in int h){
            _size[1] = h;
            return this;
        }

        /++
            tab幅のプロパティです．
        +/
        int tabWidth= 4;

        /++
            文字の位置を左寄せに設定します．
            Deprecated: 現在動作しません．
        +/
        BitmapFont alignLeft(){_align = armos.graphics.TextAlign.Left;return this;}
        /++
            文字の位置を中央寄せに設定します．
            Deprecated: 現在動作しません．
        +/
        BitmapFont alignCenter(){_align = armos.graphics.TextAlign.Center;return this;}
        /++
            文字の位置を右寄せに設定します．
            Deprecated: 現在動作しません．
        +/
        BitmapFont alignRight(){_align = armos.graphics.TextAlign.Right;return this;}

        ///
        Material material(){
            return _image.material;
        }
    }//public

    private{
        armos.graphics.Image _image;
        armos.math.Vector2i _size;
        armos.graphics.TextAlign _align = armos.graphics.TextAlign.Left;

        void drawLine(in string str){
            import std.string;
            import std.algorithm;
            import std.conv;
            import std.array;
            char[] characters = str.split("").map!(to!char).array;
            int currentPosition = 0;
            foreach (character; characters) {
                switch (character) {
                    case '\t':
                        currentPosition += tabWidth;
                        break;
                    default:
                        drawCharacter(character, currentPosition, 0);
                        currentPosition += 1;
                        break;
                }
            }
        }

        void drawCharacter(in char character, in int x, in int y){
            immutable int textureX = character%16*width;
            immutable int textureY = character/16*height;
            _image.drawCropped(x*width, y*height, textureX, textureY, textureX+width, textureY+height);

        }
    }//private
}//class BitmapFont

enum TextAlign{
    Left,
    Right,
    Center
};
