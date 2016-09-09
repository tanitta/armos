module armos.graphics.style;

/++
色や線の幅などの描画方法をまとめたstructです．
+/
struct Style {
    import armos.graphics;
    import armos.types;
    Color color = Color(255, 255, 255, 255);
    Color backgroundColor = Color(30, 30, 30, 255);
    BlendMode blendMode;
    float lineWidth = 1.0;
    bool isSmoothing = true;
    PolyRenderMode polyRenderMode = PolyRenderMode.Fill;
    bool isDepthTest = false;
}
