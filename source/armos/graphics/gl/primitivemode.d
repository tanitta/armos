module armos.graphics.gl.primitivemode;

import derelict.opengl3.gl;

/// ポリゴンのプリミティブを指定します．
enum PrimitiveMode{
    Triangles     = GL_TRIANGLES,
    TriangleStrip = GL_TRIANGLE_STRIP,
    TriangleFan   = GL_TRIANGLE_FAN,
    Lines         = GL_LINES,
    LineStrip     = GL_LINE_STRIP,
    LineLoop      = GL_LINE_LOOP,
    Points        = GL_POINTS,
}
