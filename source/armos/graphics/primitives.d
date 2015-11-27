module armos.graphics.primitives;
import armos.graphics;
import armos.math;
import std.math;

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

armos.graphics.Mesh spherePrimitive(){
	auto mesh = new armos.graphics.Mesh;
	return mesh;
}

armos.graphics.Mesh conePrimitive(){
	auto mesh = new armos.graphics.Mesh;
	return mesh;
}

armos.graphics.Mesh cylinderPrimitive(){
	auto mesh = new armos.graphics.Mesh;
	return mesh;
}

armos.graphics.Mesh icoSpherePrimitive(){
	auto mesh = new armos.graphics.Mesh;
	return mesh;
}

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
armos.graphics.Mesh circlePrimitive(in float x, in float y, in float z, in float radius, in int resolution = 12){
	return circlePrimitive(armos.math.Vector3f(x, y, z), radius, resolution);
}

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

armos.graphics.Mesh planePrimitive(in float x, in float y, in float z, in float w, in float h){
	return planePrimitive(armos.math.Vector3f(x, y, z), armos.math.Vector2f(w, h));
}
