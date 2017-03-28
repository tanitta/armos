static import ar = armos;

class TestApp : ar.app.BaseApp{
    override void setup(){
        _x = 0f;
    }

    override void update(){
        _x += 2f;
        if(_x > ar.app.currentWindow.size.x){
            _x = 0f;
        }
    }

    override void draw(){
        ar.graphics.circlePrimitive(
            ar.math.Vector3f(_x, 200, 0), // position
            20                            // radius
        ).drawFill;
    }

    private{
        float _x;
    }
}

void main(){
    version(unittest){
    }else{
        // Almost all methods in armos's classes and structs are chainable.
        ar.app.WindowConfig windowConfig = (new ar.app.WindowConfig).width(640)
                                                                    .height(480);
        ar.app.run(new TestApp, windowConfig);
    }
}
