module armos.graphics.mesh;
import armos.types;

/++
	テクスチャ座標を表すstructです．
+/
struct TexCoord{
	float u, v;
}

/++
	頂点座標を表すstructです．
+/
struct Vertex{
	float x, y, z;
}

/++
	法線ベクトルを表すstructです．
+/
struct Normal{
	float x, y, z;
}

/++
ポリゴンで構成された形状を表すclassです．
+/
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

		/// テクスチャ座標の数を表します．
		ulong numTexCoords()const{
			return texCoords.length;
		}

		/// 頂点座標の数を表します．
		ulong numVertices()const{
			return vertices.length;
		}
		
		/// 法線ベクトルの数を表します．
		ulong numNormals()const{
			return normals.length;
		}

		/// 頂点インデックスの数を表します．
		ulong numIndices()const{
			return indices.length;
		}

		/// meshの描画モードを返します．
		armos.graphics.PrimitiveMode primitiveMode()const{
			return primitiveMode_;
		}
		
		/// meshの描画モードを指定します．
		void primitiveMode(armos.graphics.PrimitiveMode mode){
			primitiveMode_ = mode;
		}

		/++
			テクスチャ座標を追加します．
		+/
		void addTexCoord(in armos.math.Vector2f vec){
			addTexCoord(vec[0], vec[1]);
		}

		/++
			テクスチャ座標を追加します．
		+/
		void addTexCoord(in float u, in float v){
			// glTexCoord2d(x, y);
			auto texCoord = TexCoord();
			texCoord.u = u;
			texCoord.v = v;
			texCoords ~= texCoord;
		}

		/++
			テクスチャ座標を追加します．
		+/
		void addTexCoord(in armos.math.Vector2f vec, armos.graphics.Texture texture){
			texture.begin;
			// addTexCoord(vec[0], vec[1]);
			texture.end;
		}

		/++
			テクスチャ座標を追加します．
			Deprecated: 現在動作しません．
		+/
		void addTexCoord(in float x, in float y, armos.graphics.Texture texture){
			texture.begin;
			// glTexCoord2d(x, y);
			texture.end;
		}

		/++
			頂点座標を追加します．
		+/
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

		/++
			頂点座標を追加します．
		+/
		void addVertex(in float x, in float y, in float z){
			addVertex(armos.math.Vector3f(x, y, z));
		}
		
		/++
			法線ベクトルを追加します．
		+/
		void addNormal(const armos.math.Vector3f vec){
			auto normal = Normal();
			normal.x = vec[0];
			normal.y = vec[1];
			normal.z = vec[2];
			normals ~= normal;
		}
		
		/++
			法線ベクトルを追加します．
		+/
		void addNormal(in float x, in float y, in float z){
			addNormal(armos.math.Vector3f(x, y, z));
		}

		/++
			頂点インデックスを追加します．
		+/
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

		/++
			meshを描画します．
			Params:
			renderMode = 面，線，点のどれを描画するか指定します．
		+/
		void draw(armos.graphics.PolyRenderMode renderMode){
			armos.graphics.currentRenderer.draw(this, renderMode, false, false, false);
		};

		/++
			meshをワイヤフレームで描画します．
		+/
		void drawWireFrame(){
			draw(armos.graphics.PolyRenderMode.WireFrame);
		};

		/++
			meshの頂点を点で描画します．
		+/
		void drawVertices(){
			draw(armos.graphics.PolyRenderMode.Points);
		};

		/++
			meshの面を塗りつぶして描画します．
		+/
		void drawFill(){
			draw(armos.graphics.PolyRenderMode.Fill);
		};
	}//public

	private{
		armos.graphics.PrimitiveMode primitiveMode_;
	}//private
}//class Mesh
