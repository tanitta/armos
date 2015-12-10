module armos.graphics.mesh;
import armos.graphics;
import armos.math;

struct TexCoord{
	float u, v;
	// int id;
}

struct Vertex{
	float x, y, z;
}

class Mesh{
	alias int IndexType;
	
	private armos.graphics.PrimitiveMode primitiveMode_;
	bool isVertsChanged = false;
	bool isFaceDirty= false;
	bool isIndicesChanged = false;
	
	// armos.math.Vector3f[] vertices;
	Vertex[] vertices;
	TexCoord[] texCoords;
	IndexType[] indices;

	ulong numTexCoords()const{
		return texCoords.length;
	}
	
	ulong numVertices()const{
		return vertices.length;
	}
	
	ulong numIndices()const{
		return indices.length;
	}
	
	armos.graphics.PrimitiveMode primitiveMode()const{
		return primitiveMode_;
	}
	void primitiveMode(armos.graphics.PrimitiveMode mode){
		primitiveMode_ = mode;
	}
	

	
	void addTexCoord(in armos.math.Vector2f vec){
		addTexCoord(vec[0], vec[1]);
	}
	
	void addTexCoord(in float u, in float v){
		// glTexCoord2d(x, y);
		auto texCoord = TexCoord();
		texCoord.u = u;
		texCoord.v = v;
		texCoords ~= texCoord;
	}
	
	void addTexCoord(in armos.math.Vector2f vec, armos.graphics.Texture texture){
		texture.begin;
		// addTexCoord(vec[0], vec[1]);
		texture.end;
	}
	
	void addTexCoord(in float x, in float y, armos.graphics.Texture texture){
		texture.begin;
		// glTexCoord2d(x, y);
		texture.end;
	}
	
	void addVertex(const armos.math.Vector3f vec){
		// vertices ~= [cast(armos.math.Vector3f)vec];
		auto vertex = Vertex();
		vertex.x = vec[0];
		vertex.y = vec[1];
		vertex.z = vec[2];
		vertices ~= vertex;
		isVertsChanged = true;
		isFaceDirty = true;
	};
	unittest{
		auto mesh = new Mesh;
		mesh.addVertex(armos.math.Vector3f(0, 1, 2));
		mesh.addVertex(armos.math.Vector3f(3, 4, 5));
		mesh.addVertex(armos.math.Vector3f(6, 7, 8));
		assert(mesh.vertices[1].y == 4.0);
		assert(mesh.isFaceDirty);
		assert(mesh.isVertsChanged);
	}
	
	void addVertex(in float x, in float y, in float z){
		addVertex(armos.math.Vector3f(x, y, z));
	}
	
	void addIndex(IndexType index){
		indices ~= index;
		isIndicesChanged = true;
		isFaceDirty = true;
	};
	unittest{
		auto mesh = new Mesh;
		mesh.addIndex(1);
		mesh.addIndex(2);
		mesh.addIndex(3);
		assert(mesh.indices[1] == 2);
		assert(mesh.isIndicesChanged);
		assert(mesh.isFaceDirty);
	}
	
	void draw(armos.graphics.PolyRenderMode renderMode){
		armos.graphics.currentRenderer.draw(this, renderMode, false, false, false);
	};
	
	void drawWireFrame(){
		draw(armos.graphics.PolyRenderMode.WireFrame);
	};
	
	void drawVertices(){
		draw(armos.graphics.PolyRenderMode.Points);
	};
	
	void drawFill(){
		draw(armos.graphics.PolyRenderMode.Fill);
	};
}

import derelict.assimp3.assimp;
import std.stdio;
armos.graphics.Mesh loadedMesh(in string fileName){
	DerelictASSIMP3.load();
	
	char[] str;
	auto f = File(fileName, "r");
	while (f.readln(str))
        write(str);
	aiPropertyStore store;
	uint flags = 0;
	aiScene* ais = cast(aiScene*)aiImportFileExWithProperties(str.ptr , flags, null, &store);
	
	// auto mesh = meshFromAiMesh(aim);
	auto mesh = new armos.graphics.Mesh;
	//...
	return mesh;
};

private armos.graphics.Mesh meshFromAiMesh(in aiMesh aim){
	auto mesh = new armos.graphics.Mesh;
	//...
	return mesh;
}
