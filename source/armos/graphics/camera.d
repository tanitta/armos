module armos.graphics.camera;
import armos.graphics;
import armos.math;
import armos.events;
/++
Cameraを表すClassです．Cameraで写したい処理をbegin()とend()の間に記述します．
+/
class Camera{
    public{
        /++
            projectionMatrixを取得します．
        +/
        Matrix4f projectionMatrix()const{return _projectionMatrix;}

        /++
            Cameraの位置を表します．
        +/
        Vector3f position = Vector3f.zero;

        /++
            Cameraが映す対象の位置を表します．
        +/
        Vector3f target = Vector3f.zero;

        /++
            Cameraの方向を表します．
        +/
        Vector3f up = Vector3f(0, 1, 0);

        /**
          Cameraの視野角を表します．単位はdegreeです．
         **/
        double fov = 60;

        /++
            描画を行う最短距離です．
        +/
        double nearDist = 0.1;

        /++
            描画を行う最長距離です．
        +/
        double farDist = 10000;

        /++
            Cameraで表示する処理を開始します．
        +/
        void begin(){
            Matrix4f lookAt = lookAtViewMatrix(
                    position, 
                    target, 
                    up
                    );

            Matrix4f persp =  perspectiveMatrix(
                    fov,
                    windowAspect,
                    nearDist,
                    farDist
                    );

            // Matrix4f vFlip = Matrix4f(
            // 	[1,  0, 0, 0                       ],
            // 	[0, -1, 0, windowSize[1] ],
            // 	[0, 0,  1, 0                       ],
            // 	[0, 0,  0, 1                       ],
            // );

            _projectionMatrix = persp*lookAt;
            // currentRenderer.bind(_projectionMatrix);
            pushViewMatrix;
            loadViewMatrix(lookAt);
            pushProjectionMatrix;
            loadProjectionMatrix(persp);
            // loadProjectionMatrix(_projectionMatrix);
        }

        /++
            Cameraで表示する処理を終了します．
        +/
        void end(){
            popViewMatrix;
            popProjectionMatrix;
            // currentRenderer.unbind();
        }
    }

    private{
        Matrix4f _projectionMatrix;
    }
}

/++
    Deprecated: WIP
+/
import armos.app;
import armos.events;
class EasyCam : Camera{
    alias N = float;
    alias Q = Quaternion!(N);
    alias V3 = Vector!(N, 3);
    alias V4 = Vector!(N, 4);
    alias M33 = Matrix!(N, 3, 3);
    alias M44 = Matrix!(N, 4, 4);

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
