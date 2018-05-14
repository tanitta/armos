module armos.graphics.gl.stack;

///
class Stack(T){
    public{
        ref const(T) top()const{
            return _stack[$-1];
        }

        ref T top(){
            return _stack[$-1];
        }
        
        
        Stack!T push(T elem){
            _stack ~= elem;
            return this;
        }
        
        Stack!T pop(){
            assert(!empty, "stack is empty");
            import std.array;
            _stack.popBack;
            return this;
        }
        
        Stack!T load(ref T elem){
            _stack[$-1] = elem;
            return this;
        }
        
        bool empty()const{
            return _stack.length == 0;
        }

        size_t length()const{
            return _stack.length;
        }
    }//public

    private{
        T[] _stack;
    }//private
}//class MatrixStack

unittest{
    auto t = new Stack!int;
    import std.stdio;
    t.push(1);
    assert(t.top == 1);
    t.push(2);
    assert(t.top == 2);
    t.pop();
    assert(t.top == 1);
}

import armos.math.matrix;
Stack!Matrix4f mult(Stack!Matrix4f stack, in Matrix4f m){
    stack.top = stack.top * m;
    return stack;
}
