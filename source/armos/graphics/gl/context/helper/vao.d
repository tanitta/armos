module armos.graphics.gl.context.helper.vao;

import armos.graphics.gl.context;
import armos.graphics.gl.vao;

///
Vao vao(Context c){
    if(c._vaoStack.empty)return null;
    return c._vaoStack.top;
}

///
Context pushVao(Context c, Vao vao){
    auto prevVao = c.vao;
    c._vaoStack.push(vao);
    if(!c.vao){
        Vao.bind(null);
        return c;
    }
    if(c.vao != prevVao){
        c.vao.bind;
    }
    return c;
}

///
Context popVao(Context c){
    auto prevVao = c.vao;
    c._vaoStack.pop();
    if(c._vaoStack.empty){
        Vao.bind(null);
        return c;
    }
    if(c.vao != prevVao){
        c.vao.bind;
        return c;
    }
    return c;
}
