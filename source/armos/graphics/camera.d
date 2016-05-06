module armos.graphics.camera;
import armos.graphics;
import armos.math;
/++
Cameraを表すClassです．Cameraで写したい処理をbegin()とend()の間に記述します．
+/
class Camera{
	public{
		/++
			projectionMatrixを取得します．
		+/
		armos.math.Matrix4f projectionMatrix(){return _projectionMatrix;}

		/++
			Cameraの位置を表します．
		+/
		armos.math.Vector3f position = armos.math.Vector3f.zero;

		/++
			Cameraが映す対象の位置を表します．
		+/
		armos.math.Vector3f target = armos.math.Vector3f.zero;

		/++
			Cameraの方向を表します．
		+/
		armos.math.Vector3f up = armos.math.Vector3f(0, 1, 0);

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
			armos.math.Matrix4f lookAt = armos.graphics.lookAtViewMatrix(
					position, 
					target, 
					up
					);

			armos.math.Matrix4f persp =  armos.graphics.perspectiveMatrix(
					fov,
					armos.app.windowAspect,
					nearDist,
					farDist
					);

			// armos.math.Matrix4f vFlip = armos.math.Matrix4f(
			// 	[1,  0, 0, 0                       ],
			// 	[0, -1, 0, armos.app.windowSize[1] ],
			// 	[0, 0,  1, 0                       ],
			// 	[0, 0,  0, 1                       ],
			// );

			_projectionMatrix = persp*lookAt;
			armos.graphics.currentRenderer.bind(_projectionMatrix);
		}

		/++
			Cameraで表示する処理を終了します．
		+/
		void end(){
			armos.graphics.currentRenderer.unbind();
		}
	}

	private{
		armos.math.Matrix4f _projectionMatrix;
	}
}

/++
	Deprecated:
+/
class EasyCam : Camera{
	alias N = float;
	alias Q = Quaternion!(N);
	alias V3 = Vector!(N, 3);
	alias V4 = Vector!(N, 4);
	alias M33 = Matrix!(N, 3, 3);
	alias M44 = Matrix!(N, 4, 4);
	
	public{
		this(){
			armos.events.addListener(armos.app.currentWindow.events.mouseMoved, this, &this.mouseMoved);
			armos.events.addListener(armos.app.currentWindow.events.mouseReleased, this, &this.mouseReleased);
			armos.events.addListener(armos.app.currentWindow.events.mousePressed, this, &this.mousePressed);
			armos.events.addListener(armos.app.currentWindow.events.update, this, &this.update);
			
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

		void mouseMoved(ref armos.events.MouseMovedEventArg message){
			_currentMousePosition = V3(message.x, message.y, 0);
			
		}
		
		void mouseReleased(ref armos.events.MouseReleasedEventArg message){
			_isDrag = false;
		}
		
		void mousePressed(ref armos.events.MousePressedEventArg message){
			_isDrag = true;
		}
		
		void update(ref armos.events.EventArg arg){
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
