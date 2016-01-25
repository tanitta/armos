import armos, std.stdio, std.math;
import derelict.opengl3.gl;
class TestApp : ar.BaseApp{
	ar.Texture texture;
	ar.Mesh rect;
	
	void setup(){
		texture = new ar.Texture;
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
		texture.allocate(bits, textureSize, textureSize, ar.ColorFormat.RGBA);
		
		rect = new ar.Mesh;
		rect.primitiveMode = ar.PrimitiveMode.Quads;
		float x = 512;
		float y = 512;
		rect.addTexCoord(0, 0);rect.addVertex(0, 0, 0);
		rect.addTexCoord(0, 1);rect.addVertex(0, y, 0);
		rect.addTexCoord(1, 1);rect.addVertex(x, y, 0);
		rect.addTexCoord(1, 0);rect.addVertex(x, 0, 0);
		
		rect.addIndex(0);
		rect.addIndex(1);
		rect.addIndex(2);
		rect.addIndex(3);
	}
	
	void draw(){
		texture.begin;
		rect.drawFill;
		texture.end;
	}
}

void main(){ar.run(new TestApp);}
