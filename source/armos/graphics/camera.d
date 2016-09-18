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
class BasicCamera: Camera{
    mixin CameraImpl;
}

mixin template CameraImpl(){
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

            // _projectionMatrix = persp*lookAt;
            // currentRenderer.bind(_projectionMatrix);
            pushViewMatrix;
            loadViewMatrix(_viewMatrix);
            pushProjectionMatrix;
            loadProjectionMatrix(_projectionMatrix);
            // loadProjectionMatrix(_projectionMatrix);
            return this;
        }

        /++
            Cameraで表示する処理を終了します．
        +/
        T end(){
            popViewMatrix;
            popProjectionMatrix;
            // currentRenderer.unbind();
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

import armos.app;
import armos.events;

/++
    Deprecated: WIP
+/
class EasyCam : Camera{
    mixin CameraImpl;
    
    private{
        alias N = float;
        alias Q = Quaternion!(N);
        alias V3 = Vector!(N, 3);
        alias V4 = Vector!(N, 4);
        alias M33 = Matrix!(N, 3, 3);
        alias M44 = Matrix!(N, 4, 4);
    }
    
    public{
        this(){
            addListener(currentWindow.events.mouseMoved, this, &this.mouseMoved);
            addListener(currentWindow.events.mouseReleased, this, &this.mouseReleased);
            addListener(currentWindow.events.mousePressed, this, &this.mousePressed);
            addListener(currentWindow.events.update, this, &this.update);

            reset;
        }

        void reset(){
            _down = Q.unit;
            _now = Q.unit;
            _rotation = M44.identity;
            _translation = M44.identity;
            _translationDelta = M44.identity;
            _isDrag = false;
            _radiusTranslation = N(1);
            _radius = N(1);

            _oldMousePosition = V3.zero;
            _currentMousePosition = V3.zero;
            _mouseMovingDirection = V3.zero;
        }
    }//public

    private{
        Q _down;
        Q _now;
        M44 _rotation;
        M44 _translation;
        M44 _translationDelta;
        bool _isDrag;
        N _radiusTranslation;
        N _radius;

        V3 _oldMousePosition;
        V3 _currentMousePosition;
        V3 _mouseMovingDirection;

        void mouseMoved(ref MouseMovedEventArg message){
            _currentMousePosition = V3(message.x, message.y, 0);

        }

        void mouseReleased(ref MouseReleasedEventArg message){
            _isDrag = false;
        }

        void mousePressed(ref MousePressedEventArg message){
            _isDrag = true;
        }

        void update(ref EventArg arg){
            _oldMousePosition = _currentMousePosition;
            _mouseMovingDirection = _currentMousePosition - _oldMousePosition;
        }
    }//private
}//class EasyCam

unittest{
    assert(__traits(compiles, (){
                auto cam = new EasyCam;
                }));
}
