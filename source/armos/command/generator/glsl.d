module armos.command.generator.glsl;

import std.getopt;
import std.path;
import std.file;

// armos g glslsource name.vert --type=defaultglsl
// => generate shaders/{name.vert}

// armos g glslsource --path=shaders/hoge.vert --type=defaultglsl
// => generate shaders/hoge.vert
auto generateGlslSource(string[] args){
    string type; //TODO
    string path;
    args.getopt("type|t", &type,
                "path|p", &path);

    string name;

    string writenPath;
    if(!path){
        name = args[0];
        path = buildPath(getcwd, "shaders", name);
    }
    if(!path.isAbsolute){
        import std.file;
        path = buildPath(getcwd, path);
        name = path.baseName;
    }

    if(!path.dirName.exists){
        path.dirName.mkdirRecurse;
    }
    string sourceType = path.extension;
    string sourceText;
    switch (sourceType) {
        case ".vert":
            sourceText = generateVertSource(type);
            break;
        case ".geom":
            sourceText = generateGeomSource(type);
            break;
        case ".frag":
            sourceText = generateFragSource(type);
            break;
        default:
            assert(false);
    }
    write(path, sourceText);
}


// armos g glslsources name --type=defaultglsl
// => generate shaders/name/{main.vert, main.geom, main.frag}

// armos g glslsources --path=shaders/hoge --type=defaultglsl
// => generate shaders/hoge/{main.vert, main.geom, main.frag}
auto generateGlslSources(string[] args){
    string type;
    string path;
    bool shouldGenerateNoVert;
    bool shouldGenerateNoGeom;
    bool shouldGenerateNoFrag;
    args.getopt("type|t", &type,
                "path|p", &path,
                "no-vert", &shouldGenerateNoVert,
                "no-geom", &shouldGenerateNoGeom,
                "no-frag", &shouldGenerateNoFrag);

    if(!path){
        path = buildPath("shaders", args[0]);
    }
    if(!shouldGenerateNoVert){
        args = args.dup ~ "--path=" ~ buildPath(path, "main.vert");
        generateGlslSource(args);
    }

    if(!shouldGenerateNoGeom){
        args = args.dup ~ "--path=" ~ buildPath(path, "main.geom");
        generateGlslSource(args);
    }

    if(!shouldGenerateNoFrag){
        args = args.dup ~ "--path=" ~ buildPath(path, "main.frag");
        generateGlslSource(args);
    }
}

private string generateVertSource(in string type){
    return `#version 330

// Enable to load package via glslify
// #pragma glslify: noise = require(glsl-noise/simplex/2d)

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat4 textureMatrix;

in vec4 vertex;
// in vec3 normal;
// in vec3 tangent;
// in vec4 texCoord0;
// in vec4 texCoord1;
// in vec4 color;

// out vec4 f_vertex;
// out vec3 f_normal;
// out vec3 f_tangent;
// out vec4 f_texCoord0;
// out vec4 f_texCoord1;
// out vec4 f_color;

void main(void) {
    gl_Position = modelViewProjectionMatrix * vertex;

    // f_vertex = vertex;
    // f_normal = normal;
    // f_tangent = tangent;
    // f_texCoord0 = texCoord0;
    // f_texCoord1 = texCoord1;
    // f_color = color;
}
`;
}

private string generateGeomSource(in string type){
    return "";
}

private string generateFragSource(in string type){
    return `#version 330

// Enable to load package via glslify
// #pragma glslify: noise = require(glsl-noise/simplex/2d)

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 modelViewProjectionMatrix;
uniform mat4 textureMatrix;

// in vec4 f_vertex;
// in vec3 f_normal;
// in vec3 f_tangent;
// in vec4 f_texCoord0;
// in vec4 f_texCoord1;
// in vec4 f_color;

out vec4 fragColor;

void main(void) {
    fragColor = vec4(1, 1, 1, 1);
}
`;
}
