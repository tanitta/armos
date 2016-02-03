module armos.graphics.material;
// import armos.types.color;
/++
++/
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
		void diffuse(armos.types.Color d){ _diffuse = d; }
		
		void diffuse(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){ 
			_diffuse = armos.graphics.Color(r, g, b, a); 
		}
		
		armos.types.Color diffuse(){return _diffuse; }
		
		///
		void speculer(armos.types.Color s){ _specular = s; }
	
		///
		void speculer(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){
			_specular = armos.graphics.Color(r, g, b, a); 
		}
		
		///
		armos.types.Color speculer(){return _specular; }
		
		///
		void ambient(armos.types.Color a){ _ambient = a; }
		
		void ambient(T)(in T r, in T g, in T b, in T a = T( armos.graphics.Color.limit )){
			_ambient = armos.graphics.Color(r, g, b, a); 
		}
		
		///
		armos.types.Color ambient(){return _ambient; }
		
		///
		void texture(armos.graphics.Texture tex){ _texture = tex; }
		armos.graphics.Texture texture(){return _texture;}
		
		///
		void loadImage(string pathInDataDir){
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
