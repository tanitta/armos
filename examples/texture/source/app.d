import std.stdio, std.math;
import derelict.opengl3.gl;
	
static import ar = armos;
class TestApp : ar.app.BaseApp{
	ar.graphics.Texture texture;
	ar.graphics.Mesh rect;
	override void setup(){
		texture = new ar.graphics.Texture;
		uint i , j;
		uint textureSize = 512;
		ubyte[] bits = new ubyte[](textureSize*textureSize*4);
		for (i = 0 ; i < textureSize ; i++) {
			for (j = 0 ; j < textureSize ; j++) {
				bits[i*512*4 + j*4 + 0] = cast(ubyte)i;
				bits[i*512*4 + j*4 + 2] = cast(ubyte)j;
				bits[i*512*4 + j*4 + 3] = cast(ubyte)( j*i );
			}
		}
		
		texture.allocate(bits, textureSize, textureSize, ar.graphics.ColorFormat.RGBA);
		rect = new ar.graphics.Mesh;
		rect.primitiveMode = ar.graphics.PrimitiveMode.TriangleStrip;
		float x = 512;
		float y = 512;
		rect.addTexCoord(0, 0);rect.addVertex(0, 0, 0);
		rect.addTexCoord(0, 1);rect.addVertex(0, y, 0);
		rect.addTexCoord(1, 1);rect.addVertex(x, y, 0);
		rect.addTexCoord(1, 0);rect.addVertex(x, 0, 0);
		
		rect.addIndex(0);
		rect.addIndex(1);
		rect.addIndex(2);
		rect.addIndex(2);
		rect.addIndex(3);
		rect.addIndex(0);
        ar.graphics.currentMaterial.texture("tex0", texture);
	}
	
	override void draw(){
		rect.drawFill;
	}
}

void main(){
    version(unittest){
    }else{
        ar.app.run(new TestApp);
    }
}
