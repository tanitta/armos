module armos.graphics.gl.context.helper.capability;

import armos.graphics.gl.context;
import armos.graphics.gl.capability;

///
bool capability(Context c, in Capability type){
    import std.algorithm:canFind;
    if(!c._capabilityStacks.keys.canFind(type)) return false;
    if(c._capabilityStacks[type].empty) return false;
    return c._capabilityStacks[type].top;
}

///
Context pushCapability(Context c, in Capability type, in bool validity){
    bool prevCapability = c.capability(type);
    c._capabilityStacks[type].push(validity);
    if(c.capability(type) != prevCapability){
        bind(type, validity);
    }
    return c;
}

///
Context popCapability(Context c, in Capability type){
    auto prevCapability = c.capability(type);
    c._capabilityStacks[type].pop();
    if(c._capabilityStacks[type].empty){
        bind(type, false);
        return c;
    }
    if(c.capability(type) != prevCapability){
        bind(type, c.capability(type));
        return c;
    }
    return c;
}
