module armos.graphics.primitives;
import armos.graphics;
import armos.math;
import std.math;

/++
箱状のMeshを返します．
+/
armos.graphics.Mesh boxPrimitive(in armos.math.Vector3f position, in armos.math.Vector3f size){
    auto mesh = new armos.graphics.Mesh;

    auto halfSize = size*0.5;
    mesh.primitiveMode = armos.graphics.PrimitiveMode.Triangles;

    mesh.addVertex(armos.math.Vector3f( -halfSize[0], -halfSize[1], -halfSize[2]  )+position);
    mesh.addVertex(armos.math.Vector3f( halfSize[0],  -halfSize[1], -halfSize[2]  )+position);
    mesh.addVertex(armos.math.Vector3f( halfSize[0],  halfSize[1],  -halfSize[2]  )+position);
    mesh.addVertex(armos.math.Vector3f( -halfSize[0], halfSize[1],  -halfSize[2]  )+position);

    mesh.addVertex(armos.math.Vector3f( -halfSize[0],  halfSize[1], halfSize[2] )+position);
    mesh.addVertex(armos.math.Vector3f( halfSize[0], halfSize[1], halfSize[2] )+position);
    mesh.addVertex(armos.math.Vector3f( halfSize[0], -halfSize[1],  halfSize[2] )+position);
    mesh.addVertex(armos.math.Vector3f( -halfSize[0], -halfSize[1],  halfSize[2] )+position);

    mesh.addIndex(0);
    mesh.addIndex(2);
    mesh.addIndex(1);

    mesh.addIndex(0);
    mesh.addIndex(3);
    mesh.addIndex(2);

    mesh.addIndex(4);
    mesh.addIndex(6);
    mesh.addIndex(5);

    mesh.addIndex(4);
    mesh.addIndex(7);
    mesh.addIndex(6);
    //
    //
    mesh.addIndex(2);
    mesh.addIndex(3);
    mesh.addIndex(5);

    mesh.addIndex(3);
    mesh.addIndex(4);
    mesh.addIndex(5);

    mesh.addIndex(0);
    mesh.addIndex(1);
    mesh.addIndex(6);

    mesh.addIndex(0);
    mesh.addIndex(6);
    mesh.addIndex(7);

    mesh.addIndex(1);
    mesh.addIndex(2);
    mesh.addIndex(5);

    mesh.addIndex(1);
    mesh.addIndex(5);
    mesh.addIndex(6);

    mesh.addIndex(0);
    mesh.addIndex(7);
    mesh.addIndex(3);

    mesh.addIndex(3);
    mesh.addIndex(7);
    mesh.addIndex(4);
    return mesh;
}

/++
連続した線のMeshを返します．
Params:
arr = 線の頂点です．任意の個数設定できます．
+/
armos.graphics.Mesh linePrimitive(armos.math.Vector3f[] arr ...){
    if (arr.length < 2) {
        assert(0);
    }
    auto mesh = new armos.graphics.Mesh;
    mesh.primitiveMode = armos.graphics.PrimitiveMode.LineStrip ;
    foreach (int index, vec; arr) {
        mesh.addVertex(vec);
        mesh.addIndex(index);
    }
    return mesh;
}

/++
球体のMeshを返します．
Deprecated: 現在動作しません．
+/
armos.graphics.Mesh spherePrimitive(){
    auto mesh = new armos.graphics.Mesh;
    return mesh;
}

/++
円錐のMeshを返します．
Deprecated: 現在動作しません．
+/
armos.graphics.Mesh conePrimitive(){
    auto mesh = new armos.graphics.Mesh;
    return mesh;
}

/++
円筒のMeshを返します．
Deprecated: 現在動作しません．
+/
armos.graphics.Mesh cylinderPrimitive(){
    auto mesh = new armos.graphics.Mesh;
    return mesh;
}

/++
多面体のMeshを返します．
Deprecated: 現在動作しません．
+/
armos.graphics.Mesh icoSpherePrimitive(){
    auto mesh = new armos.graphics.Mesh;
    return mesh;
}

/++
円盤のMeshを返します．
Params:
position = 円盤の中心の座標を指定します．
radius = 円盤の半径を指定します．
resolution = 円盤の分割数を指定します．
+/
armos.graphics.Mesh circlePrimitive(in armos.math.Vector3f position, in float radius, in int resolution = 12){
    auto mesh = new armos.graphics.Mesh;
    for (int i = 0; i < resolution; i++) {
        mesh.addVertex(position);
        mesh.addVertex(position+armos.math.Vector3f(
                    radius*cos(cast(float)i/cast(float)resolution*2.0*PI),
                    radius*sin(cast(float)i/cast(float)resolution*2.0*PI),
                    0
                    ));
        mesh.addVertex(position+armos.math.Vector3f(
                    radius*cos(cast(float)(i+1)/cast(float)resolution*2.0*PI),
                    radius*sin(cast(float)(i+1)/cast(float)resolution*2.0*PI),
                    0
                    ));
    }
    for (int i = 0; i < resolution*3; i++) {
        mesh.addIndex(i);
    }
    return mesh;
}

/++
円盤のMeshを返します．
Params:
x = 円盤の中心のX座標を指定します．
y = 円盤の中心のY座標を指定します．
z = 円盤の中心のZ座標を指定します．
radius = 円盤の半径を指定します．
resolution = 円盤の分割数を指定します．
+/
armos.graphics.Mesh circlePrimitive(in float x, in float y, in float z, in float radius, in int resolution = 12){
    return circlePrimitive(armos.math.Vector3f(x, y, z), radius, resolution);
}

/++
長方形のMeshを返します．
Params:
position = 長方形の中心の座標を指定します．
size = 長方形の大きさを指定します．
+/
armos.graphics.Mesh planePrimitive(in armos.math.Vector3f position, in armos.math.Vector2f size){
    auto mesh = new armos.graphics.Mesh;
    mesh.primitiveMode = armos.graphics.PrimitiveMode.Triangles;
    mesh.addVertex(armos.math.Vector3f( -size[0]*0.5, -size[0]*0.5, 0)+position);
    mesh.addVertex(armos.math.Vector3f( size[0]*0.5,  -size[0]*0.5, 0)+position);
    mesh.addVertex(armos.math.Vector3f( size[0]*0.5,  size[0]*0.5,  0)+position);
    mesh.addVertex(armos.math.Vector3f( -size[0]*0.5, size[0]*0.5,  0)+position);

    mesh.addIndex(0);
    mesh.addIndex(1);
    mesh.addIndex(2);

    mesh.addIndex(0);
    mesh.addIndex(3);
    mesh.addIndex(2);
    return mesh;
}

/++
長方形のMeshを返します．
Params:
x = 長方形の中心のX座標を指定します．
y = 長方形の中心のY座標を指定します．
z = 長方形の中心のZ座標を指定します．
w = 長方形のX方向の大きさを指定します．
h = 長方形のY方向の大きさを指定します．
+/
armos.graphics.Mesh planePrimitive(in float x, in float y, in float z, in float w, in float h){
    return planePrimitive(armos.math.Vector3f(x, y, z), armos.math.Vector2f(w, h));
}
