module armos.graphics.material;
// import armos.types.color;
/++
材質を表すclassです．
+/
class Material {
    public{

        ///
        void begin(){
            if(_texture){
                _texture.begin;
            }
        }

        ///
        void end(){
            if(_texture){
                _texture.end;
            }
        }

        ///
        void diffuse(in armos.types.Color d){ _diffuse = d; }

        void diffuse(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){ 
            _diffuse = armos.graphics.Color(r, g, b, a); 
        }

        armos.types.Color diffuse()const{return _diffuse; }

        ///
        void speculer(in armos.types.Color s){ _specular = s; }

        ///
        void speculer(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){
            _specular = armos.graphics.Color(r, g, b, a); 
        }

        ///
        armos.types.Color speculer()const{return _specular; }

        ///
        void ambient(in armos.types.Color a){ _ambient = a; }

        void ambient(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){
            _ambient = armos.graphics.Color(r, g, b, a); 
        }

        ///
        armos.types.Color ambient()const{return _ambient; }

        ///
        void texture(armos.graphics.Texture tex){ _texture = tex; }
        armos.graphics.Texture texture(){return _texture;}

        ///
        void loadImage(in string pathInDataDir){
            auto image = new armos.graphics.Image();
            image.load(pathInDataDir);
        }

    }//public

    private{
        armos.types.Color _diffuse;
        armos.types.Color _specular;
        armos.types.Color _ambient;
        armos.graphics.Texture _texture;
    }//private
}//class Material
