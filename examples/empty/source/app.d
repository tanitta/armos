static import ar = armos;

class TestApp : ar.app.BaseApp{
	this(){}
	
	override void setup(){}
	
	override void update(){}
	
	override void draw(){}
	
	override void keyPressed(ar.utils.KeyType key){}
	
    override void keyReleased(ar.utils.KeyType key){}
	
	override void mouseMoved(ar.math.Vector2i position, int button){}
	
	override void mousePressed(ar.math.Vector2i position, int button){}
	
	override void mouseReleased(ar.math.Vector2i position, int button){}
}

void main(){ar.app.run(new TestApp);}
