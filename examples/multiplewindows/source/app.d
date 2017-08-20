static import ar = armos;
import std.stdio;

class MainApp : ar.app.BaseApp{
    this(){}

    override void setup(){}

    override void update(){}

    override void draw(){ 
        ar.graphics.fillBackground(0, 1, 1, 1);
    }

    override void keyPressed(ar.utils.KeyType key){
        "MainApp".writeln;
    }

    override void keyReleased(ar.utils.KeyType key){}

    override void mouseMoved(ar.math.Vector2i position, int button){}

    override void mousePressed(ar.math.Vector2i position, int button){}

    override void mouseReleased(ar.math.Vector2i position, int button){}

    override void windowResized(ar.math.Vector2i size){}
}

/++
+/
class SubApp : ar.app.BaseApp{
    this(){}

    override void setup(){}

    override void update(){}

    override void draw(){ 
        ar.graphics.fillBackground(1, 1, 0, 1);
    }

    override void keyPressed(ar.utils.KeyType key){
        "SubApp".writeln;
    }

    override void keyReleased(ar.utils.KeyType key){}

    override void mouseMoved(ar.math.Vector2i position, int button){}

    override void mousePressed(ar.math.Vector2i position, int button){}

    override void mouseReleased(ar.math.Vector2i position, int button){}

    override void windowResized(ar.math.Vector2i size){}
}//class SubApp

void main(){
    version(unittest){
    }else{
        auto config = new ar.app.WindowConfig();
        auto window1 = new ar.app.GLFWWindow(config);
        auto window2 = new ar.app.GLFWWindow(config);
        auto window3 = new ar.app.GLFWWindow(config, window2.context); //share context.

        ar.app.mainLoop.register(new MainApp, window1)
                       .register(new SubApp,  window2)
                       .register(new SubApp,  window3)
                       .loop; // call loop function after application and window registations.
    }
}
