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
            _arcBall.radius = viewportSize.y*0.25;

            if(_isButtonPressed){
                updateTranslation();
                updateRotation();
            }

            import armos.app:targetFps;
            _arcBall.update(1.0/targetFps);

            updateCameraAriment();

            _mousePositionPre = _mousePositionCurrent;
            return this;
        }

        ///
        This reset(){
            _hasSetDistance = false;
            _arcBall.reset;
            return this;
        }

        
    }//public

    private{
        bool _hasSetDistance;
        bool _hasSetEvents = false;
        ArcBall _arcBall;
        V3 _angularSensitivity = V3(0.05, 0.05, 0.05);
        V3 _linearSensitivity = V3(0.1, 0.1, 0.1);

        V2 _mousePositionPre;
        V2 _mousePositionCurrent;
        V2 _mouseVelocity;

        float _unitDistance;

        ManupilationType _manupilationType;
        bool _isButtonPressed = false;

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
            _disposables["keyPressed"]  = currentObservables.keyPressed.filter!(event => event.key == KeyType.LeftShift || event.key == KeyType.RightShift)
                                                                       .doSubscribe!((event){_manupilationType = ManupilationType.Translation;});
            _disposables["keyReleased"] = currentObservables.keyReleased.filter!(event => event.key == KeyType.LeftShift || event.key == KeyType.RightShift)
                                                                        .doSubscribe!((event){_manupilationType = ManupilationType.RotationXY;});

            _disposables["mousePressed"]  = currentObservables.mousePressed.doSubscribe!((event){
                                                                                                    if(!V2(event.x, event.y).isInsideArcball(_arcBall.radius))return;
                                                                                                    _isButtonPressed = true;
                                                                                                    _mousePositionCurrent = V2(event.x, event.y);
                                                                                                    _mousePositionPre = _mousePositionCurrent;
                                                                                                    _mouseVelocity = V2.zero;
                                                                                                });
            _disposables["mouseDragged"]  = currentObservables.mouseDragged.doSubscribe!(event => mouseDragged(event));
            _disposables["mouseReleased"] = currentObservables.mouseReleased.doSubscribe!((event){_isButtonPressed = false;});
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
            if(_manupilationType == ManupilationType.Translation){
                // TODO
                import std.stdio; "translation".writeln;
            }

            ///TODO Scroll
            if(_manupilationType == ManupilationType.Translation){
                import std.stdio; "translation".writeln;
            }
            return this;
        }

        This updateRotation(){
            if(_manupilationType == ManupilationType.RotationXY){
                import armos.app:targetFps;
                V2 mouseVelocity = (_mousePositionCurrent - _mousePositionPre)*(1.0/targetFps);
                _arcBall.angularVelocity = _arcBall.orientation.rotatedVector(V3(-mouseVelocity.y, mouseVelocity.x, 0.0)*_angularSensitivity*_unitDistance);
                import std.stdio; "rotation".writeln;
            }

            if(_manupilationType == ManupilationType.RotationZ){
                import armos.app:targetFps;
                V2 mouseVelocity = (_mousePositionCurrent - _mousePositionPre)*(1.0/targetFps);
                //TODO
                V3 r = V3(-mouseVelocity.y, mouseVelocity.x, 0.0);
                // _arcBall.angularVelocity = _arcBall.orientation.rotatedVector(*_angularSensitivity*_unitDistance);
                // import std.stdio; "rotation".writeln;
            }
            return this;
        }

        This updateCameraAriment(){
            _target = _arcBall.position;
            _position = _target - _arcBall.orientation.rotatedVector(V3(0, 0, _unitDistance));
            _up = _arcBall.orientation.rotatedVector(V3(0, 1, 0));
            return this;
        }

        void mouseDragged(MouseDraggedEvent event){
            _mousePositionCurrent = V2(event.x, event.y);
        }
    }//private
}//class EasyCam

private bool isInsideArcball(in V2 position, in float raadius){
    import armos.app.window;
    return (position*currentWindow.pixelScreenCoordScale - viewportCenter).norm < raadius;
}

private V2 viewportCenter(){
    import armos.graphics:viewportSize, viewportPosition;
    import std.conv;
    import std.stdio;
    writeln("position", viewportPosition);
    writeln("size", viewportSize);
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
