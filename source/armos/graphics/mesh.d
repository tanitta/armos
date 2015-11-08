module armos.graphics.mesh;
import armos.graphics;
import armos.math;

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
	IndexType[] indices;

	
	const ulong numVertices(){
		return vertices.length;
	}
	
	const ulong numIndices(){
		return indices.length;
	}
	
	@property{
		const armos.graphics.PrimitiveMode primitiveMode(){
			return primitiveMode_;
		}
		void primitiveMode(armos.graphics.PrimitiveMode mode){
			primitiveMode_ = mode;
		}
	}
	

	
	void addVertex(const armos.math.Vector3f vec){
		// vertices ~= [cast(armos.math.Vector3f)vec];
		auto vertex = new Vertex;
		vertex.x = vec[0];
		vertex.y = vec[1];
		vertex.z = vec[2];
		vertices ~= *vertex;
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
		armos.graphics.currentRenderer.draw(this, renderMode, false, false, false);
	};
	
	void drawWireFrame(){
		draw(armos.graphics.PolyRenderMode.WireFrame);
	};
	
	void drawVertices(){
		draw(armos.graphics.PolyRenderMode.Points);
	};
}
