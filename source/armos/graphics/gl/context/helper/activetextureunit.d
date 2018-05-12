module armos.graphics.gl.context.helper.activetextureunit;

import armos.graphics.gl.context;

size_t activeTextureUnit(Context c){
    if(c._activeTextureUnitStack.empty) return 0;
    return c._activeTextureUnitStack.top;
}

///
Context pushActiveTextureUnit(alias bind = bindActiveTextureUnit)(Context c, in size_t unit){
    auto prevUnit = c.activeTextureUnit;
    c._activeTextureUnitStack.push(unit);
    if(c.activeTextureUnit!= prevUnit){
        bind(unit);
    }
    return c;
}

///
Context popActiveTextureUnit(alias bind = bindActiveTextureUnit)(Context c){
    auto prevUnit = c.activeTextureUnit;
    c._activeTextureUnitStack.pop();
    if(c._activeTextureUnitStack.empty){
        bind(0);
        return c;
    }
    if(c.activeTextureUnit != prevUnit){
        bind(c.activeTextureUnit);
        return c;
    }
    return c;
}

private void bindActiveTextureUnit(in size_t unit){
    import derelict.opengl3.gl;
    import std.conv; 
    glActiveTexture((GL_TEXTURE0+unit).to!uint);
}

unittest{}
