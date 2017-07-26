module armos.command.generator.mainapp;

string mainAppSourceTemplate(in string[] defines,
                             in string[] setups,
                             in string[] updates,
                             in string[] draws){
    import std.array;
    string define = defines.join("\n    ");
    string setup  = setups.join("\n        ");
    string update = updates.join("\n        ");
    string draw   = draws.join("\n        ");
    return mainAppSourceTemplate(define, setup, update, draw);
}

string mainAppSourceTemplate(string define,
                             string setup,
                             string update,
                             string draw){
    define = (define.length>0)? "\n    "     ~ define ~ "\n"     : "";
    setup  = (setup.length>0)?  "\n        " ~ setup  ~ "\n    " : "";
    update = (update.length>0)? "\n        " ~ update ~ "\n    " : "";
    draw   = (draw.length>0)?   "\n        " ~ draw   ~ "\n    " : "";
    return `static import ar = armos;

class MainApp : ar.app.BaseApp{
    this(){}

    override void setup(){` ~ setup ~ `}

    override void update(){` ~ update ~ `}

    override void draw(){` ~ draw ~ `}

    override void keyPressed(ar.utils.KeyType key){}

    override void keyReleased(ar.utils.KeyType key){}

    override void mouseMoved(ar.math.Vector2i position, int button){}

    override void mousePressed(ar.math.Vector2i position, int button){}

    override void mouseReleased(ar.math.Vector2i position, int button){}
` ~ define ~ `}

void main(){ar.app.run(new MainApp);}
`;
}

unittest{
    // import std.stdio;
    // mainAppSourceTemplate("", "", "", "").writeln;
}

