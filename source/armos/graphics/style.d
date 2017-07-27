module armos.graphics.style;

/++
色や線の幅などの描画方法をまとめたstructです．
+/
struct Style {
    import armos.graphics;
    import armos.types;
    Color color = Color(1.0, 1.0, 1.0, 1.0);
    Color backgroundColor = Color(0.12, 0.12, 0.12, 1.0);
    BlendMode blendMode;
    float lineWidth = 1.0;
    bool isSmoothing = true;
    PolyRenderMode polyRenderMode = PolyRenderMode.Fill;
    bool isDepthTest = false;
}
