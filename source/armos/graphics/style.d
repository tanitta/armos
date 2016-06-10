module armos.graphics.style;
import armos.graphics;
import armos.types;

/++
色や線の幅などの描画方法をまとめたstructです．
+/
struct Style {
    armos.types.Color color = armos.types.Color(255, 255, 255, 255);
    armos.types.Color backgroundColor = armos.types.Color(30, 30, 30, 255);
    armos.graphics.BlendMode blendMode;
    float lineWidth = 1.0;
    bool isSmoothing = true;
    bool isFill = true;
    bool isDepthTest = false;
}
