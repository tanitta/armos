module armos.graphics.gl.context.helper.shader;

import armos.graphics.gl.context;
import armos.graphics.gl.shader;

Shader shader(Context c){
    if(c._shaderStack.empty) return null;
    return c._shaderStack.top;
}

///
Context pushShader(Context c, Shader shader){
    auto prevShader = c.shader;
    c._shaderStack.push(shader);
    if(!c.shader){
        Shader.bind(null);
        return c;
    }
    if(c.shader != prevShader){
        c.shader.bind;
    }
    return c;
}

///
Context popShader(Context c){
    auto prevShader = c.shader;
    c._shaderStack.pop();
    if(c._shaderStack.empty){
        Shader.bind(null);
        return c;
    }
    if(c.shader != prevShader){
        c.shader.bind;
        return c;
    }
    return c;
}
