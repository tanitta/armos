module armos.graphics.node;
import armos.math;
/++
座標系の親子関係を表すclassです．
Deprecated: 現在使われていません．
+/
class Node {
    private armos.math.Vector3f position;
    private armos.math.Quaternionf orientation;
    private armos.math.Vector3f scale;

    private armos.math.Matrix4f localTransformMatrix;

    protected Node* parent;


}
