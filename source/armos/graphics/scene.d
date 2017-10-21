module armos.graphics.scene;

///
class Scene {
    import armos.graphics.matrixstack:MatrixStack;
    MatrixStack modelMatrixStack = new MatrixStack;
    pragma(msg, __FILE__, "(", __LINE__, "): ",
           "TODO: scene has only model matrix stack");
    MatrixStack viewMatrixStack = new MatrixStack;
    MatrixStack projectionMatrixStack = new MatrixStack;
    MatrixStack textureMatrixStack = new MatrixStack;
    public{
    }//public

    private{
    }//private
}//class Scene

