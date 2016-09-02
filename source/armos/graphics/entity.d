module armos.graphics.entity;

import armos.graphics;

/++
+/
class Entity {
    public{
        ///
        void draw(in PolyRenderMode renderMode){
            _material.begin;
            armos.graphics.pushStyle;
            armos.graphics.color = _material.attr("diffuse");
            armos.graphics.currentRenderer.draw(_mesh, renderMode, false, false, false);
            armos.graphics.popStyle;
            _material.end;
        };
        
        ///
        void draw(){
            draw(currentStyle.polyRenderMode);
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
        Entity mesh(armos.graphics.Mesh m){
            _mesh = m;
            return this;
        }
        
        ///
        Entity material(armos.graphics.Material m){
            _material = m;
            return this;
        }
        
        ///
        armos.graphics.Mesh mesh(){
            return _mesh;
        }
        
        ///
        armos.graphics.Material material(){
            return _material;
        }
    }//public

    private{
        armos.graphics.Mesh _mesh;
        armos.graphics.Material _material;
    }//private
}//class Entity
