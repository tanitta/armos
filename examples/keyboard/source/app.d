static import ar = armos;

class TestApp : ar.app.BaseApp{
    this(){}

    override void setup(){}

    override void update(){}

    override void draw(){
        import std.stdio;
        writeln("hasPressedKey(ar.utils.KeyType.A) : ",  hasPressedKey(ar.utils.KeyType.A));
        writeln("hasHeldKey(ar.utils.KeyType.A) : ",     hasHeldKey(ar.utils.KeyType.A));
        writeln("hasReleasedKey(ar.utils.KeyType.A) : ", hasReleasedKey(ar.utils.KeyType.A));
    }

    override void keyPressed(ar.utils.KeyType key){}

    override void keyReleased(ar.utils.KeyType key){}

    override void mouseMoved(ar.math.Vector2i position, int button){}

    override void mousePressed(ar.math.Vector2i position, int button){}

    override void mouseReleased(ar.math.Vector2i position, int button){}
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
