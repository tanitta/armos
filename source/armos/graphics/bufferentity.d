module armos.graphics.bufferentity;

static import armos.graphics;

/++
+/
class BufferEntity {
    public{
        ///
        void draw(in armos.graphics.PolyRenderMode renderMode){
            _material.begin;
            armos.graphics.pushStyle;
            armos.graphics.color = _material.diffuse;
            
            //TODO
            // armos.graphics.currentRenderer.draw(_bufferMesh, renderMode, false, false, false);
            
            armos.graphics.popStyle;
            _material.end;
        };
        
        /++
            entityをワイヤフレームで描画します．
        +/
        void drawWireFrame(){
            draw(armos.graphics.PolyRenderMode.WireFrame);
        };

        /++
            entityの頂点を点で描画します．
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
        
        ///
        BufferEntity bufferMesh(armos.graphics.BufferMesh bm){
            _bufferMesh = bm;
            return this;
        }
        
        ///
        BufferEntity material(armos.graphics.Material m){
            _material = m;
            return this;
        }
        
        ///
        armos.graphics.BufferMesh bufferMesh(){
            return _bufferMesh;
        }
        
        ///
        armos.graphics.Material material(){
            return _material;
        }
    }//public

    private{
        armos.graphics.BufferMesh _bufferMesh;
        armos.graphics.Material _material;
    }//private
}//class BufferEntity
