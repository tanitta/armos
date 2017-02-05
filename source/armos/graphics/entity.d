module armos.graphics.entity;

import armos.graphics;

/++
+/
class Entity {
    public{
        ///
        Entity draw(in PolyRenderMode renderMode){
            _material.begin;
            armos.graphics.currentRenderer.draw(_mesh, renderMode, true, true, true);
            _material.end;
            return this;
        };
        
        ///
        Entity draw(){
            draw(currentStyle.polyRenderMode);
            return this;
        };
        
        /++
            entityをワイヤフレームで描画します．
        +/
        Entity drawWireFrame(){
            draw(armos.graphics.PolyRenderMode.WireFrame);
            return this;
        };

        /++
            entityの頂点を点で描画します．
        +/
        Entity drawVertices(){
            draw(armos.graphics.PolyRenderMode.Points);
            return this;
        };

        /++
            meshの面を塗りつぶして描画します．
        +/
        Entity drawFill(){
            draw(armos.graphics.PolyRenderMode.Fill);
            return this;
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
