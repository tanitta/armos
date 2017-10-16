module armos.graphics.font;

import derelict.freetype.ft;
import armos.graphics;
import armos.math;
import armos.types;

/++
    読み込まれる文字を表します．
+/
struct Glyph{
    size_t index;
    uint glyph;
    int height;
    int width;
    int bearingX, bearingY;
    int xmin, xmax, ymin, ymax;
    int advance;
    float tW,tH;
    float t1,t2,v1,v2;

    void setupInfo(in size_t index, in uint glyph, in FT_Face face){
        this.index = index;
        this.glyph = glyph;
        height     = cast(int)face.glyph.metrics.height >>6;
        width      = cast(int)face.glyph.metrics.width >>6;
        bearingX   = cast(int)face.glyph.metrics.horiBearingX >>6;
        bearingY   = cast(int)face.glyph.metrics.horiBearingY >>6;
        xmin       = face.glyph.bitmap_left;
        xmax       = xmin + width;
        ymin       = -face.glyph.bitmap_top;
        ymax       = ymin + height;
        advance    = cast(int)face.glyph.metrics.horiAdvance >>6;
        tW         = width;
        tH         = height;
    }
} 

/++
Fontを読み込み，描画を行います．
+/
class Font{
    private alias This = typeof(this);
    public{
        this(){
            DerelictFT.load();
            if(!_librariesInitialized){
                FT_Error error = FT_Init_FreeType( &_library );
                if(!error){
                    _librariesInitialized = true;
                }
            }
            _mesh = new Mesh;
            _mesh.primitiveMode = PrimitiveMode.Triangles;
        }

        ~this(){
            FT_Done_Face(_face);
        }

        /++
        +/
        This load(
            in string fontPath, in int fontSize, 
            in bool isAntiAliased=false,
            in bool isFullCharacterSet=false,
            in bool makeContours=false,
            in float simplifyAmt=0.3f,
            in int dpi=0
        ){
            int fontId = 0;
            _fontSize = fontSize;
            FT_Error error = FT_New_Face( _library, fontPath.ptr, fontId, &_face );

            if(dpi!=0) _dpi = dpi;
            
            FT_Set_Char_Size( _face, fontSize << 6, fontSize << 6, _dpi, _dpi);
            _fontUnitScale = (cast(float)fontSize * _dpi) / (72 * _face.units_per_EM);
            _lineHeight = _face.height * _fontUnitScale;
            _ascenderHeight = _face.ascender * _fontUnitScale;
            _descenderHeight = _face.descender * _fontUnitScale;
            
            _glyphBBox.set(
                    _face.bbox.xMin * _fontUnitScale,
                    _face.bbox.yMin * _fontUnitScale,
                    (_face.bbox.xMax - _face.bbox.xMin) * _fontUnitScale,
                    (_face.bbox.yMax - _face.bbox.yMin) * _fontUnitScale
                    );
            
            _useKerning = FT_HAS_KERNING( _face );
            _numCharacters = (isFullCharacterSet ? 256 : 128) - NUM_CHARACTER_TO_START;
            loadEachCharacters(isAntiAliased);
            if(isAntiAliased && _fontSize>20){
            	_textureAtlas.minMagFilter(TextureMinFilter.Linear,TextureMagFilter.Linear);
            }else{
            	_textureAtlas.minMagFilter(TextureMinFilter.Nearest,TextureMagFilter.Nearest);
            }
            return this;
        }

        /++
        +/
        This drawString(in string str, in int x, in int y){
            if (str.length == 0) return this;

            _mesh.vertices   = new Vector4f[](str.length*4);
            _mesh.texCoords0 = new Vector4f[](str.length*4);
            _mesh.indices    = new int[](str.length*6);

            float xShift = x;
            float yShift = y + _lineHeight;
            int previousCharacter = 0;
            foreach (size_t i, c; str) {
                switch (c) {
                    case '\n':
                        yShift += _lineHeight;
                        xShift = x;
                        previousCharacter = 0;
                        break;
                    case '\t':
                        xShift += toCharacter(' ').advance * _letterSpace * 4;
                        previousCharacter = c;
                        break;
                    case ' ':
                        xShift += toCharacter(' ').advance * _letterSpace;
                        previousCharacter = c;
                        break;
                    default:
                        auto glyph = _characters[_glyphIndexMap[c]];
                        if(previousCharacter>0){
                            xShift += kerning(c,previousCharacter);
                        }
                        _mesh.setCharacterToStringMesh(glyph, i, xShift, yShift);
                        xShift += glyph.advance*_letterSpace;
                        previousCharacter = c;
                }
            }
            _mesh.drawWireFrame;
            // TODO set texture to this.material
            // currentMaterial.texture("tex0", _textureAtlas);
            _mesh.drawFill;
            return this;
        }

        //TODO
        /++
        +/
        // void drawStringAsShapes(string drawnString, int x, int y)const{}
    }//public

