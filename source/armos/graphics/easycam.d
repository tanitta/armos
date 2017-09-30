module armos.graphics.easycam;
import armos.graphics.camera;
import armos.math;

private alias V2 = Vector2f;
private alias V3 = Vector3f;
private alias M3 = Matrix3f;
private alias Q  = Quaternionf;

private enum ManupilationType {
    RotationXY,
    RotationZ,
    Translation
}//enum ManupilationType

///
class EasyCam :Camera{
    import armos.events;
    import armos.app;
    import rx;
    private  alias This = typeof(this);
    mixin CameraImpl;

    public{
        ///
        this(){
            _subjectTranslate = new SubjectObject!V3;
            _subjectRotate    = new SubjectObject!V3;
            _subjectZoom      = new SubjectObject!float;
            // _moussePositionPre = 
            _manupilationType = ManupilationType.RotationXY;
            _arcBall = new ArcBall;

            reset();
        }

        ///
        ~this(){
            if(_hasSetEvents){
                removeEvents();
            }
        }

        ///
        This update(){
            if(!_hasSetEvents){
                addEvents();
            }

            if(_isButtonPressed){
                _mouseVelocity = _mousePositionCurrent - _mousePositionPre;
            }else{
                _mouseVelocity = V2.zero;
            }

            import armos.graphics:viewportSize;
            import std.math;
            _unitDistance = viewportSize.y / (2.0f * tan(PI * _fov / 360.0f));
            _arcBall.radius = viewportSize.y*0.5;

            if(_isButtonPressed){
            }
            updateTranslation();
            updateRotation();

            import armos.app:targetFps;
            _arcBall.update(1.0/targetFps);

            updateCameraAriment();

            _mousePositionPre = _mousePositionCurrent;
            _mouseScrollAmount = 0;
            return this;
        }

        ///
        This reset(){
            _hasSetDistance = false;
            _arcBall.reset;
            _distanceRate = 1.0;
            _mouseScrollAmount = 0.0;
            return this;
        }

        
    }//public

