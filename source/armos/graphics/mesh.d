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

		///
		void load(string pathInDataDir){
			vertices = [];
			texCoords = [];
			indices = [];
			(new AssimpModelLoader).load(pathInDataDir);
		}
	}//public

	private{
		armos.graphics.PrimitiveMode primitiveMode_;
	}//private
}//class Mesh


import derelict.assimp3.assimp;
import std.stdio;
import std.algorithm : map;
import std.array : array, Appender;

/++
++/
class AssimpModelLoader {
	public{
		~this(){
			clear;
		}

		///
		void load(string pathInDataDir){
			import std.string;
			string fileName = armos.utils.absolutePath(pathInDataDir);

			import derelict.assimp3.assimp;
			import std.stdio;
			DerelictASSIMP3.load();

			loadScene(fileName);

			
			import std.stdio;
			
			auto materials
				= _scene.mMaterials[0 .. _scene.mNumMaterials]
				.map!(m => createMaterial(m))
				.array;
				
			auto meshes
				= _scene.mMeshes[0 .. _scene.mNumMeshes]
				.map!(m => createMesh(m, materials))
				.array;

		}
		
		///
		void clear(){
			if(_isLoaded){
				aiReleaseImport(_scene);
				_isLoaded = false;
			}
		}


	}//public

	private{
		
		///
		void loadScene(string fileName){
			auto f = File(fileName, "r");

			char[] str;
			while (f.readln(str)){
				write(str);
			}

			aiPropertyStore* store = aiCreatePropertyStore();
			uint flags = aiProcess_CalcTangentSpace
				| aiProcess_Triangulate
				| aiProcess_JoinIdenticalVertices
				| aiProcess_SortByPType;

			import std.string;
			_scene = cast(aiScene*)aiImportFile(fileName.toStringz, flags);
			// _scene = cast(aiScene*)aiImportFileExWithProperties(str.ptr , flags, null, store);

			if(_scene){
				_isLoaded = true;
			}
		}

		///
		static string fromAiString(const(aiString) s) @safe pure {
			return s.data[0 .. s.length].idup;
		}

		///
		static armos.types.Color fromAiColor(ref const(aiColor4D) c){
			return armos.types.Color(c.r*255.0, c.g*255.0, c.b*255.0, c.a*255.0);
		}
		
		///
		static armos.math.Vector3f fromAiVector(ref const aiVector3D v){
			return armos.math.Vector3f(v.x, v.y, v.z);
		}

		///
		armos.graphics.Material createMaterial(const(aiMaterial)* material) const {
			aiString aiName;
			aiGetMaterialString(material, AI_MATKEY_NAME, 0, 0, &aiName);
			auto name = fromAiString(aiName);
		
			aiColor4D color;
		
			aiGetMaterialColor(material, AI_MATKEY_COLOR_DIFFUSE, 0, 0, &color);
			auto diffuse = fromAiColor(color);
		
			aiGetMaterialColor(material, AI_MATKEY_COLOR_SPECULAR, 0, 0, &color);
			auto speculer = fromAiColor(color);
		
			aiGetMaterialColor(material, AI_MATKEY_COLOR_AMBIENT, 0, 0, &color);
			auto ambient = fromAiColor(color);
		
			auto mat= new armos.graphics.Material;
			mat.diffuse = diffuse;
			mat.speculer = speculer;
			mat.ambient = ambient;
			
			return mat;
		}
		
		///
		Mesh createMesh(const(aiMesh)* mesh, const(armos.graphics.Material)[] materials) const {
			auto name = fromAiString(mesh.mName);

			auto vertices = 
				mesh.mVertices[0 .. mesh.mNumVertices]
				.map!(v => fromAiVector(v))
				.array;

			const(armos.math.Vector3f)[] normals;
			if(mesh.mNormals !is null) {
				normals = mesh.mNormals[0 .. mesh.mNumVertices]
				.map!(n => fromAiVector(n))
				.array;
			}

			Appender!(uint[])[uint] faces;
			foreach(f; mesh.mFaces[0 .. mesh.mNumFaces]) {
				immutable n = f.mNumIndices;
				auto app = n in faces;
				if(app is null) {
					app = &(faces[n] = Appender!(uint[])());
				}
				app.put(f.mIndices[0 .. n]);
			}
			import std.stdio;
			mesh.mNumVertices.writeln;
			mesh.mNumBones.writeln;
			
			// const(Bone)[] bones;
			// if(mesh.mBones !is null) {
			// 	bones = mesh.mBones[0 .. mesh.mNumBones]
			// 	.map!(b => createBone(b))
			// 	.array;
			// }
			//
			//
			// uint[][uint] facesArray;
			// foreach(e; faces.byKeyValue) {
			// 	facesArray[e.key] = e.value.data;
			// }
			// facesArray.rehash;
			//
			// immutable mi = mesh.mMaterialIndex;
			// auto material = (mi < materials.length) ? materials[mi] : null;
			// return new Mesh(
			// 		name, vertices, normals, bones, facesArray, material);
			
			return new Mesh();
		}

		aiScene* _scene;
		bool _isLoaded = false; 
	}//private
}//class AssimpModelLoader
