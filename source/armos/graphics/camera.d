module armos.graphics.camera;
import armos.graphics;
import armos.math;
/++
Cameraを表すClassです．Cameraで写したい処理をbegin()とend()の間に記述します．
++/
class Camera{
	public{
		/++
			projectionMatrixを取得します．
		++/
		armos.math.Matrix4f projectionMatrix(){return _projectionMatrix;}

		/++
			Cameraの位置を表します．
		++/
		armos.math.Vector3f position;

		/++
			Cameraが映す対象の位置を表します．
		++/
		armos.math.Vector3f target;

		/++
			Cameraの方向を表します．
		++/
		armos.math.Vector3f up = armos.math.Vector3f(0, 1, 0);

		/**
			Cameraの視野角を表します．単位はdegreeです．
		**/
		double fov = 60;

		/++
			描画を行う最短距離です．
		++/
		double nearDist = 1;

		/++
			描画を行う最長距離です．
		++/
		double farDist = 1000;

		/++
			Cameraで表示する処理を開始します．
		++/
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
		++/
		void end(){
			armos.graphics.currentRenderer.unbind();
		}
	}

	private{
		armos.math.Matrix4f _projectionMatrix;
	}
}
