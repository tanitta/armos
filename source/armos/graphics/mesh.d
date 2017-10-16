module armos.graphics.mesh;
import armos.types;
import armos.math;
import armos.graphics;

/++
    ポリゴンで構成された形状を表すclassです．
+/
class Mesh {
    public{
        alias int IndexType;

        bool isVertsChanged   = false;
        bool isFaceDirty      = false;
        bool isIndicesChanged = false;

        Vector4f[]    vertices;
        Vector3f[]    normals;
        Vector3f[]    tangents;
        Vector4f[]    texCoords0;
        Vector4f[]    texCoords1;
        alias texCoords0         texCoords; 
        armos.types.FloatColor[] colors;
        IndexType[]              indices;

        /// テクスチャ座標の数を表します．
        size_t numTexCoords()const{
            return texCoords.length;
        }

        /// 頂点座標の数を表します．
        size_t numVertices()const{
            return vertices.length;
        }

        /// 法線ベクトルの数を表します．
        size_t numNormals()const{
            return normals.length;
        }

        /// 頂点インデックスの数を表します．
        size_t numIndices()const{
            return indices.length;
        }

        /// meshの描画モードを返します．
        PrimitiveMode primitiveMode()const{
            return _primitiveMode;
        }

        /// meshの描画モードを指定します．
        Mesh primitiveMode(in PrimitiveMode mode){
            _primitiveMode = mode;
            return this;
        }

        /++
            テクスチャ座標を追加します．
        +/
        Mesh addTexCoord(in Vector2f vec){
            addTexCoord(vec[0], vec[1]);
            return this;
        }

        /++
            テクスチャ座標を追加します．
        +/
        Mesh addTexCoord(in float u, in float v){
            texCoords ~= Vector4f(u, v, 0f, 1f);
            return this;
        }

        /++
            頂点座標を追加します．
        +/
        Mesh addVertex(in Vector3f vec){
            vertices ~= Vector4f(vec[0], vec[1], vec[2], 1);
            isVertsChanged = true;
            isFaceDirty = true;
            return this;
        };
        unittest{
            auto mesh = new Mesh;
            mesh.addVertex(Vector3f(0, 1, 2));
            mesh.addVertex(Vector3f(3, 4, 5));
            mesh.addVertex(Vector3f(6, 7, 8));
            assert(mesh.vertices[1][1] == 4.0);
            assert(mesh.isFaceDirty);
            assert(mesh.isVertsChanged);
        }

        /++
            頂点座標を追加します．
        +/
        Mesh addVertex(in float x, in float y, in float z){
            addVertex(Vector3f(x, y, z));
            return this;
        }

        /++
            法線ベクトルを追加します．
        +/
        Mesh addNormal(in Vector3f vec){
            normals ~= vec;
            return this;
        }

        /++
            法線ベクトルを追加します．
        +/
        Mesh addNormal(in float x, in float y, in float z){
            addNormal(Vector3f(x, y, z));
            return this;
        }

        /++
            頂点インデックスを追加します．
        +/
        Mesh addIndex(in IndexType index){
            indices ~= index;
            isIndicesChanged = true;
            isFaceDirty = true;
            return this;
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
        Mesh draw(in PolyRenderMode renderMode){
            // TODO
            // currentRenderer.draw(this, renderMode, false, false, false);
            currentRenderer.render();
            return this;
        };

        /++
            meshをワイヤフレームで描画します．
        +/
        Mesh drawWireFrame(){
            draw(PolyRenderMode.WireFrame);
            return this;
        };

        /++
            meshの頂点を点で描画します．
        +/
        Mesh drawVertices(){
            draw(PolyRenderMode.Points);
            return this;
        };

        /++
            meshの面を塗りつぶして描画します．
        +/
        Mesh drawFill(){
            draw(PolyRenderMode.Fill);
            return this;
        };

        ///
        Mesh calcNormal(){
            switch (_primitiveMode) {
                case PrimitiveMode.Triangles:
                    Vector3f[] normalSums = new Vector3f[numVertices];
                    foreach (ref sum; normalSums) {
                        sum = Vector3f.zero;
                    }
                    for (size_t i = 0; i < numIndices; i+=3){
                        immutable v1 = vertices[indices[i]].xyz;
                        immutable v2 = vertices[indices[i+1]].xyz;
                        immutable v3 = vertices[indices[i+2]].xyz;
                        immutable n = (v2-v1).vectorProduct(v3-v1).normalized;
                        normalSums[indices[i]]   += n;
                        normalSums[indices[i+1]] += n;
                        normalSums[indices[i+2]] += n;
                    }

                    import std.algorithm:map;
                    import std.array:array;
                    normals = normalSums.map!(n => n.normalized).array;
                    break;
                default:
                    return this;
            }
            return this;
        }
        
        ///
        Mesh opBinary(string op:"~")(Mesh rhs){
            assert(this.primitiveMode == rhs.primitiveMode, "missmatch primitive mode");
            import std.algorithm;
            import std.conv;
            import std.array:array;
            auto result = new Mesh;
            result.indices    = this.indices    ~ rhs.indices.map!(i => (i + this.vertices.length).to!int).array;
            result.vertices   = this.vertices   ~ rhs.vertices;
            result.normals    = this.normals    ~ rhs.normals;
            result.tangents   = this.tangents   ~ rhs.tangents;
            result.texCoords0 = this.texCoords0 ~ rhs.texCoords0;
            result.texCoords1 = this.texCoords1 ~ rhs.texCoords1;
            result.colors     = this.colors     ~ rhs.colors;
            return result;
        }
        
        unittest{
            alias V = Vector4f;
            auto m1 = new Mesh;
            m1.vertices = [
                V(1, 0, 0, 1), 
                V(0, 2, 0, 1), 
                V(0, 0, 3, 1)
            ];
            m1.indices = [0, 1, 2];
            
            auto m2 = new Mesh;
            m2.vertices = [
                V(4, 0, 0, 1), 
                V(0, 5, 0, 1), 
                V(0, 0, 6, 1)
            ];
            m2.indices = [0, 1, 2];
            
            auto m3 = m1 ~ m2;
            assert(m3.vertices.length == 6);
            assert(m3.vertices == m1.vertices ~ m2.vertices);
            assert(m3.indices.length  == m1.indices.length+m2.indices.length);
            assert(m3.indices == [0, 1, 2, 3, 4, 5]);
        }
        
        ///
        void opOpAssign(string op:"~")(Mesh rhs){
            assert(this.primitiveMode == rhs.primitiveMode, "missmatch primitive mode");
            import std.algorithm;
            import std.conv;
            import std.array:array;
            this.indices    ~= rhs.indices.map!(i => (i + this.vertices.length).to!int).array;
            this.vertices   ~= rhs.vertices;
            this.normals    ~= rhs.normals;
            this.tangents   ~= rhs.tangents;
            this.texCoords0 ~= rhs.texCoords0;
            this.texCoords1 ~= rhs.texCoords1;
            this.colors     ~= rhs.colors;
        }
        
        unittest{
            alias V = Vector4f;
            auto m1 = new Mesh;
            m1.vertices = [
                V(1, 0, 0, 1), 
                V(0, 2, 0, 1), 
                V(0, 0, 3, 1)
            ];
            m1.indices = [0, 1, 2];
            
            auto m2 = new Mesh;
            m2.vertices = [
                V(4, 0, 0, 1), 
                V(0, 5, 0, 1), 
                V(0, 0, 6, 1)
            ];
            m2.indices = [0, 1, 2];
            
            m1 ~= m2;
            assert(m1.vertices.length == 6);
            assert(m1.vertices == [
                V(1, 0, 0, 1), 
                V(0, 2, 0, 1), 
                V(0, 0, 3, 1)
            ] ~ [
                V(4, 0, 0, 1), 
                V(0, 5, 0, 1), 
                V(0, 0, 6, 1)
            ]);
            assert(m1.indices.length  == 6);
            assert(m1.indices == [0, 1, 2, 3, 4, 5]);
        }
    }//public

    private{
        PrimitiveMode _primitiveMode = PrimitiveMode.Triangles;
    }//private
}//class Mesh
