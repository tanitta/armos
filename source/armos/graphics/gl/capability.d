module armos.graphics.gl.capability;

import derelict.opengl3.gl;

///
enum Capability {
    DepthTest = GL_DEPTH_TEST, 
}//enum GlCapability

void bind(in Capability type, in bool validity){
    if(validity){
        glEnable(type);
    }else{
        glDisable(type);
    }
}
