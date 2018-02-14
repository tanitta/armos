module armos.graphics.gl.context.helper.fbo;

import armos.graphics.gl.context;
import armos.graphics.gl.fbo;

///
Fbo fbo(Context c){
    if(c._fboStack.empty)return null;
    return c._fboStack.top;
}

Context pushFbo(Context c, Fbo fbo){
    auto prevFbo = c.fbo;
    c._fboStack.push(fbo);
    if(!c.fbo){
        Fbo.bind(null);
        return c;
    }
    if(c.fbo!= prevFbo){
        c.fbo.bind;
    }
    return c;
}

Context popFbo(Context c){
    auto prevFbo = c.fbo;
    c._fboStack.pop();
    if(c._fboStack.empty){
        Fbo.bind(null);
        return c;
    }
    if(c.fbo != prevFbo){
        c.fbo.bind;
        return c;
    }
    return c;
}
