module armos.graphics.gl.context.helper.buffer;

import armos.graphics.gl.context;
import armos.graphics.gl.buffer;

Buffer buffer(Context c, in BufferType bufferType){
    import std.algorithm:canFind;
    if(!c._bufferStacks.keys.canFind(bufferType)) return null;
    if(c._bufferStacks[bufferType].empty) return null;
    return c._bufferStacks[bufferType].top;
}

Context pushBuffer(Context c, in BufferType bufferType, Buffer buffer){
    auto prevBuffer = c.buffer(bufferType);
    c._bufferStacks[bufferType].push(buffer);
    if(!c.buffer(bufferType)){
        Buffer.bind(bufferType, null);
        return c;
    }
    if(c.buffer(bufferType) != prevBuffer){
        c.buffer(bufferType).bind;
        return c;
    }
    return c;
}

Context popBuffer(Context c, in BufferType bufferType){
    auto prevBuffer = c.buffer(bufferType);
    c._bufferStacks[bufferType].pop();
    if(c._bufferStacks[bufferType].empty){
        Buffer.bind(bufferType, null);
        return c;
    }
    if(c.buffer(bufferType) != prevBuffer){
        c.buffer(bufferType).bind;
        return c;
    }
    return c;
}
