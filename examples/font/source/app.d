static import ar = armos;

class TestApp : ar.app.BaseApp{
	override void setup(){
        ar.graphics.blendMode = ar.graphics.BlendMode.Alpha;

        string fontPath;
        version(OSX){
            fontPath = "/Library/Fonts/Futura.ttc";
        }
        version(Windows){
            fontPath = "C:\\Windows\\Fonts\\Arial\\arial.ttf";

        }
        version(linux){
            //TODO
        }

        _font = (new ar.graphics.Font).load("/Library/Fonts/Futura.ttc", 32, true);
    }

	override void draw(){
        _font.drawString("Grumpy wizards make toxic brew \nfor the evil Queen and Jack.", 0, 0);
    }

    private{
        ar.graphics.Font _font;
    }
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
