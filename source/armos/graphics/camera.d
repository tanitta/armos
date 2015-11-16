module armos.graphics.camera;
import armos.graphics;
import armos.math;

class Camera{
	armos.math.Matrix4f projectionMatrix;
	
	armos.math.Vector3f position;
	armos.math.Vector3f target;
	armos.math.Vector3f up = armos.math.Vector3f(0, 1, 0);
	double fov = 60;
	double nearDist = 0;
	double farDist = 1000;
	
	void start(){
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
		
		armos.math.Matrix4f vFlip = armos.math.Matrix4f(
			[1, 0, 0, 0],
			[0, -1, 0, armos.app.windowSize[1]],
			[0, 0, 1, 0],
			[0, 0, 0, 1],
		);
		
		projectionMatrix = vFlip*persp*lookAt;
		armos.graphics.currentRenderer.bind(projectionMatrix);
	}
	void end(){
		armos.graphics.currentRenderer.unbind();
	}
}