    private{
        bool _hasSetDistance;
        bool _hasSetEvents = false;
        ArcBall _arcBall;
        V3 _angularSensitivity = V3(40, 40, 0.05);
        V3 _linearSensitivity = V3(5, 5, 0.02);

        V2 _mousePositionPre;
        V2 _mousePositionCurrent;
        V2 _mouseVelocity;
        float _mouseScrollAmount;
        float _distanceRate = 1.0;

        float _unitDistance;

        ManupilationType _manupilationType;
        bool _isButtonPressed = false;
        bool _isShiftPressed = false;

        Disposable _disposableKeyPressed;
        Disposable _disposableKeyReleased;
        Disposable _disposableMousePressed;
        Disposable _disposableMouseDragged;
        Disposable _disposableMouseReleased;
        Disposable[string] _disposables;

        SubjectObject!V3    _subjectTranslate;
        SubjectObject!V3    _subjectRotate;
        SubjectObject!float _subjectZoom;


        This addEvents(){
            import std.typecons;
            import armos.utils.keytype;
            _disposables["keyPressed"]    = currentObservables.keyPressed
                                                              .filter!(event => event.key == KeyType.LeftShift || event.key == KeyType.RightShift)
                                                              .doSubscribe!((event){_isShiftPressed = true;
                                                                      });
            _disposables["keyReleased"]   = currentObservables.keyReleased
                                                              .filter!(event => event.key == KeyType.LeftShift || event.key == KeyType.RightShift)
                                                              .doSubscribe!((event){_isShiftPressed = false;
                                                                      });

            _disposables["mousePressed"]  = currentObservables.mousePressed
                                                              .doSubscribe!((event){
                                                                                       if(_isShiftPressed){
                                                                                           _manupilationType = ManupilationType.Translation;
                                                                                           _isButtonPressed = true;
                                                                                           _mousePositionCurrent = V2(event.x, event.y);
                                                                                           _mousePositionPre = _mousePositionCurrent;
                                                                                           _mouseVelocity = V2.zero;
                                                                                       }else{
                                                                                           if(V2(event.x, event.y).isInside(_arcBall.radius)){
                                                                                               _isButtonPressed = true;
                                                                                               _mousePositionCurrent = V2(event.x, event.y);
                                                                                               _mousePositionPre = _mousePositionCurrent;
                                                                                               _mouseVelocity = V2.zero;
                                                                                               _manupilationType = ManupilationType.RotationXY;
                                                                                               if(V2(event.x, event.y).isInside(_arcBall.radius, _arcBall.radius*0.7)){
                                                                                                   _manupilationType = ManupilationType.RotationZ;
                                                                                               }
                                                                                           }
                                                                                       }
                                                                                   });
            _disposables["mouseDragged"]  = currentObservables.mouseDragged
                                                              .doSubscribe!(event => mouseDragged(event));
            _disposables["mouseReleased"] = currentObservables.mouseReleased
                                                              .doSubscribe!((event){_isButtonPressed = false;});

            _disposables["mouseScrolled"] = currentObservables.mouseScrolled
                                                              .doSubscribe!((event){_mouseScrollAmount += event.yOffset;});
            _hasSetEvents = true;
            return this;
        }

        This removeEvents(){
            import std.algorithm;
            _disposables.keys.map!(key => _disposables[key])
                             .each!(d => d.dispose);
            _hasSetEvents = false;
            return this;
        }

        This updateTranslation(){
            if(_isButtonPressed){
                if(_manupilationType == ManupilationType.Translation){
                    import armos.app:targetFps;
                    V2 mouseVelocity = (_mousePositionCurrent - _mousePositionPre)*(1.0/targetFps);
                    _arcBall.linearVelocity = _arcBall.orientation.rotatedVector(V3(mouseVelocity.x, mouseVelocity.y, 0.0)*_linearSensitivity*_distanceRate*_unitDistance);
                }
            }

            if(_mouseScrollAmount != 0f){
                import std.math;
                _distanceRate = fmax(_distanceRate + _mouseScrollAmount*_linearSensitivity.z, 0);
            }
            return this;
        }

        This updateRotation(){
            if(_isButtonPressed){
                if(_manupilationType == ManupilationType.RotationXY){
                    import armos.app:targetFps;
                    V2 mouseVelocity = (_mousePositionCurrent - _mousePositionPre)*(1.0/targetFps);
                    _arcBall.angularVelocity = _arcBall.orientation.rotatedVector(V3(mouseVelocity.y, -mouseVelocity.x, 0.0)*_angularSensitivity);
                }

                if(_manupilationType == ManupilationType.RotationZ){
                    import armos.app:targetFps;
                    import std.math;
                    V2 mouseVelocity = (_mousePositionCurrent - _mousePositionPre)*(1.0/targetFps);
                    auto mousePositionFromCenter = (_mousePositionCurrent*currentWindow.pixelScreenCoordScale - viewportCenter);
                    auto thetaVelocity = V3(mouseVelocity.x, mouseVelocity.y, 0).vectorProduct(V3(mousePositionFromCenter.x, mousePositionFromCenter.y, 0)).z;
                    _arcBall.angularVelocity = _arcBall.orientation.rotatedVector(V3(0f, 0f, thetaVelocity)*_angularSensitivity);
                }
            }
            return this;
        }

        This updateCameraAriment(){
            _target = _arcBall.position;
            _position = _target - _arcBall.orientation.rotatedVector(V3(0, 0, _distanceRate*_unitDistance));
            _up = _arcBall.orientation.rotatedVector(V3(0, 1, 0));
            return this;
        }

        void mouseDragged(MouseDraggedEvent event){
            _mousePositionCurrent = V2(event.x, event.y);
        }
    }//private
}//class EasyCam

private bool isInside(in V2 position, in float radius1, in float radius2 = 0.0){
    import std.math;
    auto rMax = fmax(radius1, radius2);
    auto rMin = fmin(radius1, radius2);
    import armos.app.window;
    auto rMouse = (position*currentWindow.pixelScreenCoordScale - viewportCenter).norm;
    return rMin < rMouse && rMouse < rMax;
}

private V2 viewportCenter(){
    import armos.graphics:viewportSize, viewportPosition;
    import std.conv;
    return viewportPosition.to!V2 + viewportSize.to!V2 * 0.5;
}

/++
+/
private class ArcBall {
    public{
        V3 angularVelocity;
        V3 linearVelocity;
        Q orientation;
        V3 position;
        float linearDamping = 0.9;
        float angularDamping = 0.9;
        float radius = 1.0;

        ///
        this(){
            reset();
        }

        ///
        ArcBall reset(){
            angularVelocity = V3.zero;
            linearVelocity  = V3.zero;
            orientation     = Q.unit;
            position        = V3.zero;
            return this;
        }

        ///
        ArcBall update(in float unitTime){
            position = position + linearVelocity * unitTime;
            if(angularVelocity.norm > 0.0){
                immutable qAngularVelocityPerUnitTime = Q.angleAxis(angularVelocity.norm*unitTime, angularVelocity.normalized);
                orientation = qAngularVelocityPerUnitTime * orientation;
            }
            linearVelocity  = linearVelocity*linearDamping;
            angularVelocity = angularVelocity*angularDamping;
            return this;
        }
    }//public
}//class ArcBall
