module armos.graphics.camera;

import armos.graphics;
import armos.math;
import armos.events;

/++
Cameraを表すinterfaceです．Cameraで写したい処理をbegin()とend()の間に記述します．
+/
interface Camera{
    public{
        /++
            projectionMatrixを取得します．
        +/
        Matrix4f projectionMatrix();
        
        /++
            viewMatrixを取得します．
        +/
        Matrix4f viewMatrix();

        /++
            Cameraの位置を表します．
        +/
        Vector3f position();
        
        ///
        Camera position(in Vector3f p);
        
        /++
            Cameraが映す対象の位置を表します．
        +/
        Vector3f target();
        
        ///
        Camera target(in Vector3f v);

        /++
            Cameraの方向を表します．
        +/
        Vector3f up();
        
        ///
        Camera up(in Vector3f v);

        /**
          Cameraの視野角を表します．単位はdegreeです．
         **/
        double fov();
        
        ///
        Camera fov(in double f);

        /++
            描画を行う最短距離です．
        +/
        double nearDist();
        
        ///
        Camera nearDist(in double n);
        
        /++
            描画を行う最長距離です．
        +/
        double farDist();
        
        ///
        Camera farDist(in double f);
            
        /++
            Cameraで表示する処理を開始します．
        +/
        Camera begin();
        
        /++
            Cameraで表示する処理を終了します．
        +/
        Camera end();
    }//public
}//interface Camera

///
class DefaultCamera: Camera{
    mixin CameraImpl;
}

mixin template CameraImpl(){
    import armos.math;
    import armos.graphics;
    import armos.app;
    private alias T = typeof(this);
    public{
        /++
            projectionMatrixを取得します．
        +/
        Matrix4f projectionMatrix()const{return _projectionMatrix;}

        ///
        Matrix4f viewMatrix()const{return _viewMatrix;}
        
        /++
            Cameraの位置を表します．
        +/
        Vector3f position()const{return _position;}
        
        ///
        T position(in Vector3f p){_position = p; return this;}
        

        /++
            Cameraが映す対象の位置を表します．
        +/
        Vector3f target()const{return _target;}
        
        ///
        T target(in Vector3f v){_target = v; return this;}

        /++
            Cameraの方向を表します．
        +/
        Vector3f up()const{return _up;}
        
        ///
        T up(in Vector3f v){_up = v; return this;}

        /**
          Cameraの視野角を表します．単位はdegreeです．
         **/
        double fov()const{return _fov;}
        
        ///
        T fov(in double f){_fov = f; return this;}

        /++
            描画を行う最短距離です．
        +/
        double nearDist()const{return _nearDist;}
        
        ///
        T nearDist(in double n){
            _nearDist = n;
            return this;
        }

        /++
            描画を行う最長距離です．
        +/
        double farDist()const{return _farDist;}
        
        ///
        T farDist(in double f){
            _farDist = f;
            return this;
        }

        /++
            Cameraで表示する処理を開始します．
        +/
        T begin(){
            _viewMatrix = lookAtViewMatrix(
                    _position, 
                    _target, 
                    _up
                    );

            _projectionMatrix = perspectiveMatrix(
                    _fov,
                    windowAspect,
                    _nearDist,
                    _farDist
                    );

            pushViewMatrix;
            loadViewMatrix(_viewMatrix);
            pushProjectionMatrix;
            loadProjectionMatrix(_projectionMatrix);
            multProjectionMatrix(scalingMatrix!float(1f, -1f, 1f));
            return this;
        }

        /++
            Cameraで表示する処理を終了します．
        +/
        T end(){
            popViewMatrix;
            popProjectionMatrix;
            return this;
        }
    }

    private{
        Matrix4f _projectionMatrix;
        Matrix4f _viewMatrix;
        
        Vector3f _position = Vector3f.zero;
        Vector3f _target   = Vector3f.zero;
        Vector3f _up       = Vector3f(0, 1, 0);
        
        double   _fov      = 60.0;
        double   _nearDist = 0.1;
        double   _farDist  = 10000.0;
    }
}
