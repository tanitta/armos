module armos.graphics.style;

/++
色や線の幅などの描画方法をまとめたstructです．
+/
struct Style {
    static import armos.graphics;
    static import armos.types;
    armos.types.Color color = armos.types.Color(255, 255, 255, 255);
    armos.types.Color backgroundColor = armos.types.Color(30, 30, 30, 255);
    armos.graphics.BlendMode blendMode;
    float lineWidth = 1.0;
    bool isSmoothing = true;
    armos.graphics.PolyRenderMode polyRenderMode = armos.graphics.PolyRenderMode.Fill;
    bool isDepthTest = false;
}
