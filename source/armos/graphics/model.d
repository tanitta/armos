module armos.graphics.model;

/++
++/
class Model {
	public{
		armos.graphics.Mesh[] meshes;
		armos.graphics.Material[] materials;
		
		void load(string pathInDataDir){
			meshes = (new AssimpModelLoader).load(pathInDataDir).meshes;
			materials = (new AssimpModelLoader).load(pathInDataDir).materials;
		}
		
		size_t numMeshes(){
			return meshes.length;
		}
		
		size_t numMaterials(){
			return materials.length;
		}
			
		///
		void draw(armos.graphics.PolyRenderMode renderMode){
			foreach (mesh; meshes) {
				mesh.material.begin;
				armos.graphics.pushStyle;
				armos.graphics.setColor = mesh.material.diffuse;
				armos.graphics.currentRenderer.draw(mesh, renderMode, false, false, false);
				armos.graphics.popStyle;
				mesh.material.end;
			}
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
	}//private
}//class Model

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
		Model load(string pathInDataDir){
			import std.string;
			_modelfilepath = armos.utils.absolutePath(pathInDataDir);

			import derelict.assimp3.assimp;
			import std.stdio;
			DerelictASSIMP3.load();

			loadScene(_modelfilepath);

			
			import std.stdio;
			
			auto materials
				= _scene.mMaterials[0 .. _scene.mNumMaterials]
				.map!(m => createMaterial(m))
				.array;
				
			auto meshes
				= _scene.mMeshes[0 .. _scene.mNumMeshes]
				.map!(m => createMesh(m, materials))
				.array;

			auto model = new Model;
			model.materials = materials;
			model.meshes = meshes;
			return model;
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
				// write(str);
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
		static armos.math.Vector3f fromAiVector3f(ref const( aiVector3D ) v){
			return armos.math.Vector3f(v.x, v.y, v.z);
		}
		
		static armos.math.Vector2f fromAiVector2f(ref const aiVector2D v){
			return armos.math.Vector2f(v.x, v.y);
		}

		///set material
		armos.graphics.Material createMaterial(const(aiMaterial)* material) const {
			aiString aiName;
			aiGetMaterialString(material, AI_MATKEY_NAME, 0, 0, &aiName);
			auto name = fromAiString(aiName);
		
			
			auto mat= new armos.graphics.Material;
			aiColor4D color;
		
			//diffuse
			aiGetMaterialColor(material, AI_MATKEY_COLOR_DIFFUSE, 0, 0, &color);
			mat.diffuse = fromAiColor(color);
		
			//speculer
			aiGetMaterialColor(material, AI_MATKEY_COLOR_SPECULAR, 0, 0, &color);
			mat.speculer = fromAiColor(color);
		
			//ambient
			aiGetMaterialColor(material, AI_MATKEY_COLOR_AMBIENT, 0, 0, &color);
			mat.ambient = fromAiColor(color);
			
			//material
			aiString aiPath;
			if(
				aiGetMaterialTexture(
					material,
					aiTextureType_DIFFUSE, 0, &aiPath,
					null, null, null, null, null 
				) ==  aiReturn_SUCCESS
			){
				auto image = new armos.graphics.Image;
				
				import std.path;
				string textureFileName = fromAiString( aiPath );
				image.load(buildPath( dirName(_modelfilepath), textureFileName ));
				
				mat.texture = image.texture;
			}
			
			return mat;
		}
		
		///
		armos.graphics.Mesh createMesh(const(aiMesh)* mesh, armos.graphics.Material[] materials) const {
			auto name = fromAiString(mesh.mName);

			auto vertices = 
				mesh.mVertices[0 .. mesh.mNumVertices]
				.map!(v => fromAiVector3f(v))
				.array;

			const(armos.math.Vector3f)[] normals;
			if(mesh.mNormals !is null) {
				normals = mesh.mNormals[0 .. mesh.mNumVertices]
				.map!(n => fromAiVector3f(n))
				.array;
			}
			
			import std.stdio;
			
			auto convertedMesh= new armos.graphics.Mesh;
			
			
			for (int i = 0; i < mesh.mNumVertices; i++) {
				auto texCoord = armos.graphics.TexCoord();
				texCoord.u = mesh.mTextureCoords[0][i].x;
				texCoord.v =  mesh.mTextureCoords[0][i].y;
				// texCoord.u.writeln;
				// texCoord.v.writeln;
				convertedMesh.texCoords ~= texCoord;
			}
			
			convertedMesh.vertices = vertices.map!((armos.math.Vector3f vec){
				auto vert = armos.graphics.Vertex();
				vert.x = vec[0];
				vert.y = vec[1];
				vert.z = vec[2];
				return vert;
			}).array;
			
			foreach(f; mesh.mFaces[0 .. mesh.mNumFaces]) {
				int numVertices =  f.mNumIndices;
				foreach(i; f.mIndices[0 .. numVertices]){
					convertedMesh.addIndex(i);
				}
			}
			
			immutable mi = mesh.mMaterialIndex;
			auto material = (mi < materials.length) ? materials[mi] : null;
			convertedMesh.material = material;

			return convertedMesh;
		}

		aiScene* _scene;
		bool _isLoaded = false; 
		string _modelfilepath;
	}//private
}//class AssimpModelLoader
