module armos.graphics.font;
import armos.graphics;
import derelict.freetype.ft;
struct Character{
	int index;
	int glyph;
	int height;
	int width;
	int bearingX, bearingY;
	int xmin, xmax, ymin, ymax;
	int advance;
	float tW,tH;
	float t1,t2,v1,v2;
} 
class Font{
	public{
		this(){
			DerelictFT.load();
			if(!_librariesInitialized){
				FT_Error error = FT_Init_FreeType( &_library );
				if(!error){
					_librariesInitialized = true;
				}
			}
		}
		
		void loadFont(
			string fontName, int fontSize, 
			bool isAntiAliased=true,
			bool isFullCharacterSet=false,
			bool makeContours=false,
			float simplifyAmt=0.3f,
			int dpi=0
		){

			int fontId = 0;
			string filePath = armos.utils.toDataPath( fontName );
			FT_Error error = FT_New_Face( _library, filePath.ptr, fontId, &_face );
			
			if(dpi!=0){
				_dpi = dpi;
			}
			
			FT_Set_Char_Size( _face, fontSize << 6, fontSize << 6, _dpi, _dpi);
			float fontUnitScale = (cast(float)fontSize * _dpi) / (72 * _face.units_per_EM);
			_lineHeight = _face.height * fontUnitScale;
			_ascenderHeight = _face.ascender * fontUnitScale;
			_descenderHeight = _face.descender * fontUnitScale;
			
			_glyphBBox.set(
				_face.bbox.xMin * fontUnitScale,
				_face.bbox.yMin * fontUnitScale,
				(_face.bbox.xMax - _face.bbox.xMin) * fontUnitScale,
				(_face.bbox.yMax - _face.bbox.yMin) * fontUnitScale
			);
			
			_useKerning = FT_HAS_KERNING( _face );
			
			_numCharacters = (isFullCharacterSet ? 256 : 128) - NUM_CHARACTER_TO_START;
			
			loadEachCharacter(isAntiAliased);
		}
		
		void drawString(string drawnString, int x, int y)const{}
		
		void drawStringAsShapes(string drawnString, int x, int y)const{}
		
		string FontPathByName(string fontName){
			return fontName;
		};
	}
	
	private{
		static immutable  NUM_CHARACTER_TO_START = 32;
		static FT_Library _library;
		static bool _librariesInitialized = false;
		static int _dpi = 96;
		Character[] _characters;
		FT_Face _face;
		float _lineHeight = 0.0;
		float _ascenderHeight = 0.0;
		float _descenderHeight = 0.0;
		bool _useKerning;
		int _numCharacters = 0;
		armos.types.Rectangle _glyphBBox;
		
		void loadEachCharacter(bool isAntiAliased){
			int border = 1;
			long areaSum=0;
			_characters = new Character[](_numCharacters);
			armos.graphics.Bitmap!(char)[] expandedData = new armos.graphics.Bitmap!(char)[](_numCharacters);
			
			foreach (int i, ref character; _characters) {
				int glyph = cast(char)(i+NUM_CHARACTER_TO_START);
				if (glyph == 0xA4) glyph = 0x20AC; // hack to load the euro sign, all codes in 8859-15 match with utf-32 except for this one
				FT_Error error = FT_Load_Glyph( _face, FT_Get_Char_Index( _face, glyph ), isAntiAliased ?  FT_LOAD_FORCE_AUTOHINT : FT_LOAD_DEFAULT );
				
				if (isAntiAliased == true){
					FT_Render_Glyph(_face.glyph, FT_RENDER_MODE_NORMAL);
				}else{
					FT_Render_Glyph(_face.glyph, FT_RENDER_MODE_MONO);
				}
				
				FT_Bitmap* bitmap= &_face.glyph.bitmap;
				
				auto width  = bitmap.width;
				auto height = bitmap.rows;
				
				character.index = i;
				character.glyph          = glyph;
				character.height         = cast(int)_face.glyph.metrics.height >>6;
				character.width          = cast(int) _face.glyph.metrics.width >>6;
				character.bearingX       = cast(int)_face.glyph.metrics.horiBearingX >>6;
				character.bearingY       = cast(int)_face.glyph.metrics.horiBearingY >>6;
				character.xmin           = _face.glyph.bitmap_left;
				character.xmax           = character.xmin + character.width;
				character.ymin           = -_face.glyph.bitmap_top;
				character.ymax           = character.ymin + character.height;
				character.advance        = cast(int)_face.glyph.metrics.horiAdvance >>6;
				character.tW             = character.width;
				character.tH             = character.height;
				
				areaSum += cast(long)( (character.tW+border*2)*(character.tH+border*2) );
				
				if(width==0 || height==0) continue;
				

			}	
			
		}
	}
}