    private{
        static immutable  NUM_CHARACTER_TO_START = 32;
        static FT_Library _library;
        static bool _librariesInitialized = false;
        static int _dpi = 96;
        Glyph[] _characters;
        size_t[uint] _glyphIndexMap;
        FT_Face _face;
        int _fontSize;
        float _fontUnitScale;
        float _lineHeight = 0.0;
        float _ascenderHeight = 0.0;
        float _descenderHeight = 0.0;
        float _letterSpace = 1f;
        bool _useKerning;
        int _numCharacters = 0;
        Rectangle _glyphBBox;
        Mesh _mesh;
        Texture _textureAtlas;

        float kerning(in uint c, in uint previousCharacter){
            if(FT_HAS_KERNING( _face )){
                FT_Vector v;
                FT_Get_Kerning(_face, FT_Get_Char_Index(_face, c), FT_Get_Char_Index(_face, previousCharacter), 1, &v);
                return v.x * _fontUnitScale;
            }else{
                return 0;
            }
        }

        Glyph toCharacter(char c){
            return _characters[_glyphIndexMap[c]];
        }

        void loadEachCharacters(in bool isAntiAliased){
            int border = 4;
            long areaSum = 0;
            _characters = new Glyph[](_numCharacters);
            Bitmap!(char)[] expandedData = new Bitmap!(char)[](_numCharacters);

            foreach (size_t i, ref character; _characters) {
                uint glyph = cast(uint)(i+NUM_CHARACTER_TO_START);
                _glyphIndexMap[glyph] = i;
                if (glyph == 0xA4) glyph = 0x20AC; // hack to load the euro sign, all codes in 8859-15 match with utf-32 except for this one
                FT_Error error = FT_Load_Glyph( _face, FT_Get_Char_Index( _face, glyph ), isAntiAliased ?  FT_LOAD_FORCE_AUTOHINT : FT_LOAD_DEFAULT );

                if (isAntiAliased){
                    FT_Render_Glyph(_face.glyph, FT_RENDER_MODE_NORMAL);
                }else{
                    FT_Render_Glyph(_face.glyph, FT_RENDER_MODE_MONO);
                }

                FT_Bitmap* bitmap= &_face.glyph.bitmap;

                auto width  = bitmap.width;
                auto height = bitmap.rows;

                character.setupInfo(i, glyph, _face);

                areaSum += cast(long)( (character.tW+border*2)*(character.tH+border*2) );

                if(width==0 || height==0) continue;
                expandedData[i].allocate(width, height, ColorFormat.RGBA);
                expandedData[i].setAllPixels(0, 0);
                expandedData[i].setAllPixels(1, 0);
                expandedData[i].setAllPixels(2, 0);
                expandedData[i].setAllPixels(3, 0);

                if (isAntiAliased){
                    // Optimizable
                    for (int y = 0; y < bitmap.rows; ++y) {
                        for (int x = 0; x < bitmap.width; ++x) {
                            auto index = x + y * bitmap.pitch;
                            auto c = bitmap.buffer[index];
                            expandedData[i].pixel(x, y, 0, 255);
                            expandedData[i].pixel(x, y, 1, 255);
                            expandedData[i].pixel(x, y, 2, 255);
                            expandedData[i].pixel(x, y, 3, c);
                        }
                    }
                } else {
                    auto src =  bitmap.buffer;
                    for(typeof(height) j=0; j < height; j++) {
                        char b=0;
                        auto bptr =  src;
                        for(typeof(width) k=0; k < width; k++){

                            if (k%8==0){
                                b = (*bptr++);
                            }

                            expandedData[i].pixel(k, j, 0, b&0x80 ? 255 : 0);
                            expandedData[i].pixel(k, j, 1, b&0x80 ? 255 : 0);
                            expandedData[i].pixel(k, j, 2, b&0x80 ? 255 : 0);
                            expandedData[i].pixel(k, j, 3, b&0x80 ? 255 : 0);
                            b <<= 1;
                        }
                        src += bitmap.pitch;
                    }
                }
            }
            _textureAtlas = _characters.packInTexture(areaSum, border, expandedData);
        }
    }//private
}

