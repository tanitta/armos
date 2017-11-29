module armos.graphics.gl.context.helper.matrix;

import armos.graphics.gl.context;
import armos.math.matrix;

Matrix4f matrix(Context c, in MatrixType type){
    return c.matrixStack(type).top;
}

///
Context matrix(Context c, in MatrixType type, in Matrix4f m){
    c.matrixStack(type).top = m;
    return c;
}

///
Context pushMatrix(Context c, in MatrixType type){
    c.matrixStack(type).push(c.matrixStack(type).top);
    return c;
}

///
Context popMatrix(Context c, in MatrixType type){
    c.matrixStack(type).pop;
    return c;
}

///
Context multMatrix(Context c, in MatrixType type, in Matrix4f m){
    c.matrixStack(type).top = c.matrixStack(type).top * m;
    return c;
}


///
Matrix4f modelMatrix(Context c){
    return c.matrix(MatrixType.Model);
}

///
Context modelMatrix(Context c, in Matrix4f m){
    return c.matrix(MatrixType.Model, m);
}

///
Context pushModelMatrix(Context c){
    return c.pushMatrix(MatrixType.Model);
}

///
Context popModelMatrix(Context c){
    return c.popMatrix(MatrixType.Model);
}

///
Context multModelMatrix(Context c, in Matrix4f m){
    return c.multMatrix(MatrixType.Model, m);
}


///
Matrix4f viewMatrix(Context c){
    return c.matrix(MatrixType.View);
}

///
Context viewMatrix(Context c, in Matrix4f m){
    return c.matrix(MatrixType.View, m);
}

///
Context pushViewMatrix(Context c){
    return c.pushMatrix(MatrixType.View);
}

///
Context popViewMatrix(Context c){
    return c.popMatrix(MatrixType.View);
}

///
Context multViewMatrix(Context c, in Matrix4f m){
    return c.multMatrix(MatrixType.View, m);
}


///
Matrix4f projectionMatrix(Context c){
    return c.matrix(MatrixType.Projection);
}

///
Context projectionMatrix(Context c, in Matrix4f m){
    return c.matrix(MatrixType.Projection, m);
}

///
Context pushProjectionMatrix(Context c){
    return c.pushMatrix(MatrixType.Projection);
}

///
Context popProjectionMatrix(Context c){
    return c.popMatrix(MatrixType.Projection);
}

///
Context multProjectionMatrix(Context c, in Matrix4f m){
    return c.multMatrix(MatrixType.Projection, m);
}
