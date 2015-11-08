module armos.graphics.mesh;
import armos.graphics;
import armos.math;

class Mesh{
	alias int IndexType;
	bool isVertsChanged = false;
	bool isFaceDirty= false;
	bool isIndicesChanged = false;
	
	armos.math.Vector3f[] vertices;
	IndexType[] indices;

	void addVertex(const armos.math.Vector3f vec){
		vertices ~= [cast(armos.math.Vector3f)vec];
		isVertsChanged = true;
		isFaceDirty = true;
	};
	unittest{
		auto mesh = new Mesh;
		mesh.addVertex(new armos.math.Vector3f(0, 1, 2));
		mesh.addVertex(new armos.math.Vector3f(3, 4, 5));
		mesh.addVertex(new armos.math.Vector3f(6, 7, 8));
		assert(mesh.vertices[1][1] == 4.0);
		assert(mesh.isFaceDirty);
		assert(mesh.isVertsChanged);
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
		armos.graphics.getCurrentRenderer.draw(this, renderMode);
	};
	
	void drawWireFrame(){
		draw(armos.graphics.PolyRenderMode.WireFrame);
	};
	
	void drawVertices(){
		draw(armos.graphics.PolyRenderMode.Points);
	};
}