private void setCharacterToStringMesh(Mesh mesh, in Glyph glyph, in size_t index, in float x, in float y){
    mesh.vertices[index*4]   = Vector4f(glyph.xmin+x, glyph.ymin+y, 0, 1);
    mesh.vertices[index*4+1] = Vector4f(glyph.xmax+x, glyph.ymin+y, 0, 1);
    mesh.vertices[index*4+2] = Vector4f(glyph.xmax+x, glyph.ymax+y, 0, 1);
    mesh.vertices[index*4+3] = Vector4f(glyph.xmin+x, glyph.ymax+y, 0, 1);

    mesh.texCoords0[index*4]   = Vector4f(glyph.t1, glyph.v1, 0, 0);
    mesh.texCoords0[index*4+1] = Vector4f(glyph.t2, glyph.v1, 0, 0);
    mesh.texCoords0[index*4+2] = Vector4f(glyph.t2, glyph.v2, 0, 0);
    mesh.texCoords0[index*4+3] = Vector4f(glyph.t1, glyph.v2, 0, 0);

    import std.conv;
    mesh.indices[index*6]   = (index*4).to!(Mesh.IndexType);
    mesh.indices[index*6+1] = (index*4+1).to!(Mesh.IndexType);
    mesh.indices[index*6+2] = (index*4+2).to!(Mesh.IndexType);
    mesh.indices[index*6+3] = (index*4+2).to!(Mesh.IndexType);
    mesh.indices[index*6+4] = (index*4+3).to!(Mesh.IndexType);
    mesh.indices[index*6+5] = (index*4).to!(Mesh.IndexType);
}

private Texture packInTexture(ref Glyph[] characters, in long areaSum, in int border, Bitmap!(char)[] expandedData){
    import std.algorithm;
    bool compareCharacters(in Glyph c1, in Glyph c2){
        if(c1.tH == c2.tH) return c1.tW > c2.tW;
        else return c1.tH > c2.tH;
    }
    auto sortedCharacter = characters.dup;
    sort!(compareCharacters)(sortedCharacter);

    Vector2i atlasSize = calcAtlasSize(areaSum, sortedCharacter, border);

    Bitmap!char atlasPixelsLuminanceAlpha;
    atlasPixelsLuminanceAlpha.allocate(atlasSize[0], atlasSize[1], ColorFormat.RGBA);
    atlasPixelsLuminanceAlpha.setAllPixels(0,0);
    atlasPixelsLuminanceAlpha.setAllPixels(1,0);
    atlasPixelsLuminanceAlpha.setAllPixels(2,0);
    atlasPixelsLuminanceAlpha.setAllPixels(3,0);


    int x=0;
    int y=0;
    int maxRowHeight = cast(int)sortedCharacter[0].tH + border*2;
    for(int i = 0; i < cast(int)sortedCharacter.length; i++){
        Bitmap!(char)* charBitmap = &expandedData[cast(int)sortedCharacter[i].index];

        if(x+cast(int)sortedCharacter[i].tW + border*2 > atlasSize[0]){
            x = 0;
            y += maxRowHeight;
            maxRowHeight = cast(int)sortedCharacter[i].tH + border*2;
        }

        characters[sortedCharacter[i].index].t1 = cast( float )(x + border)/cast( float )(atlasSize[0]);
        characters[sortedCharacter[i].index].v1 = cast( float )(y + border)/cast( float )(atlasSize[1]);
        characters[sortedCharacter[i].index].t2 = cast(float)(characters[sortedCharacter[i].index].tW + x + border)/cast(float)(atlasSize[0]);
        characters[sortedCharacter[i].index].v2 = cast(float)(characters[sortedCharacter[i].index].tH + y + border)/cast(float)(atlasSize[1]);
        charBitmap.pasteInto(atlasPixelsLuminanceAlpha,x+border,y+border);
        x+= cast(int)sortedCharacter[i].tW + border*2;
    }
    return (new Texture).allocate(atlasPixelsLuminanceAlpha);
}

private Vector2i calcAtlasSize(long areaSum, in Glyph[] sortedCharacter, int border){
    import std.math;
    bool packed = false;
    float alpha = log(cast(float)areaSum)*1.44269;
    int w;
    int h;
    while(!packed){
        w = cast(int)pow(2,floor((alpha/2.0) + 0.5)); 
        h = w;
        int x=0;
        int y=0;
        int maxRowHeight = cast(int)sortedCharacter[0].tH + border*2;
        packed = true;
        foreach (ref c; sortedCharacter) {
            import std.conv:to;
            if(x+c.tW + border*2 > w){
                x = 0;
                y += maxRowHeight;
                maxRowHeight = c.tH.to!int + border*2;
                if(y + maxRowHeight > h){
                    alpha++;
                    packed = false;
                    break;
                }
            }
            x += c.tW.to!int + border*2;
        }
    }
    return Vector2i(w, h);
}
