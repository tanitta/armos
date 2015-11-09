module armos.graphics.node;
import armos.math;

class Node {
	private armos.math.Vector3f position;
	private armos.math.Quaternionf orientation;
	private armos.math.Vector3f scale;
	
	private armos.math.Matrix4f localTransformMatrix;
	
	protected Node* parent;
	
	
}
