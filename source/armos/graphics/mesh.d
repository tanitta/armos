module armos.graphics.mesh;
import armos.types;

struct TexCoord{
	float u, v;
}

struct Vertex{
	float x, y, z;
}

struct Normal{
	float x, y, z;
}

/++
++/
class Mesh {
	public{
		alias int IndexType;

		bool isVertsChanged = false;
		bool isFaceDirty= false;
		bool isIndicesChanged = false;

		Vertex[] vertices;
		Normal[] normals;
		armos.types.FloatColor[] colors;
		TexCoord[] texCoords;
		IndexType[] indices;
		armos.graphics.Material material;

		///
		ulong numTexCoords()const{
			return texCoords.length;
		}

		///
		ulong numVertices()const{
			return vertices.length;
		}
		
		///
		ulong numNormals()const{
			return normals.length;
		}

		///
		ulong numIndices()const{
			return indices.length;
		}

		///
		armos.graphics.PrimitiveMode primitiveMode()const{
			return primitiveMode_;
		}
		
		///
		void primitiveMode(armos.graphics.PrimitiveMode mode){
			primitiveMode_ = mode;
		}

		///
		void addTexCoord(in armos.math.Vector2f vec){
			addTexCoord(vec[0], vec[1]);
		}

		///
		void addTexCoord(in float u, in float v){
			// glTexCoord2d(x, y);
			auto texCoord = TexCoord();
			texCoord.u = u;
			texCoord.v = v;
			texCoords ~= texCoord;
		}

		///
		void addTexCoord(in armos.math.Vector2f vec, armos.graphics.Texture texture){
			texture.begin;
			// addTexCoord(vec[0], vec[1]);
			texture.end;
		}

		///
		void addTexCoord(in float x, in float y, armos.graphics.Texture texture){
			texture.begin;
			// glTexCoord2d(x, y);
			texture.end;
		}

		///
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

		///
		void addVertex(in float x, in float y, in float z){
			addVertex(armos.math.Vector3f(x, y, z));
		}
		
		///
		void addNormal(const armos.math.Vector3f vec){
			auto normal = Normal();
			normal.x = vec[0];
			normal.y = vec[1];
			normal.z = vec[2];
			normals ~= normal;
		}
		
		void addNormal(in float x, in float y, in float z){
			addNormal(armos.math.Vector3f(x, y, z));
		}

		///
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

		///
		void draw(armos.graphics.PolyRenderMode renderMode){
			armos.graphics.currentRenderer.draw(this, renderMode, false, false, false);
		};

		///
		void drawWireFrame(){
			draw(armos.graphics.PolyRenderMode.WireFrame);
		};

		///
		void drawVertices(){
			draw(armos.graphics.PolyRenderMode.Points);
		};

		///
		void drawFill(){
			draw(armos.graphics.PolyRenderMode.Fill);
		};
	}//public

	private{
		armos.graphics.PrimitiveMode primitiveMode_;
	}//private
}//class Mesh
