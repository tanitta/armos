module armos.graphics.experimental.entity;

import armos.graphics.experimental.mesh:Mesh;

import armos.graphics;

/++
+/
class Entity {
    public{
        ///
        Entity draw(Renderer renderer, in PolyRenderMode renderMode){
            _material.begin;
            pragma(msg, __FILE__, "(", __LINE__, "): ",
                   "TODO: enable to draw");
            // armos.graphics.currentRenderer.draw(_mesh, renderMode, true, true, true);
                // renderer.render();
            _material.end;
            return this;
        };

        /++
            draw entity as wireframe.
        +/
        Entity drawWireFrame(Renderer renderer){
            draw(renderer, armos.graphics.PolyRenderMode.WireFrame);
            return this;
        };

        /++
            entityの頂点を点で描画します．
        +/
        Entity drawVertices(Renderer renderer){
            draw(renderer, armos.graphics.PolyRenderMode.Points);
            return this;
        };

        /++
            meshの面を塗りつぶして描画します．
        +/
        Entity drawFill(Renderer renderer){
            draw(renderer, armos.graphics.PolyRenderMode.Fill);
            return this;
        };
        
        ///
        Entity mesh(Mesh!float m){
            _mesh = m;
            return this;
        }
        
        ///
        Entity material(armos.graphics.Material m){
            _material = m;
            return this;
        }
        
        ///
        Mesh!float mesh(){
            return _mesh;
        }
        
        ///
        armos.graphics.Material material(){
            return _material;
        }
    }//public

    private{
        Mesh!float _mesh;
        armos.graphics.Material _material;

    }//private
}//class Entity
