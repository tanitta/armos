module armos.graphics.gl.context.helper.texture;

import armos.graphics.gl.context;
import armos.graphics.gl.texture;

///
Texture texture(Context c, TextureTarget target){
    auto unitIndex = c.activeTextureUnit;
    return c.texture(target, unitIndex);
}

///
Texture texture(Context c, in TextureTarget target, in size_t unitIndex){
    import std.algorithm;
    // if(c._textureStacks.keys.canFind(unitIndex)) // create stack
    if(c._textureStacks[unitIndex][target].empty)return null;
    return c._textureStacks[unitIndex][target].top;
}

///
Context pushTexture(alias bind = Texture.bind)(Context c, Texture texture){
    return c.pushTexture!bind(texture, texture.target, c.activeTextureUnit);
}

///
Context pushTexture(alias bind = Texture.bind)(Context c, Texture texture, in TextureTarget target, in size_t unitIndex){
    auto prevTex = c.texture(target, unitIndex);
    c._textureStacks[unitIndex][target].push(texture);
    c.pushActiveTextureUnit(unitIndex);
    if(!c.texture(target, unitIndex)){
        bind(null, target);
        return c;
    }
    if(c.texture(target, unitIndex)!= prevTex){
        bind(c.texture(target, unitIndex), target);
    }
    c.popActiveTextureUnit();
    return c;
}

///
Context popTexture(alias bind = Texture.bind)(Context c, in TextureTarget target){
    return c.popTexture!bind(target, c.activeTextureUnit);
}

///
Context popTexture(alias bind = Texture.bind)(Context c, in TextureTarget target, in size_t unitIndex){
    auto prevTex = c.texture(target, unitIndex);
    c._textureStacks[unitIndex][target].pop();
    c.pushActiveTextureUnit(unitIndex);
    if(c._textureStacks[unitIndex][target].empty){
        bind(null, target);
        return c;
    }
    if(c.texture(target, unitIndex) != prevTex){
        bind(c.texture(target, unitIndex), target);
        return c;
    }
    c.popActiveTextureUnit();
    return c;
}

unittest{
}
