module armos.graphics.gl.polyrendermode;

import derelict.opengl3.gl;

/// ポリゴンのレンダリング方法を表します
enum PolyRenderMode {
    Points    = GL_POINTS, /// 頂点のみ描画します．
    WireFrame = GL_LINE,   /// 線のみ描画します．
    Fill      = GL_FILL,   /// 面を塗りつぶして描画します．
}
