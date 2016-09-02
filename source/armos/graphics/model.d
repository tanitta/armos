module armos.graphics.model;

static import armos.graphics;
static import armos.math;
static import armos.types;

/++
3Dモデルを読み込み，描画するclassです．
+/
class Model {
    public{
        armos.graphics.Mesh[] meshes;
        armos.graphics.Material[] materials;
        armos.graphics.Entity[] entities;

        /++
            モデルを読み込みます．

            読み込み時にmeshはmaterial毎に分割されます．
        +/
        void load(in string pathInDataDir){
            auto loadedModel = (new AssimpModelLoader).load(pathInDataDir);
            meshes    = loadedModel.meshes;
            materials = loadedModel.materials;
            entities  = loadedModel.entities;
        }

        /++
            読み込まれたmeshの数を返します．
        +/
        size_t numMeshes()const{
            return meshes.length;
        }

        /++
            読み込まれたmaterialの数を返します．
        +/
        size_t numMaterials()const{
            return materials.length;
        }

        /++
            modelを描画します．
            Params:
            renderMode = 面，線，点のどれを描画するか指定します．
        +/
        void draw(in armos.graphics.PolyRenderMode renderMode){
            foreach (entity; entities) {
                entity.draw(renderMode);
            }
        };

        /++
            modelをワイヤフレームで描画します．
        +/
        void drawWireFrame(){
            draw(armos.graphics.PolyRenderMode.WireFrame);
        };

        /++
            modelの頂点を点で描画します．
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
    }//private
}//class Model

import derelict.assimp3.assimp;
import std.stdio;
import std.algorithm : map;
import std.array : array, Appender;

/++
    Assimpによりmodelの読み込みを行います．
+/
class AssimpModelLoader {
    public{
        ~this(){
            clear;
        }

        /// modelを読み込みそれを返します．
        Model load(in string pathInDataDir){
            import std.string;
            static import armos.utils;
            _modelfilepath = armos.utils.absolutePath(pathInDataDir);

            import derelict.assimp3.assimp;
            import std.stdio;
            DerelictASSIMP3.load();

            loadScene(_modelfilepath);
            
            return createdModel(_scene);
        }

        /// 読み込んだモデルを削除します．
        void clear(){
            if(_isLoaded){
                aiReleaseImport(_scene);
                _isLoaded = false;
            }
        }


    }//public 
    
    private{

        ///
        void loadScene(in string fileName){
            auto f = File(fileName, "r");

            char[] str;
            while (f.readln(str)){
                // write(str);
            }

            aiPropertyStore* store = aiCreatePropertyStore();
            immutable uint flags = aiProcess_CalcTangentSpace
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
        
        armos.graphics.Model createdModel(const(aiScene)* scene)const{
            import std.range;
            auto model = new Model;
            model.materials = scene.mMaterials[0 .. scene.mNumMaterials]
                                   .map!(m => createdMaterial(m))
                                   .array;

            model.meshes    = scene.mMeshes[0 .. scene.mNumMeshes]
                                   .map!(m => createdMesh(m))
                                   .array;
            
            model.entities  = scene.mMeshes[0 .. scene.mNumMeshes]
                                   .length
                                   .iota
                                   .map!( 
                                           i => (new armos.graphics.Entity).mesh(model.meshes[i])
                                                                            .material(model.materials[scene.mMeshes[i].mMaterialIndex])
                                        )
                                   .array;
            return model;
        }

        armos.graphics.Material createdMaterial(const(aiMaterial)* material) const {
            aiString aiName;
            aiGetMaterialString(material, AI_MATKEY_NAME, 0, 0, &aiName);
            auto name = fromAiString(aiName);


            auto mat= new armos.graphics.DefaultMaterial;
            aiColor4D color;

            //diffuse
            aiGetMaterialColor(material, AI_MATKEY_COLOR_DIFFUSE, 0, 0, &color);
            mat.attr("diffuse") = fromAiColor(color);

            //speculer
            aiGetMaterialColor(material, AI_MATKEY_COLOR_SPECULAR, 0, 0, &color);
            mat.attr("speculer") = fromAiColor(color);

            //ambient
            aiGetMaterialColor(material, AI_MATKEY_COLOR_AMBIENT, 0, 0, &color);
            mat.attr("ambient") = fromAiColor(color);

            //texture
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
                immutable string textureFileName = fromAiString( aiPath );
                image.load(buildPath( dirName(_modelfilepath), textureFileName ));

                mat.texture = image.texture;
            }

            return mat;
        }

        armos.graphics.Mesh createdMesh(const(aiMesh)* mesh) const {
        // armos.graphics.Mesh createMesh(const(aiMesh)* mesh, armos.graphics.Material[] materials) const {
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
                convertedMesh.texCoords ~= armos.math.Vector4f(mesh.mTextureCoords[0][i].x, mesh.mTextureCoords[0][i].y, 0f, 1f);
            }

            convertedMesh.vertices = vertices.map!((armos.math.Vector3f vec){
                    return armos.math.Vector4f(vec[0], vec[1], vec[2], 1f);
                    }).array;

            foreach(f; mesh.mFaces[0 .. mesh.mNumFaces]) {
                immutable int numVertices =  f.mNumIndices;
                foreach(i; f.mIndices[0 .. numVertices]){
                    convertedMesh.addIndex(i);
                }
            }

            // immutable mi = mesh.mMaterialIndex;
            // auto material = (mi < materials.length) ? materials[mi] : null;
            // convertedMesh.material = material;

            return convertedMesh;
        }

        aiScene* _scene;
        bool _isLoaded = false; 
        string _modelfilepath;
    }//private
}//class AssimpModelLoader
