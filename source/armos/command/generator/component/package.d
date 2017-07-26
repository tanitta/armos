module armos.command.generator.component;

abstract class Component{
    static Component add(ref Component[] components, ref string[] options);
    string[] define()const{ return [""]; }
    string[] setup()const{ return [""]; }
    string[] update()const{ return [""]; } 
    string[] draw()const{ return [""]; }
    // private this(){};
}

/++
+/
class DefaultCamera: Component{
    import std.string;
    static void add(ref Component[] components, ref string[] options){
        import std.getopt;

        string name;
        options.getopt("defaultcamera", &name);
        if(name.length != 0){
            auto camera = new DefaultCamera();
            camera._name = name;
            components ~= camera;
        }
    };
    override string[] define()const{ 
        return ["private ar.graphics.Camera %s;".format(_name)]; 
    }
    override string[] setup()const{ 
        import std.range;
        import std.array;
        import std.string;
        import std.conv;
        return [_name ~ " = (new ar.graphics.DefaultCamera()).position(ar.math.Vector3f(0, 0, -1))",
                ' '.repeat.take(_name.length).array.to!string ~ "                                    .target(ar.math.Vector3f.zero);"]; 
    }

    override string[] draw()const{ 
        return ["{auto cameraScope = ar.utils.scoped(%s);}".format(_name)]; 
    }
    private{
        this(){};
        string _name;
    }
}//class Camera
